package haxe.ui.backend;

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
    
    private override function get_width():Float {
        var cx:Float = container.offsetWidth;
        if (cx <= 0) {
            for (c in _topLevelComponents) {
                if (c.width > cx) {
                    cx = c.width;
                }
            }
        }
        return cx;
    }

    private override function get_height():Float {
        var cy:Float = container.offsetHeight;
        if (cy <= 0) {
            for (c in _topLevelComponents) {
                if (c.height > cy) {
                    cy = c.height;
                }
            }
        }
        return cy;
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

        _topLevelComponents.push(component);
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
        sheet.insertRule("#haxeui-container-parent {
            margin: 0;
            width: 100%;
        }", sheet.cssRules.length);
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
        sheet.insertRule("#haxeui-container-parent {
            margin: 0;
            height: 100%;
        }", sheet.cssRules.length);
        sheet.insertRule("#haxeui-container {
            margin: 0;
            height: 100%;
        }", sheet.cssRules.length);
    }
    
    public override function removeComponent(component:Component):Component {
        _topLevelComponents.remove(component);
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

    private var container(get, null):Element;
    private function get_container():Element {
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
            if (c.parentElement != null && c.parentElement.id != "haxeui-container-parent") {
                c.parentElement.id = "haxeui-container-parent";
            }
        }
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
    
    private var _hasListener:Bool = false;
    private function addResizeListener() {
        if (_hasListener == true) {
            return;
        }

        _hasListener = true;
        Browser.window.addEventListener("resize", function(e) {
           for (c in _topLevelComponents) {
               resizeComponent(c);
           }
        });

    }

    //***********************************************************************************************************
    // Events
    //***********************************************************************************************************
    private override function supportsEvent(type:String):Bool {
        return EventMapper.HAXEUI_TO_DOM.get(type) != null;
    }

    private override function mapEvent(type:String, listener:UIEvent->Void) {
        var container = Browser.document.body;
        
        switch (type) {
            case MouseEvent.MOUSE_MOVE | MouseEvent.MOUSE_OVER | MouseEvent.MOUSE_OUT |
                MouseEvent.MOUSE_DOWN | MouseEvent.MOUSE_UP | MouseEvent.CLICK | MouseEvent.DBL_CLICK:

                // chrome sends a spurious mouse move event even if the mouse hasnt moved, lets consume that first
                if (type == MouseEvent.MOUSE_MOVE && _mapping.exists(type) == false && UserAgent.instance.chrome == true) {
                    var fn = null;
                    fn = function(e) {
                        container.removeEventListener(EventMapper.HAXEUI_TO_DOM.get(MouseEvent.MOUSE_MOVE), fn);
                        if (EventMapper.MOUSE_TO_TOUCH.get(type) != null) {
                            container.removeEventListener(EventMapper.MOUSE_TO_TOUCH.get(type), fn);
                        }

                        if (_mapping.exists(type) == false) {
                            if (EventMapper.MOUSE_TO_TOUCH.get(type) != null) {
                                container.addEventListener(EventMapper.MOUSE_TO_TOUCH.get(type), __onMouseEvent);
                            }

                            _mapping.set(type, listener);
                            container.addEventListener(EventMapper.HAXEUI_TO_DOM.get(MouseEvent.MOUSE_MOVE), __onMouseEvent);
                        }
                    }

                    container.addEventListener(EventMapper.HAXEUI_TO_DOM.get(MouseEvent.MOUSE_MOVE), fn);
                    if (EventMapper.MOUSE_TO_TOUCH.get(type) != null) {
                        container.addEventListener(EventMapper.MOUSE_TO_TOUCH.get(type), fn);
                    }
                    return;
                }

                if (_mapping.exists(type) == false) {
                    if (EventMapper.MOUSE_TO_TOUCH.get(type) != null) {
                        container.addEventListener(EventMapper.MOUSE_TO_TOUCH.get(type), __onMouseEvent);
                    }

                    _mapping.set(type, listener);
                    container.addEventListener(EventMapper.HAXEUI_TO_DOM.get(type), __onMouseEvent);
                }

            case KeyboardEvent.KEY_DOWN | KeyboardEvent.KEY_UP:
                if (_mapping.exists(type) == false) {
                    _mapping.set(type, listener);
                    container.addEventListener(EventMapper.HAXEUI_TO_DOM.get(type), __onKeyEvent);
                }
        }
    }

    private override function unmapEvent(type:String, listener:UIEvent->Void) {
        var container = Browser.document.body;
        
        switch (type) {
            case MouseEvent.MOUSE_MOVE | MouseEvent.MOUSE_OVER | MouseEvent.MOUSE_OUT |
                MouseEvent.MOUSE_DOWN | MouseEvent.MOUSE_UP | MouseEvent.CLICK | MouseEvent.DBL_CLICK:
                _mapping.remove(type);
                container.removeEventListener(EventMapper.HAXEUI_TO_DOM.get(type), __onMouseEvent);
                if (EventMapper.MOUSE_TO_TOUCH.get(type) != null) {
                    container.removeEventListener(EventMapper.MOUSE_TO_TOUCH.get(type), __onMouseEvent);
                }

            case KeyboardEvent.KEY_DOWN | KeyboardEvent.KEY_UP:
                _mapping.remove(type);
                container.removeEventListener(EventMapper.HAXEUI_TO_DOM.get(type), __onKeyEvent);
        }
    }

    //***********************************************************************************************************
    // Event Handlers
    //***********************************************************************************************************
    private function __onMouseEvent(event:js.html.Event) {
        //event.preventDefault();

        var type:String = EventMapper.DOM_TO_HAXEUI.get(event.type);
        if (type != null) {
            var fn = _mapping.get(type);
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
}
