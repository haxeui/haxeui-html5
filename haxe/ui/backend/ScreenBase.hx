package haxe.ui.backend;

import haxe.ui.backend.html5.HtmlUtils;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.dialogs.DialogButton;
import haxe.ui.core.Component;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.Screen;
import haxe.ui.core.UIEvent;
import haxe.ui.backend.html5.EventMapper;
import js.Browser;
import js.html.Element;

class ScreenBase {
    private var _mapping:Map<String, UIEvent->Void>;

    public var focus:Component;
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

    private var _options:Dynamic;
    public var options(get, set):Dynamic;
    private function get_options():Dynamic {
        return _options;
    }
    private function set_options(value:Dynamic):Dynamic {
        _options = value;
        return value;
    }
    
    public var width(get, null):Float;
    public function get_width():Float {
        return container.offsetWidth;
    }

    public var height(get, null):Float;
    public function get_height() {
        return container.offsetHeight;
    }

    public var dpi(get, null):Float;
    private function get_dpi():Float {
        return 72;
    }
    
    private var __topLevelComponents:Array<Component> = new Array<Component>();
    public function addComponent(component:Component) {
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
        
        __topLevelComponents.push(component);
        addResizeListener();
        resizeComponent(component);
        container.appendChild(component.element);
    }

    public function removeComponent(component:Component) {
        __topLevelComponents.remove(component);
        container.removeChild(component.element);
    }

    private function handleSetComponentIndex(child:Component, index:Int) {
        //HtmlUtils.removeElement(child.element);
        if (index == cast(this, Screen).rootComponents.length - 1) {
            container.appendChild(child.element);
        } else {
            HtmlUtils.insertBefore(cast(this, Screen).rootComponents[index + 1].element, child.element);
        }
    }
    
    private function resizeComponent(c:Component) {
        if (c.percentWidth > 0) {
            c.width = (this.width * c.percentWidth) / 100;
        }
        if (c.percentHeight > 0) {
            c.height = (this.height * c.percentHeight) / 100;
        }
    }

    private var container(get, null):Element;
    private function get_container():Element {
        var c = null;
        if (options == null || options.container == null) {
            c = Browser.document.body;
        } else {
            c = options.container;
        }
        if (c.style.overflow == null || c.style.overflow == "") {
            c.style.overflow = "hidden";
        }
        return c;
    }

    private var _hasListener:Bool = false;
    private function addResizeListener() {
        if (_hasListener == true) {
            return;
        }

        _hasListener = true;
        Browser.window.onresize = function(e) {
           for (c in __topLevelComponents) {
               resizeComponent(c);
           }
        }

    }

    //***********************************************************************************************************
    // Dialogs
    //***********************************************************************************************************
    public function messageDialog(message:String, title:String = null, options:Dynamic = null, callback:DialogButton->Void = null):Dialog {
        return null;
    }

    public function showDialog(content:Component, options:Dynamic = null, callback:DialogButton->Void = null):Dialog {
        return null;
    }

    public function hideDialog(dialog:Dialog):Bool {
        return false;
    }

    //***********************************************************************************************************
    // Events
    //***********************************************************************************************************
    private function supportsEvent(type:String):Bool {
        return EventMapper.HAXEUI_TO_DOM.get(type) != null;
    }

    private function mapEvent(type:String, listener:UIEvent->Void) {
        switch (type) {
            case MouseEvent.MOUSE_MOVE | MouseEvent.MOUSE_OVER | MouseEvent.MOUSE_OUT
                | MouseEvent.MOUSE_DOWN | MouseEvent.MOUSE_UP | MouseEvent.CLICK:
                if (_mapping.exists(type) == false) {
                    _mapping.set(type, listener);
                    container.addEventListener(EventMapper.HAXEUI_TO_DOM.get(type), __onMouseEvent);
                }
        }
    }

    private function unmapEvent(type:String, listener:UIEvent->Void) {
        switch (type) {
            case MouseEvent.MOUSE_MOVE | MouseEvent.MOUSE_OVER | MouseEvent.MOUSE_OUT
                | MouseEvent.MOUSE_DOWN | MouseEvent.MOUSE_UP | MouseEvent.CLICK:
                _mapping.remove(type);
                container.removeEventListener(EventMapper.HAXEUI_TO_DOM.get(type), __onMouseEvent);
        }
    }

    //***********************************************************************************************************
    // Event Handlers
    //***********************************************************************************************************
    private function __onMouseEvent(event:js.html.MouseEvent) {
        event.preventDefault();
        
        var type:String = EventMapper.DOM_TO_HAXEUI.get(event.type);
        if (type != null) {
            var fn = _mapping.get(type);
            if (fn != null) {
                var mouseEvent = new MouseEvent(type);
                mouseEvent.screenX = event.pageX;
                mouseEvent.screenY = event.pageY;
                fn(mouseEvent);
            }
        }
    }
}