package haxe.ui.backend;

import haxe.ui.Toolkit;
import haxe.ui.backend.html5.EventMapper;
import haxe.ui.backend.html5.HtmlUtils;
import haxe.ui.backend.html5.UserAgent;
import haxe.ui.backend.html5.util.StyleSheetHelper;
import haxe.ui.core.Component;
import haxe.ui.core.Screen;
import haxe.ui.events.KeyboardEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import js.Browser;
import js.html.CSSStyleSheet;
import js.html.Element;
import js.html.TouchEvent;

using StringTools;

class ScreenImpl extends ScreenBase {
    private var _mapping:Map<String, UIEvent->Void>;

    public function new() {
        _mapping = new Map<String, UIEvent->Void>();
        /* might need this later
        Browser.document.body.addEventListener("mousedown", function(e) {
            e.stopPropagation();
            e.preventDefault();
            return false;
        });
        Browser.document.body.addEventListener("contextmenu", function(e) {
            e.stopPropagation();
            e.preventDefault();
            return false;
        });
        */
    }

    private override function set_options(value:ToolkitOptions):ToolkitOptions {
        super.set_options(value);
        var cx:String = Toolkit.backendProperties.getProp("haxe.ui.html5.container.width", null);
        var cy:String = Toolkit.backendProperties.getProp("haxe.ui.html5.container.height", null);
        var c = container;
        if (cx != null) {
            c.style.width = cx;
        }
        if (cy != null) {
            c.style.height = cy;
        }
        return value;
    }

    private override function get_dpi():Float {
        return HtmlUtils.dpi;
    }

    private override function get_title():String {
        return js.Browser.document.title;
    }
    private override function set_title(s:String):String {
        js.Browser.document.title = s;
        return s;
    }
    
    private var _width:Null<Float> = null;
    private override function get_width():Float {
        if (_width != null && _width > 0) {
            return _width;
        }
        var cx:Float = container.offsetWidth;
        if (cx <= 0) {
            for (c in rootComponents) {
                if (c.width > cx) {
                    cx = c.width;
                }
            }
        }
        _width = cx / Toolkit.scaleX;
        return _width;
    }

    private var _height:Null<Float> = null;
    private override function get_height():Float {
        if (_height != null && _height > 0) {
            return _height;
        }
        var cy:Float = container.offsetHeight;
        if (cy <= 0) {
            for (c in rootComponents) {
                if (c.height > cy) {
                    cy = c.height;
                }
            }
        }
        _height = cy / Toolkit.scaleY;
        return _height;
    }

    private override function get_isRetina():Bool {
        return HtmlUtils.isRetinaDisplay();
    }
    
    public override function addComponent(component:Component):Component {
        container.appendChild(component.element);
        component.ready();

        if (Toolkit.scaleX != 1 || Toolkit.scaleY != 1) {
            var transformString = '';
            if (Toolkit.scaleX != 1) {
                transformString += 'scaleX(${Toolkit.scaleX}) ';
            }
            if (Toolkit.scaleY != 1) {
                transformString += 'scaleY(${Toolkit.scaleY}) ';
            }
            component.element.style.transform = transformString;
            component.element.style.transformOrigin = "top left";
        }

        if (component.percentWidth != null) {
            addPercentContainerWidth();
        }
        if (component.percentHeight != null) {
            addPercentContainerHeight();
        }
        addResizeListener();
        resizeComponent(component);
        #if haxeui_html5_set_zindex
        component.element.style.zIndex = "10000";
        #end
        return component;
    }

    private var _percentContainerWidthAdded:Bool = false;
    private function addPercentContainerWidth() {
        if (_percentContainerWidthAdded == true) {
            return;
        }
        _percentContainerWidthAdded = true;
        
        var sheet:CSSStyleSheet = StyleSheetHelper.getValidStyleSheet();
        
        var w = containerParent.getAttribute("width");
        if (w == null) {
            w = "";
        }
        w = w.trim();
        
        if (!w.endsWith("%") && !w.endsWith("px")) {
            sheet.insertRule("#haxeui-container-parent {
                margin: 0;
                width: 100%;
            }", sheet.cssRules.length);
        }
        sheet.insertRule("#haxeui-container {
            margin: 0;
            width: 100%;
        }", sheet.cssRules.length);
    }
    
    private var _percentContainerHeightAdded:Bool = false;
    private function addPercentContainerHeight() {
        if (_percentContainerHeightAdded == true) {
            return;
        }
        _percentContainerHeightAdded = true;
        
        var sheet:CSSStyleSheet = StyleSheetHelper.getValidStyleSheet();
        
        var h = containerParent.getAttribute("height");
        if (h == null) {
            h = "";
        }
        h = h.trim();
        
        if (!h.endsWith("%") && !h.endsWith("px")) {
            sheet.insertRule("#haxeui-container-parent {
                margin: 0;
                height: 100%;
            }", sheet.cssRules.length);
        }
        sheet.insertRule("#haxeui-container {
            margin: 0;
            height: 100%;
        }", sheet.cssRules.length);
    }
    
    public override function removeComponent(component:Component, dispose:Bool = true):Component {
        rootComponents.remove(component);
        if (container.contains(component.element) == true) {
            container.removeChild(component.element);
        }
        return component;
    }

    private override function handleSetComponentIndex(child:Component, index:Int) {
        if (index == cast(this, Screen).rootComponents.length - 1) {
            container.appendChild(child.element);
        } else {
            HtmlUtils.insertBefore(cast(this, Screen).rootComponents[index + 1].element, child.element);
        }
    }

    private var _container:Element = null;
    private var container(get, null):Element;
    private function get_container():Element {
        if (_container != null) {
            return _container;
        }
        var c : Element = null;
        if (options == null || options.container == null) {
            c = Browser.document.body;
        } else {
            c = options.container;
        }
        if (c.style.overflow == null || c.style.overflow == "") {
            c.style.overflow = "hidden";
        }
        if (c.id != "haxeui-container") {
            c.id = "haxeui-container";
            if (options != null && options.container != null) {
                c.style.position = "relative";
            }
            if (c.parentElement != null && c.parentElement.id != "haxeui-container-parent") {
                c.parentElement.id = "haxeui-container-parent";
            }
        }
        _container = c;
        return c;
    }

    var _pageRoot:Element = null;
    private function pageRoot(from:Element):Element {
        if (_pageRoot != null) {
            return _pageRoot;
        }
        
        var r = null;
        var el = from;
        while (el != null) {
            if (el.classList.contains("haxeui-component") == false) {
                r = el;
                _pageRoot = el;
                break;
            }
            el = el.parentElement;
        }
        return r;
    }
    
    private var _containerParent:Element = null;
    private var containerParent(get, null):Element;
    private function get_containerParent():Element {
        if (_containerParent != null) {
            return _containerParent;
        }
        
        var c = container;
        if (c != null) {
            _containerParent = c.parentElement;
        }
        
        return _containerParent;
    }
    
    
    private var _hasListener:Bool = false;
    private function addResizeListener() {
        if (_hasListener == true) {
            return;
        }

        _hasListener = true;
        Browser.window.addEventListener("load", onFullyLoaded);
        if (container == Browser.document.body) {
            Browser.window.addEventListener("resize", function(e) {
                containerResized();
            });
        } else { // haxeui app is in a container html element, lets use mutation observer to listen for size changes 
            var observer = resizeObserver(onElementResized);
            if (observer != null) {
                observer.observe(container);
            }
        }
    }

    private function onElementResized(entries:Array<Dynamic>) {
        containerResized();
    }

    private function resizeObserver(cb:Array<Dynamic>->Void):Dynamic {
        var ro:Dynamic = null;
        try {
            #if (haxe_ver > 4.1) 
            ro = js.Syntax.code("ResizeObserver");
            #else
            ro = untyped __js__("ResizeObserver");
            #end
        } catch(e:Dynamic) {
            return null;
        }

        if (ro == null) {
            return null;
        }

        #if (haxe_ver > 4.1) 
        return js.Syntax.code("new ResizeObserver({0})", cb);
        #else
        return untyped __js__("new ResizeObserver({0})", cb);
        #end
    }

    private function onFullyLoaded() {
        Browser.window.removeEventListener("load", onFullyLoaded);
        containerResized();
    }

    private function containerResized() {
        _width = null;
        _height = null;
        resizeRootComponents();
        if (_mapping.exists(UIEvent.RESIZE)) {
            var event = new UIEvent(UIEvent.RESIZE);
            var fn = _mapping.get(UIEvent.RESIZE);
            if (fn != null) {
                fn(event);
            }
        }
    }

    //***********************************************************************************************************
    // Events
    //***********************************************************************************************************
    private override function supportsEvent(type:String):Bool {
        return (type == UIEvent.RESIZE) || EventMapper.HAXEUI_TO_DOM.get(type) != null;
    }

    private override function mapEvent(type:String, listener:UIEvent->Void) {
        var container = Browser.document.body;
        
        switch (type) {
            case MouseEvent.MOUSE_MOVE | MouseEvent.MOUSE_OVER | MouseEvent.MOUSE_OUT |
                MouseEvent.MOUSE_DOWN | MouseEvent.MOUSE_UP | MouseEvent.CLICK | MouseEvent.DBL_CLICK |
                MouseEvent.RIGHT_MOUSE_DOWN | MouseEvent.RIGHT_MOUSE_UP | MouseEvent.RIGHT_CLICK:

                // chrome sends a spurious mouse move event even if the mouse hasnt moved, lets consume that first
                /* not sure this is still needed 
                if (type == MouseEvent.MOUSE_MOVE && _mapping.exists(type) == false && UserAgent.instance.chrome == true) {
                    var fn = null;
                    fn = function(e) {
                        container.removeEventListener(EventMapper.HAXEUI_TO_DOM.get(MouseEvent.MOUSE_MOVE), fn);
                        if (EventMapper.MOUSE_TO_TOUCH.get(type) != null) {
                            container.removeEventListener(EventMapper.MOUSE_TO_TOUCH.get(type), fn);
                        }

                        if (_mapping.exists(type) == false) {
                            if (EventMapper.MOUSE_TO_TOUCH.get(type) != null) {
                                HtmlUtils.addEventListener(container, EventMapper.MOUSE_TO_TOUCH.get(type), __onMouseEvent, false);
                            }

                            _mapping.set(type, listener);
                            HtmlUtils.addEventListener(container, EventMapper.HAXEUI_TO_DOM.get(MouseEvent.MOUSE_MOVE), __onMouseEvent, false);
                        }
                    }

                    //container.addEventListener(EventMapper.HAXEUI_TO_DOM.get(MouseEvent.MOUSE_MOVE), fn, {passive: false});
                    HtmlUtils.addEventListener(container, EventMapper.HAXEUI_TO_DOM.get(MouseEvent.MOUSE_MOVE), fn, false);
                    if (EventMapper.MOUSE_TO_TOUCH.get(type) != null) {
                        HtmlUtils.addEventListener(container, EventMapper.MOUSE_TO_TOUCH.get(type), fn, false);
                    }
                    return;
                }
                */

                if (_mapping.exists(type) == false) {
                    if (EventMapper.MOUSE_TO_TOUCH.get(type) != null) {
                        HtmlUtils.addEventListener(container, EventMapper.MOUSE_TO_TOUCH.get(type), __onMouseEvent, false);
                    }

                    _mapping.set(type, listener);
                    HtmlUtils.addEventListener(container, EventMapper.HAXEUI_TO_DOM.get(type), __onMouseEvent, false);
                }
                if (type == MouseEvent.RIGHT_MOUSE_DOWN || type == MouseEvent.RIGHT_MOUSE_UP) {
                    disableContextMenu(true);
                }

            case KeyboardEvent.KEY_DOWN | KeyboardEvent.KEY_UP:
                if (_mapping.exists(type) == false) {
                    _mapping.set(type, listener);
                    container.addEventListener(EventMapper.HAXEUI_TO_DOM.get(type), __onKeyEvent);
                }
                
            case UIEvent.RESIZE:
                if (_mapping.exists(type) == false) {
                    _mapping.set(type, listener);
                }
        }
    }

    private override function unmapEvent(type:String, listener:UIEvent->Void) {
        var container = Browser.document.body;
        
        switch (type) {
            case MouseEvent.MOUSE_MOVE | MouseEvent.MOUSE_OVER | MouseEvent.MOUSE_OUT |
                MouseEvent.MOUSE_DOWN | MouseEvent.MOUSE_UP | MouseEvent.CLICK | MouseEvent.DBL_CLICK |
                MouseEvent.RIGHT_MOUSE_DOWN | MouseEvent.RIGHT_MOUSE_UP | MouseEvent.RIGHT_CLICK:
                _mapping.remove(type);
                container.removeEventListener(EventMapper.HAXEUI_TO_DOM.get(type), __onMouseEvent);
                if (EventMapper.MOUSE_TO_TOUCH.get(type) != null) {
                    container.removeEventListener(EventMapper.MOUSE_TO_TOUCH.get(type), __onMouseEvent);
                }
                if (type == MouseEvent.RIGHT_MOUSE_DOWN || type == MouseEvent.RIGHT_MOUSE_UP) {
                    disableContextMenu(false);
                }

            case KeyboardEvent.KEY_DOWN | KeyboardEvent.KEY_UP:
                _mapping.remove(type);
                container.removeEventListener(EventMapper.HAXEUI_TO_DOM.get(type), __onKeyEvent);
                
            case UIEvent.RESIZE:
                _mapping.remove(type);
        }
    }

    //***********************************************************************************************************
    // Event Handlers
    //***********************************************************************************************************
    private function __onMouseEvent(event:js.html.Event) {
        //event.preventDefault();

        var button:Int = -1;
        // var touchEvent = false;
        // try {
        //     touchEvent = (event is js.html.TouchEvent);
        // } catch (e:Dynamic) { }
        // if (touchEvent == false && (event is js.html.MouseEvent)) {
            var me:js.html.PointerEvent = cast(event, js.html.PointerEvent);
            button = me.which;
        // }
        
        var r = true;
        var type:String = EventMapper.DOM_TO_HAXEUI.get(event.type);
        if (type == MouseEvent.RIGHT_CLICK) {
            event.stopPropagation();
            event.preventDefault();
            r = false;
        }
        if (event.type == "pointerdown") { // handle right button mouse events better
            var which:Int = Reflect.field(event, "which");
            switch (which) {
                case 1: type = MouseEvent.MOUSE_DOWN;
                case 2: type = MouseEvent.MOUSE_DOWN; // should be mouse middle, but there is no haxe equiv (yet);
                case 3: type = MouseEvent.RIGHT_MOUSE_DOWN;
            }
        } else if (event.type == "pointerup") { // handle right button mouse events better
            var which:Int = Reflect.field(event, "which");
            switch (which) {
                case 1: type = MouseEvent.MOUSE_UP;
                case 2: type = MouseEvent.MOUSE_UP; // should be mouse middle, but there is no haxe equiv (yet);
                case 3: type = MouseEvent.RIGHT_MOUSE_UP;
            }
        }

        
        if (type != null) {
            var fn = _mapping.get(type);
            if (fn != null) {
                var mouseEvent = new MouseEvent(type);
                mouseEvent._originalEvent = event;

                // if (touchEvent == true) {
                //     var te:js.html.TouchEvent = cast(event, js.html.TouchEvent);
                //     mouseEvent.screenX = (te.changedTouches[0].pageX - Screen.instance.container.offsetLeft) / Toolkit.scaleX;
                //     mouseEvent.screenY = (te.changedTouches[0].pageY - Screen.instance.container.offsetTop) / Toolkit.scaleY;
                //     mouseEvent.touchEvent = true;
                // } else if ((event is js.html.MouseEvent)) {
                if ((event is js.html.PointerEvent)) {
                    var pe:js.html.PointerEvent = cast(event, js.html.PointerEvent);
                    mouseEvent.buttonDown = (pe.buttons != 0);
                    mouseEvent.screenX = (pe.pageX - Screen.instance.container.offsetLeft) / Toolkit.scaleX;
                    mouseEvent.screenY = (pe.pageY - Screen.instance.container.offsetTop) / Toolkit.scaleY;
                    mouseEvent.ctrlKey = pe.ctrlKey;
                    mouseEvent.shiftKey = pe.shiftKey;
                }

                fn(mouseEvent);
            }
        }
        
        return r;
    }

    private function __onKeyEvent(event:js.html.KeyboardEvent) {
        var type:String = EventMapper.DOM_TO_HAXEUI.get(event.type);
        if (type != null) {
            if (event.keyCode == 9 || event.which == 9) {
                event.preventDefault();
                event.stopImmediatePropagation();
                event.stopPropagation();
            }
            var fn = _mapping.get(type);
            if (fn != null) {
                var keyboardEvent = new KeyboardEvent(type);
                keyboardEvent._originalEvent = event;
                keyboardEvent.keyCode = event.keyCode;
                keyboardEvent.ctrlKey = event.ctrlKey;
                keyboardEvent.shiftKey = event.shiftKey;
                fn(keyboardEvent);
            }
        }
    }

    private var _contextMenuDisabledCount:Int = 0;
    private function disableContextMenu(disable:Bool) {
        var container = Browser.document.body;

        if (disable == true) {
            _contextMenuDisabledCount++;
        } else {
            _contextMenuDisabledCount--;
            if (_contextMenuDisabledCount < 0) {
                _contextMenuDisabledCount = 0;
            }
        }

        if (_contextMenuDisabledCount == 1) {
            container.addEventListener("contextmenu", __preventContextMenu);
        } else if (_contextMenuDisabledCount == 0) {
            container.removeEventListener("contextmenu", __preventContextMenu);
        }
    }

    @:noCompletion 
    private function __preventContextMenu(event:js.html.UIEvent) {
        event.preventDefault();
        return false;
    }
}
