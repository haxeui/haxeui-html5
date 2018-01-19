package haxe.ui.backend;

import haxe.ui.components.Button;
import haxe.ui.components.TextArea;
import haxe.ui.components.Image;
import haxe.ui.core.KeyboardEvent;
import haxe.ui.components.TextField;
import haxe.ui.backend.html5.EventMapper;
import haxe.ui.backend.html5.HtmlUtils;
import haxe.ui.backend.html5.StyleHelper;
import haxe.ui.backend.html5.UserAgent;
import haxe.ui.backend.html5.native.NativeElement;
import haxe.ui.components.VProgress;
import haxe.ui.containers.Header;
import haxe.ui.containers.ScrollView;
import haxe.ui.containers.TableView;
import haxe.ui.core.Component;
import haxe.ui.core.ImageDisplay;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.Screen;
import haxe.ui.core.ScrollEvent;
import haxe.ui.core.TextDisplay;
import haxe.ui.core.TextInput;
import haxe.ui.core.UIEvent;
import haxe.ui.styles.Style;
import haxe.ui.util.Rectangle;
import haxe.ui.util.filters.Blur;
import haxe.ui.util.filters.DropShadow;
import haxe.ui.util.filters.FilterParser;
import js.Browser;
import js.html.CSSStyleDeclaration;
import js.html.Element;
import js.html.MutationObserver;
import js.html.MutationRecord;
import js.html.Node;
import js.html.WheelEvent;

class ComponentBase {
    public var element:Element;
    private var _eventMap:Map<String, UIEvent->Void>;

    private var _nativeElement:NativeElement;

    private static var _mutationObserver:MutationObserver;
    private static var elementToComponent:Map<Node, Component> = new Map<Node, Component>();

    @:access(haxe.ui.backend.ScreenBase)
    public function new() {
        _eventMap = new Map<String, UIEvent->Void>();
        if (_mutationObserver == null) {
            _mutationObserver = new MutationObserver(onMutationEvent);
            _mutationObserver.observe(Screen.instance.container, { childList: true } );
        }
    }

    private static function onMutationEvent(records:Array<MutationRecord>, o:MutationObserver) {
        var done:Bool = false;
        for (record in records) {
            for (i in 0...record.addedNodes.length) {
                var node:Node = record.addedNodes.item(i);
                var c:Component = elementToComponent.get(node);
                if (c != null) {
                    c.recursiveReady();
                }
            }
            if (done == true) {
                break;
            }
        }
    }

    private function recursiveReady() {
        elementToComponent.remove(element);
        var component:Component = cast(this, Component);
        component.invalidateLayout();
        component.ready();
        for (child in component.childComponents) {
            child.recursiveReady();
        }
    }

    public function handleCreate(native:Bool) {
        var newElement = null;
        if (native == true) {
            if (Std.is(this, ScrollView)) { // special case for scrollview
                _nativeElement = new NativeElement(cast this);
                if (element == null) {
                    element = _nativeElement.create();
                }
                element.style.position = "absolute";
                element.style.overflow = "auto";
                elementToComponent.set(element, cast(this, Component));
                return;
            } else {
                var component:Component = cast(this, Component);
                var nativeConfig:Map<String, String> = component.getNativeConfigProperties();
                if (nativeConfig != null && nativeConfig.exists("class")) {
                    _nativeElement = Type.createInstance(Type.resolveClass(nativeConfig.get("class")), [this]);
                    _nativeElement.config = nativeConfig;
                    newElement = _nativeElement.create();
                }
            }

            if (newElement != null) {
                newElement.style.position = "absolute";

                if (element != null) {
                    var p = element.parentElement;
                    if (p != null) {
                        elementToComponent.remove(element);
                        p.replaceChild(newElement, element);
                    }
                }

                element = newElement;

                remapEvents();
            }
        }

        if (newElement == null) {
            if (Std.is(this, ScrollView)) {
                _nativeElement = null;
                if (element == null) {
                    element = Browser.document.createDivElement();
                    element.style.setProperty("-webkit-touch-callout", "none");
                    element.style.setProperty("-webkit-user-select", "none");
                    element.style.setProperty("-khtml-user-select", "none");
                    element.style.setProperty("-moz-user-select", "none");
                    element.style.setProperty("-ms-user-select", "none");
                    element.style.setProperty("user-select", "none");
                    element.style.boxSizing = "border-box";
                    element.style.position = "absolute";
                }

                element.scrollTop = 0;
                element.scrollLeft = 0;
                element.style.overflow = "hidden";
                elementToComponent.set(element, cast(this, Component));
                return;
            }

            newElement = Browser.document.createDivElement();

            newElement.style.setProperty("-webkit-touch-callout", "none");
            newElement.style.setProperty("-webkit-user-select", "none");
            newElement.style.setProperty("-khtml-user-select", "none");
            newElement.style.setProperty("-moz-user-select", "none");
            newElement.style.setProperty("-ms-user-select", "none");
            newElement.style.setProperty("user-select", "none");
            newElement.style.boxSizing = "border-box";
            newElement.style.position = "absolute";

            if (Std.is(this, Image)) {
                newElement.style.boxSizing = "initial";
            }

            if (element != null) {
                var p = element.parentElement;
                if (p != null) {
                    elementToComponent.remove(element);
                    p.replaceChild(newElement, element);
                }
            }

            element = newElement;
            elementToComponent.set(element, cast(this, Component));
            _nativeElement = null;

            remapEvents();
        }
    }

    private function remapEvents() {
        if (_eventMap == null) {
            return;
        }
        var copy:Map <String, UIEvent->Void> = new Map<String, UIEvent->Void>();
        for (k in _eventMap.keys()) {
            var fn = _eventMap.get(k);
            copy.set(k, fn);
            unmapEvent(k, fn);
        }
        _eventMap = new Map<String, UIEvent->Void>();
        for (k in copy.keys()) {
            mapEvent(k, copy.get(k));
        }
    }

    private function handlePosition(left:Null<Float>, top:Null<Float>, style:Style) {
        if (element == null) {
            return;
        }

        if (left != null) {
            element.style.left = HtmlUtils.px(left);
        }
        if (top != null) {
            element.style.top = HtmlUtils.px(top);
        }

        if (Std.is(this, TableView) && left != null && top != null && cast(this, TableView).native == true) {
            var c:Component = cast(this, Component);
            var h = c.findComponent(Header);
            h.element.style.left = '${HtmlUtils.px(h.screenLeft)}';
            h.element.style.top = '${HtmlUtils.px(h.screenTop)}';

        }
    }

    private function handleSize(width:Null<Float>, height:Null<Float>, style:Style) {
        if (width == null || height == null || width <= 0 || height <= 0) {
            return;
        }

        if (this.element == null) {
            return;
        }

        if (Std.is(this, VProgress)) { // this is a hack for chrome
            if (element.style.getPropertyValue("transform-origin") != null && element.style.getPropertyValue("transform-origin").length > 0) {
                var tw = width;
                var th = height;

                width = th;
                height = tw;
            }
        }

        var c:Component = cast(this, Component);
        var css:CSSStyleDeclaration = element.style;
        StyleHelper.apply(this, width, height, style);
        var parent:ComponentBase = c.parentComponent;
        if (parent != null && parent.element.style.borderWidth != null) {
            css.marginTop = '-${parent.element.style.borderWidth}';
            css.marginLeft = '-${parent.element.style.borderWidth}';
        } else {
        }

        for (child in cast(this, Component).childComponents) {
            if (style.borderLeftSize != null && style.borderLeftSize > 0) {
                child.element.style.marginLeft = '-${style.borderLeftSize}px';
            }
            if (style.borderTopSize != null && style.borderTopSize > 0) {
                child.element.style.marginTop = '-${style.borderTopSize}px';
            }
        }

        if (style.clip == true) {
            handleClipRect(new Rectangle(0, 0, width, height));
        }
    }

    private function handleReady() {
        if (cast(this, Component).id != null) {
            element.id = cast(this, Component).id;
        }
    }

    private function handleClipRect(value:Rectangle) {
        var c:Component = cast(this, Component);
        var parent:Component = c.parentComponent;
        if (value != null && parent != null && (parent._nativeElement == null || Std.is(c, Header))) {
            element.style.clip = 'rect(${HtmlUtils.px(value.top)},${HtmlUtils.px(value.right)},${HtmlUtils.px(value.bottom)},${HtmlUtils.px(value.left)})';
            if (Std.is(this, Header) && parent.native == true) {
                if (element.style.position != "fixed") {
                    element.style.position = "fixed";
                }
                element.style.left = '${HtmlUtils.px(c.screenLeft - value.left)}';
                element.style.top = '${HtmlUtils.px(c.screenTop - value.top)}';
            } else {
                element.style.left = '${HtmlUtils.px(c.left - value.left)}';
                element.style.top = '${HtmlUtils.px(c.top - value.top)}';
            }
        } else {
            element.style.removeProperty("clip");
        }
    }

    public function handlePreReposition() {
    }

    public function handlePostReposition() {
    }

    private function handleVisibility(show:Bool) {
        element.style.display = (show == true) ? "" : "none";
    }

    //***********************************************************************************************************
    // Text related
    //***********************************************************************************************************
    private var _textDisplay:TextDisplay;
    public function createTextDisplay(text:String = null):TextDisplay {
        if (_textDisplay == null) {
            _textDisplay = new TextDisplay();
            _textDisplay.parentComponent = cast this;
            element.appendChild(_textDisplay.element);
        }
        if (text != null) {
            _textDisplay.text = text;
        }
        return _textDisplay;
    }

    public function getTextDisplay():TextDisplay {
        return createTextDisplay();
    }

    public function hasTextDisplay():Bool {
        return (_textDisplay != null);
    }

    private var _textInput:TextInput;
    public function createTextInput(text:String = null):TextInput {
        if (_textInput == null) {
            _textInput = new TextInput();
            _textInput.parentComponent = cast this;
            element.appendChild(_textInput.element);
        }
        if (text != null) {
            _textInput.text = text;
        }
        return _textInput;
    }

    public function getTextInput():TextInput {
        return createTextInput();
    }

    public function hasTextInput():Bool {
        return (_textInput != null);
    }

    //***********************************************************************************************************
    // Image related
    //***********************************************************************************************************
    private var _imageDisplay:ImageDisplay;
    public function createImageDisplay():ImageDisplay {
        if (_imageDisplay == null) {
            _imageDisplay = new ImageDisplay();
            element.appendChild(_imageDisplay.element);
        }
        return _imageDisplay;
    }

    public function getImageDisplay():ImageDisplay {
        return createImageDisplay();
    }

    public function hasImageDisplay():Bool {
        return (_imageDisplay != null);
    }

    public function removeImageDisplay() {
        if (_imageDisplay != null) {
            /*
            if (contains(_imageDisplay) == true) {
                removeChild(_imageDisplay);
            }
            */
            _imageDisplay.dispose();
            _imageDisplay = null;
        }
    }

    private function handleSetComponentIndex(child:Component, index:Int) {
        if (index == cast(this, Component).childComponents.length - 1) {
            element.appendChild(child.element);
        } else {
            HtmlUtils.insertBefore(cast(this, Component).childComponents[index + 1].element, child.element);
        }
    }

    //***********************************************************************************************************
    // Display tree
    //***********************************************************************************************************
    private function handleAddComponent(child:Component):Component {
        element.appendChild(child.element);
        return child;
    }

    private function handleAddComponentAt(child:Component, index:Int):Component {
        handleAddComponent(child);
        handleSetComponentIndex(child, index);
        return child;
    }

    private function handleRemoveComponent(child:Component, dispose:Bool = true):Component {
        HtmlUtils.removeElement(child.element);
        return child;
    }

    private function handleRemoveComponentAt(index:Int, dispose:Bool = true):Component {
        var child = cast(this, Component)._children[index];
        HtmlUtils.removeElement(child.element);
        return child;
    }

    private function applyStyle(style:Style) {
        if (element == null) {
            return;
        }

        setCursor(style.cursor);

        if (style.filter != null) {
            if (style.filter[0] == "drop-shadow") {
                var dropShadow:DropShadow = FilterParser.parseDropShadow(style.filter);
                if (dropShadow.inner == false) {
                    element.style.boxShadow = '${dropShadow.distance}px ${dropShadow.distance}px ${dropShadow.blurX}px 0px ${HtmlUtils.rgba(dropShadow.color, dropShadow.alpha)}';
                } else {
                    element.style.boxShadow = 'inset ${dropShadow.distance}px ${dropShadow.distance}px ${dropShadow.blurX}px 0px ${HtmlUtils.rgba(dropShadow.color, dropShadow.alpha)}';
                }
            } else if (style.filter[0] == "blur") {
                var blur:Blur = FilterParser.parseBlur(style.filter);
                element.style.setProperty("-webkit-filter", 'blur(${blur.amount}px)');
                element.style.setProperty("-moz-filter", 'blur(${blur.amount}px)');
                element.style.setProperty("-o-filter", 'blur(${blur.amount}px)');
                //element.style.setProperty("-ms-filter", 'blur(${blur.amount}px)');
                element.style.setProperty("filter", 'blur(${blur.amount}px)');
            }
        } else {
            element.style.filter = null;
            element.style.boxShadow = null;
            element.style.removeProperty("box-shadow");
            element.style.removeProperty("-webkit-filter");
            element.style.removeProperty("-moz-filter");
            element.style.removeProperty("-o-filter");
            //element.style.removeProperty("-ms-filter");
            element.style.removeProperty("filter");
        }

        if (style.opacity != null) {
            element.style.opacity = '${style.opacity}';
        }

        if (style.fontSize != null) {
            element.style.fontSize = HtmlUtils.px(style.fontSize);
        }
        
        if (style.color != null) {
            element.style.color = HtmlUtils.color(style.color);
        }
    }

    //***********************************************************************************************************
    // Util functions
    //***********************************************************************************************************
    private function setCursor(cursor:String) {
        if (cursor == null) {
            //cursor = "default";
        }
        if (cursor == null) {
            element.style.removeProperty("cursor");
            if (hasImageDisplay()) {
                getImageDisplay().element.style.removeProperty("cursor");
            }
        } else {
            element.style.cursor = cursor;
            if (hasImageDisplay()) {
                getImageDisplay().element.style.cursor = cursor;
            }
            if (hasTextDisplay()) {
                getTextDisplay().element.style.cursor = cursor;
            }
        }

        for (c in cast(this, Component).childComponents) {
            if (c.element.style.cursor == null) {
                c.setCursor("inherit");
            }
        }
    }

    private var __props:Map<String, Dynamic>;
    private function get(name:String):Dynamic {
        if (__props == null) {
            return null;
        }
        return __props.get(name);
    }

    private function set(name:String, value:Dynamic) {
        if (__props == null) {
            __props = new Map<String, Dynamic>();
        }
        __props.set(name, value);
    }

    private function has(name:String):Bool {
        if (__props == null) {
            return false;
        }
        return __props.exists(name);
    }

    //***********************************************************************************************************
    // Events
    //***********************************************************************************************************
    private function mapEvent(type:String, listener:UIEvent->Void) {
        switch (type) {
            case MouseEvent.MOUSE_MOVE | MouseEvent.MOUSE_OVER | MouseEvent.MOUSE_OUT |
                MouseEvent.MOUSE_DOWN | MouseEvent.MOUSE_UP | MouseEvent.CLICK:
                if (_eventMap.exists(type) == false) {
                    if (EventMapper.MOUSE_TO_TOUCH.get(type) != null) {
                        element.addEventListener(EventMapper.MOUSE_TO_TOUCH.get(type), __onMouseEvent);
                    }
                    
                    _eventMap.set(type, listener);
                    element.addEventListener(EventMapper.HAXEUI_TO_DOM.get(type), __onMouseEvent);
                }
            case UIEvent.CHANGE:

                if (_eventMap.exists(type) == false) {
                    _eventMap.set(type, listener);

                    if (Std.is(this, TextField) || Std.is(this, TextArea)) {
                        element.addEventListener(EventMapper.HAXEUI_TO_DOM.get(KeyboardEvent.KEY_UP), __onTextFieldChangeEvent);
                    } else {
                        element.addEventListener(EventMapper.HAXEUI_TO_DOM.get(type), __onChangeEvent);
                    }
                }
            case MouseEvent.MOUSE_WHEEL:
                _eventMap.set(type, listener);
                if (UserAgent.instance.firefox == true) {
                    element.addEventListener("DOMMouseScroll", __onMouseWheelEvent);
                } else {
                    element.addEventListener("mousewheel", __onMouseWheelEvent);
                }
            case ScrollEvent.CHANGE:
                _eventMap.set(type, listener);
                element.addEventListener("scroll", __onScrollEvent);
        }
    }

    private function unmapEvent(type:String, listener:UIEvent->Void) {
        switch (type) {
            case MouseEvent.MOUSE_MOVE | MouseEvent.MOUSE_OVER | MouseEvent.MOUSE_OUT |
                MouseEvent.MOUSE_DOWN | MouseEvent.MOUSE_UP | MouseEvent.CLICK:
                _eventMap.remove(type);
                element.removeEventListener(EventMapper.HAXEUI_TO_DOM.get(type), __onMouseEvent);
                if (EventMapper.MOUSE_TO_TOUCH.get(type) != null) {
                    element.removeEventListener(EventMapper.MOUSE_TO_TOUCH.get(type), __onMouseEvent);
                }
                
            case UIEvent.CHANGE:
                _eventMap.remove(type);

                if (Std.is(this, TextField)) {
                    element.removeEventListener(EventMapper.HAXEUI_TO_DOM.get(KeyboardEvent.KEY_UP), __onTextFieldChangeEvent);
                } else {
                    element.removeEventListener(EventMapper.HAXEUI_TO_DOM.get(type), __onChangeEvent);
                }
            case MouseEvent.MOUSE_WHEEL:
                _eventMap.remove(type);
                if (UserAgent.instance.firefox == true) {
                    element.removeEventListener("DOMMouseScroll", __onMouseWheelEvent);
                } else {
                    element.removeEventListener("mousewheel", __onMouseWheelEvent);
                }
        }
    }

    //***********************************************************************************************************
    // Event Handlers
    //***********************************************************************************************************
    private function __onChangeEvent(event:js.html.UIEvent) {
        var type:String = EventMapper.DOM_TO_HAXEUI.get(event.type);
        if (type != null) {
            var fn = _eventMap.get(type);
            if (fn != null) {
                var uiEvent = new UIEvent(type);
                fn(uiEvent);
            }
        }
    }

    private function __onTextFieldChangeEvent(event:js.html.UIEvent) {
        var fn = _eventMap.get(UIEvent.CHANGE);
        if (fn != null) {
            var uiEvent = new UIEvent(UIEvent.CHANGE);
            fn(uiEvent);
        }
    }

    private function __onMouseEvent(event:js.html.Event) {
        var type:String = EventMapper.DOM_TO_HAXEUI.get(event.type);
        if (type != null) {
            try { // set/releaseCapture isnt currently supported in chrome
                if (type == MouseEvent.MOUSE_DOWN) {
                    element.setCapture();
                } else if (type == MouseEvent.MOUSE_UP) {
                    element.releaseCapture();
                }
            } catch (e:Dynamic) {
            }

            var fn = _eventMap.get(type);
            if (fn != null) {
                var mouseEvent = new MouseEvent(type);
                mouseEvent._originalEvent = event;
                
                var touchEvent = false;
                try {
                    touchEvent = Std.is(event, js.html.TouchEvent);
                } catch (e:Dynamic) { }
                
                if (touchEvent == true) {
                    //var te:js.html.TouchEvent = cast(event, js.html.TouchEvent);
                    //mouseEvent.screenX = te.changedTouches[0].pageX / Toolkit.scaleX;
                    //mouseEvent.screenY = te.changedTouches[0].pageY / Toolkit.scaleY;
                    //mouseEvent.touchEvent = true;
                } else if (Std.is(event, js.html.MouseEvent)) {
                    var me:js.html.MouseEvent = cast(event, js.html.MouseEvent);
                    mouseEvent.buttonDown = (me.buttons != 0);
                    mouseEvent.screenX = me.pageX / Toolkit.scaleX;
                    mouseEvent.screenY = me.pageY / Toolkit.scaleY;
                }
                
                fn(mouseEvent);
            }
        }
    }

    private function __onMouseWheelEvent(event:js.html.MouseEvent) {
        var fn = _eventMap.get(MouseEvent.MOUSE_WHEEL);
        if (fn == null) {
            return;
        }

        var delta:Float = 0;
        if (Reflect.field(event, "wheelDelta") != null) {
            delta = Reflect.field(event, "wheelDelta");
        } else if (Std.is(event, WheelEvent)) {
            delta = cast(event, WheelEvent).deltaY;
        } else {
            delta = -event.detail;
        }

        delta = Math.max(-1, Math.min(1, delta));

        var mouseEvent = new MouseEvent(MouseEvent.MOUSE_WHEEL);
        mouseEvent._originalEvent = event;
        mouseEvent.screenX = event.pageX;
        mouseEvent.screenY = event.pageY;
        mouseEvent.delta = delta;
        fn(mouseEvent);
    }
    
    private function __onScrollEvent(event:js.html.MouseScrollEvent) {
        var type:String = EventMapper.DOM_TO_HAXEUI.get(event.type);
        var fn = _eventMap.get(type);
        if (fn != null) {
            var scrollEvent:ScrollEvent = new ScrollEvent(ScrollEvent.CHANGE);
            fn(scrollEvent);
        }
    }
}