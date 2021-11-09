package haxe.ui.backend;

import haxe.ui.Toolkit;
import haxe.ui.backend.html5.EventMapper;
import haxe.ui.backend.html5.HtmlUtils;
import haxe.ui.backend.html5.StyleHelper;
import haxe.ui.backend.html5.UserAgent;
import haxe.ui.backend.html5.util.StyleSheetHelper;
import haxe.ui.components.Image;
import haxe.ui.core.Component;
import haxe.ui.core.ImageDisplay;
import haxe.ui.core.Screen;
import haxe.ui.core.TextDisplay;
import haxe.ui.core.TextInput;
import haxe.ui.events.KeyboardEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.ScrollEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.filters.Blur;
import haxe.ui.filters.DropShadow;
import haxe.ui.filters.Grayscale;
import haxe.ui.geom.Point;
import haxe.ui.geom.Rectangle;
import haxe.ui.styles.Style;
import js.Browser;
import js.html.CSSStyleDeclaration;
import js.html.CSSStyleSheet;
import js.html.CanvasElement;
import js.html.Element;
import js.html.MutationObserver;
import js.html.MutationRecord;
import js.html.Node;
import js.html.WheelEvent;

class ComponentImpl extends ComponentBase {
    public var element:Element;
    @:noCompletion private var _eventMap:Map<String, UIEvent->Void>;

    @:noCompletion private static var _mutationObserver:MutationObserver;
    private static var elementToComponent:Map<Node, Component> = new Map<Node, Component>();
    @:noCompletion private static var _stylesAdded:Bool = false;

    @:access(haxe.ui.backend.ScreenImpl)
    public function new() {
        super();
        _eventMap = new Map<String, UIEvent->Void>();
        if (_mutationObserver == null) {
            _mutationObserver = new MutationObserver(onMutationEvent);
            _mutationObserver.observe(Screen.instance.container, { childList: true } );
        }

        if (Browser.document.styleSheets.length == 0) {
            var style = Browser.document.createElement("style");
            style.appendChild(Browser.document.createTextNode(""));
            Browser.document.head.appendChild(style);
        }
        
        if (_stylesAdded == false) {
            _stylesAdded = true;
            
            var sheet:CSSStyleSheet = StyleSheetHelper.getValidStyleSheet();
            sheet.insertRule("#haxeui-container .haxeui-component, .haxeui-component:focus {
                position: absolute;
                box-sizing: border-box;
                -webkit-touch-callout: none;
                -webkit-user-select: none;
                -khtml-user-select: none;
                -moz-user-select: none;
                -ms-user-select: none;
                user-select: none;
                -webkit-tap-highlight-color: transparent;
                webkit-user-select;
                outline: none !important;
            }", sheet.cssRules.length);
            @:privateAccess Screen.instance.container.classList.add("haxeui-theme-" + Toolkit.theme);
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

    private override function get_isNativeScroller():Bool {
        return false;
    }
    
    private function recursiveReady() {
        elementToComponent.remove(element);
        var component:Component = cast(this, Component);
        component.invalidateComponentLayout();
        component.ready();
        for (child in component.childComponents) {
            child.recursiveReady();
        }
    }

    private override function handleCreate(native:Bool) {
        if (this.isScroller) {
            if (element == null) {
                element = Browser.document.createDivElement();
            }

            element.scrollTop = 0;
            element.scrollLeft = 0;
            //element.style.overflow = "hidden";
            element.classList.add("haxeui-component");
            elementToComponent.set(element, cast(this, Component));
            return;
        }

        var newElement = Browser.document.createDivElement();
        newElement.classList.add("haxeui-component");

        if ((this is Image)) {
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

        remapEvents();
    }

    private function remapEvents() {
        if (_eventMap == null) {
            return;
        }
        var copy:Map<String, UIEvent->Void> = new Map<String, UIEvent->Void>();
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

    private override function handlePosition(left:Null<Float>, top:Null<Float>, style:Style) {
        if (element == null) {
            return;
        }

        if (left != null) {
            element.style.left = HtmlUtils.px(left);
        }
        if (top != null) {
            element.style.top = HtmlUtils.px(top);
        }
    }

    private override function handleSize(width:Null<Float>, height:Null<Float>, style:Style) {
        if (width == null || height == null || width <= 0 || height <= 0) {
            return;
        }

        if (this.element == null) {
            return;
        }

        var c:Component = cast(this, Component);
        var css:CSSStyleDeclaration = element.style;
        StyleHelper.apply(this, width, height, style);
        var parent:ComponentImpl = c.parentComponent;
        if (parent != null && parent.element.style.borderWidth != null) {
            css.marginTop = '-${parent.element.style.borderWidth}';
            css.marginLeft = '-${parent.element.style.borderWidth}';
        } else if (parent != null) {
            css.marginTop = '';
            css.marginLeft = '';
        }

        for (child in cast(this, Component).childComponents) {
            if (style.borderLeftSize != null && style.borderLeftSize > 0) {
                child.element.style.marginLeft = '-${style.borderLeftSize}px';
            } else {
                child.element.style.marginLeft = '';
            }
            if (style.borderTopSize != null && style.borderTopSize > 0) {
                child.element.style.marginTop = '-${style.borderTopSize}px';
            } else {
                child.element.style.marginTop = '';
            }
        }
    }

    private override function handleReady() {
        if (cast(this, Component).id != null) {
            element.id = cast(this, Component).id;
        }
    }

    private override function handleFrameworkProperty(id:String, value:Any) {
        switch (id) {
            case "allowMouseInteraction":
                if (value == true && element.style.getPropertyValue("pointer-events") != null) {
                    element.style.removeProperty("pointer-events");
                } else if (element.style.getPropertyValue("pointer-events") != "none") {
                    element.style.setProperty("pointer-events", "none");
                    setCursor(null);
                }
        }
    }
    
    private override function handleClipRect(value:Rectangle) {
        var c:Component = cast(this, Component);
        var parent:Component = c.parentComponent;
        if (value != null && parent != null) {
            element.style.clip = 'rect(${HtmlUtils.px(value.top)},${HtmlUtils.px(value.right - 1)},${HtmlUtils.px(value.bottom)},${HtmlUtils.px(value.left)})';
            element.style.left = '${HtmlUtils.px(Std.int(c.left - value.left))}';
            element.style.top = '${HtmlUtils.px(Std.int(c.top - value.top))}';
        } else {
            element.style.removeProperty("clip");
        }
    }

    private override function handleVisibility(show:Bool) {
        element.style.display = (show == true) ? "" : "none";
    }

    //***********************************************************************************************************
    // Text related
    //***********************************************************************************************************
    public override function createTextDisplay(text:String = null):TextDisplay {
        if (_textDisplay == null) {
            super.createTextDisplay(text);
            element.appendChild(_textDisplay.element);
        }
        
        return _textDisplay;
    }

    public override function createTextInput(text:String = null):TextInput {
        if (_textInput == null) {
            super.createTextInput(text);
            element.appendChild(_textInput.element);
        }
        return _textInput;
    }

    //***********************************************************************************************************
    // Image related
    //***********************************************************************************************************
    public override function createImageDisplay():ImageDisplay {
        if (_imageDisplay == null) {
            super.createImageDisplay();
            element.appendChild(_imageDisplay.element);
        }
        return _imageDisplay;
    }

    private override function handleSetComponentIndex(child:Component, index:Int) {
        if (index == this.childComponents.length - 1) {
            element.appendChild(child.element);
        } else {
            if (index == this.childComponents.indexOf(child) - 1) {
                var before = this.childComponents[index];
                HtmlUtils.insertBefore(before.element, child.element);
            } else {
                var before = this.childComponents[index + 1];
                HtmlUtils.insertBefore(before.element, child.element);
            }
        }
    }

    //***********************************************************************************************************
    // Display tree
    //***********************************************************************************************************
    private override function handleAddComponent(child:Component):Component {
        element.appendChild(child.element);
        return child;
    }

    private override function handleAddComponentAt(child:Component, index:Int):Component {
        handleAddComponent(child);
        handleSetComponentIndex(child, index);
        return child;
    }

    private override function handleRemoveComponent(child:Component, dispose:Bool = true):Component {
        HtmlUtils.removeElement(child.element);
        return child;
    }

    private override function handleRemoveComponentAt(index:Int, dispose:Bool = true):Component {
        var child = cast(this, Component)._children[index];
        HtmlUtils.removeElement(child.element);
        return child;
    }

    private override function applyStyle(style:Style) {
        if (element == null) {
            return;
        }

        setCursor(style.cursor);

        if (style.filter != null) {
            if ((style.filter[0] is DropShadow)) {
                var dropShadow:DropShadow = cast style.filter[0];
                if (dropShadow.inner == false) {
                    element.style.boxShadow = '${dropShadow.distance}px ${dropShadow.distance + 2}px ${dropShadow.blurX - 1}px ${dropShadow.blurY - 1}px ${HtmlUtils.rgba(dropShadow.color, dropShadow.alpha)}';
                } else {
                    element.style.boxShadow = 'inset ${dropShadow.distance}px ${dropShadow.distance}px ${dropShadow.blurX}px 0px ${HtmlUtils.rgba(dropShadow.color, dropShadow.alpha)}';
                }
            } else if ((style.filter[0] is Blur)) {
                var blur:Blur = cast style.filter[0];
                element.style.setProperty("-webkit-filter", 'blur(${blur.amount}px)');
                element.style.setProperty("-moz-filter", 'blur(${blur.amount}px)');
                element.style.setProperty("-o-filter", 'blur(${blur.amount}px)');
                //element.style.setProperty("-ms-filter", 'blur(${blur.amount}px)');
                element.style.setProperty("filter", 'blur(${blur.amount}px)');
            } else if ((style.filter[0] is Grayscale)) {
                var grayscale:Grayscale = cast style.filter[0];
                element.style.setProperty("-webkit-filter", 'grayscale(${grayscale.amount}%)');
                element.style.setProperty("-moz-filter", 'grayscale(${grayscale.amount}%)');
                element.style.setProperty("-o-filter", 'grayscale(${grayscale.amount}%)');
                element.style.setProperty("filter", 'grayscale(${grayscale.amount}%)');
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

        if (style.backdropFilter != null) {
            if ((style.backdropFilter[0] is Blur)) {
                var blur:Blur = cast style.backdropFilter[0];
                element.style.setProperty("backdrop-filter", 'blur(${blur.amount}px)');
            }
        } else {
            element.style.removeProperty("backdrop-filter");
        }
        
        if (style.opacity != null) {
            element.style.opacity = '${style.opacity}';
        }

        if (style.fontName != null) {
            element.style.fontFamily = style.fontName;
        }

        if (style.fontSize != null) {
            element.style.fontSize = HtmlUtils.px(style.fontSize);
        }
        
        if (style.color != null) {
            element.style.color = HtmlUtils.color(style.color);
        }
        
        if (hasImageDisplay()) {
            _imageDisplay.applyStyle();
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

    @:noCompletion private var _canvas:CanvasElement = null;
    private function getCanvas(width:Float, height:Float) {
        if (_canvas == null) {
            _canvas = Browser.document.createCanvasElement();
            _canvas.style.setProperty("-webkit-backface-visibility", "hidden");
            _canvas.style.setProperty("-moz-backface-visibility", "hidden");
            _canvas.style.setProperty("-ms-backface-visibility", "hidden");
            _canvas.style.position = "absolute";
            _canvas.style.setProperty("pointer-events", "none");
            _canvas.width = cast width;
            _canvas.height = cast height;
            element.insertBefore(_canvas, element.firstChild);
        }
        if (width != _canvas.width) {
            _canvas.width = cast width;
        }
        if (height != _canvas.height) {
            _canvas.height = cast height;
        }
        return _canvas;
    }
    
    private function hasCanvas() {
        return (_canvas != null);
    }
    
    private function removeCanvas() {
        if (_canvas != null && element.contains(_canvas)) {
            element.removeChild(_canvas);
            _canvas = null;
        }
    }
    
    //***********************************************************************************************************
    // Events
    //***********************************************************************************************************
    private override function mapEvent(type:String, listener:UIEvent->Void) {
        switch (type) {
            case MouseEvent.MOUSE_MOVE | MouseEvent.MOUSE_OVER | MouseEvent.MOUSE_OUT |
                MouseEvent.MOUSE_DOWN | MouseEvent.MOUSE_UP | MouseEvent.CLICK | MouseEvent.DBL_CLICK:
                if (_eventMap.exists(type) == false) {
                    #if !haxeui_notouch
                    if (EventMapper.MOUSE_TO_TOUCH.get(type) != null) {
                        element.addEventListener(EventMapper.MOUSE_TO_TOUCH.get(type), __onMouseEvent);
                    }
                    #end
                    
                    _eventMap.set(type, listener);
                    element.addEventListener(EventMapper.HAXEUI_TO_DOM.get(type), __onMouseEvent);
                }
            case MouseEvent.RIGHT_CLICK:    
                if (_eventMap.exists(type) == false) {
                    _eventMap.set(type, listener);
                    element.addEventListener("contextmenu", __onContextMenu);
                }
            case MouseEvent.MOUSE_WHEEL:
                _eventMap.set(type, listener);
                if (UserAgent.instance.firefox == true) {
                    element.addEventListener("DOMMouseScroll", __onMouseWheelEvent);
                } else {
                    element.addEventListener("mousewheel", __onMouseWheelEvent);
                }
			case KeyboardEvent.KEY_DOWN | KeyboardEvent.KEY_UP:
				if (_eventMap.exists(type) == false) {
					_eventMap.set(type, listener);
					element.addEventListener(EventMapper.HAXEUI_TO_DOM.get(type), __onKeyboardEvent);
				}
            case UIEvent.CHANGE:
                if (_eventMap.exists(type) == false) {
                    if (hasTextInput() == true) {
                        _eventMap.set(type, listener);
                        getTextInput().element.addEventListener(EventMapper.HAXEUI_TO_DOM.get(KeyboardEvent.KEY_UP), __onTextFieldChangeEvent);
                    }
                }
            case ScrollEvent.CHANGE:
                _eventMap.set(type, listener);
                element.addEventListener("scroll", __onScrollEvent);
        }
    }

    private override function unmapEvent(type:String, listener:UIEvent->Void) {
        switch (type) {
            case MouseEvent.MOUSE_MOVE | MouseEvent.MOUSE_OVER | MouseEvent.MOUSE_OUT |
                MouseEvent.MOUSE_DOWN | MouseEvent.MOUSE_UP | MouseEvent.CLICK | MouseEvent.DBL_CLICK:
                _eventMap.remove(type);
                element.removeEventListener(EventMapper.HAXEUI_TO_DOM.get(type), __onMouseEvent);
                #if !haxeui_notouch
                if (EventMapper.MOUSE_TO_TOUCH.get(type) != null) {
                    element.removeEventListener(EventMapper.MOUSE_TO_TOUCH.get(type), __onMouseEvent);
                }
                #end
            case MouseEvent.RIGHT_CLICK:    
                _eventMap.remove(type);
                element.removeEventListener("contextmenu", __onContextMenu);
            case MouseEvent.MOUSE_WHEEL:
                _eventMap.remove(type);
                if (UserAgent.instance.firefox == true) {
                    element.removeEventListener("DOMMouseScroll", __onMouseWheelEvent);
                } else {
                    element.removeEventListener("mousewheel", __onMouseWheelEvent);
                }
			case KeyboardEvent.KEY_DOWN | KeyboardEvent.KEY_UP:
				_eventMap.remove(type);
                element.removeEventListener(EventMapper.HAXEUI_TO_DOM.get(type), __onKeyboardEvent);
            case UIEvent.CHANGE:
                if (hasTextInput()) {
                    _eventMap.remove(type);
                    getTextInput().element.removeEventListener(EventMapper.HAXEUI_TO_DOM.get(KeyboardEvent.KEY_UP), __onTextFieldChangeEvent);
                }
        }
    }

    //***********************************************************************************************************
    // Event Handlers
    //***********************************************************************************************************
    @:noCompletion 
    private function __onContextMenu(event:js.html.UIEvent) {
        event.preventDefault();
        var type:String = MouseEvent.RIGHT_CLICK;
        if (type != null) {
            var fn = _eventMap.get(type);
            if (fn != null) {
                var uiEvent = new MouseEvent(type);
                uiEvent.screenX = event.pageX;
                uiEvent.screenY = event.pageY;
                fn(uiEvent);
            }
        }
        return false;
    }
    
    @:noCompletion 
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

	@:noCompletion 
    private function __onTextFieldChangeEvent(event:js.html.UIEvent) {
        var fn = _eventMap.get(UIEvent.CHANGE);
        if (fn != null) {
            var uiEvent = new UIEvent(UIEvent.CHANGE);
            fn(uiEvent);
        }
    }

	@:noCompletion 
    @:access(haxe.ui.core.Screen)
    private function __onMouseEvent(event:js.html.Event) {
        // TODO: conditionally implement: https://developer.mozilla.org/en-US/docs/Web/API/Element/setPointerCapture
        // especially for scrolls
        var type:String = EventMapper.DOM_TO_HAXEUI.get(event.type);
        if (type != null) {
            try { // set/releaseCapture isnt currently supported in chrome
                if (type == MouseEvent.MOUSE_DOWN) {
                    //element.setCapture();
                } else if (type == MouseEvent.MOUSE_UP) {
                    //element.releaseCapture();
                }
            } catch (e:Dynamic) {
            }

            var fn = _eventMap.get(type);
            if (fn != null) {
                var mouseEvent = new MouseEvent(type);
                mouseEvent._originalEvent = event;
                var touchEvent = false;
                try {
                    touchEvent = (event is js.html.TouchEvent);
                } catch (e:Dynamic) { }
                
                if (touchEvent == true) {
                    var te:js.html.TouchEvent = cast(event, js.html.TouchEvent);
                    mouseEvent.screenX = (te.changedTouches[0].pageX - Screen.instance.container.offsetLeft) / Toolkit.scaleX;
                    mouseEvent.screenY = (te.changedTouches[0].pageY - Screen.instance.container.offsetTop) / Toolkit.scaleY;
                    mouseEvent.touchEvent = true;
                } else if ((event is js.html.MouseEvent)) {
                    var me:js.html.MouseEvent = cast(event, js.html.MouseEvent);
                    mouseEvent.buttonDown = (me.buttons != 0);
                    mouseEvent.screenX = (me.pageX - Screen.instance.container.offsetLeft) / Toolkit.scaleX;
                    mouseEvent.screenY = (me.pageY - Screen.instance.container.offsetTop) / Toolkit.scaleY;
                    mouseEvent.ctrlKey = me.ctrlKey;
                    mouseEvent.shiftKey = me.shiftKey;
                }
                
                fn(mouseEvent);
            }
        }
    }

    @:access(haxe.ui.core.Screen)
    private override function getComponentOffset():Point {
        return new Point(0, 0);
        // ill concieved?
        //return new Point(Screen.instance.pageRoot(element).offsetLeft, Screen.instance.pageRoot(element).offsetTop);
    }
    
    @:noCompletion 
    @:access(haxe.ui.core.Screen)
    private function __onMouseWheelEvent(event:js.html.MouseEvent) {
        var fn = _eventMap.get(MouseEvent.MOUSE_WHEEL);
        if (fn == null) {
            return;
        }

        var delta:Float = 0;
        if (Reflect.field(event, "wheelDelta") != null) {
            delta = Reflect.field(event, "wheelDelta");
        } else if ((event is WheelEvent)) {
            delta = cast(event, WheelEvent).deltaY;
        } else {
            delta = -event.detail;
        }

        delta = Math.max(-1, Math.min(1, delta));

        var mouseEvent = new MouseEvent(MouseEvent.MOUSE_WHEEL);
        mouseEvent._originalEvent = event;
        mouseEvent.screenX = (event.pageX - Screen.instance.container.offsetLeft) / Toolkit.scaleX;
        mouseEvent.screenY = (event.pageY - Screen.instance.container.offsetTop) / Toolkit.scaleY;
        mouseEvent.ctrlKey = event.ctrlKey;
        mouseEvent.shiftKey = event.shiftKey;
        mouseEvent.delta = delta;
        fn(mouseEvent);
    }
	
	@:noCompletion 
	private function __onKeyboardEvent(event:js.html.Event) {
		var type:String = EventMapper.DOM_TO_HAXEUI.get(event.type);
        if (type != null) {
            var fn = _eventMap.get(type);
            if (fn != null) {
                var keyboardEvent = new KeyboardEvent(type);
                keyboardEvent._originalEvent = event;
                
                if ((event is js.html.KeyboardEvent)) {
                    var me:js.html.KeyboardEvent = cast(event, js.html.KeyboardEvent);
					keyboardEvent.keyCode = me.keyCode;
					keyboardEvent.altKey = me.altKey;
					keyboardEvent.ctrlKey = me.ctrlKey;
					keyboardEvent.shiftKey = me.shiftKey;
                }
                
                fn(keyboardEvent);
            }
        }
	}
    
    @:noCompletion 
    private function __onScrollEvent(event:js.html.MouseScrollEvent) {
        var type:String = EventMapper.DOM_TO_HAXEUI.get(event.type);
        var fn = _eventMap.get(type);
        if (fn != null) {
            var scrollEvent:ScrollEvent = new ScrollEvent(ScrollEvent.CHANGE);
            fn(scrollEvent);
        }
    }
}