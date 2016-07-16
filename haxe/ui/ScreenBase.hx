package haxe.ui;

import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.dialogs.DialogButton;
import haxe.ui.core.Component;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.UIEvent;
import haxe.ui.html5.EventMapper;
import js.Browser;
import js.html.Element;

class ScreenBase {
	private var _mapping:Map<String, UIEvent->Void>;
	
	public var focus:Component;
	public var options(default, default):Dynamic;
	
	public function new() {
		_mapping = new Map<String, UIEvent->Void>();
	}

	public var width(get, null):Float;	
	public function get_width():Float {
		return container.offsetWidth;
	}
	
	public var height(get, null):Float;	
	public function get_height() {
		return container.offsetHeight;
	}

    private var __topLevelComponents:Array<Component> = new Array<Component>();
	public function addComponent(component:Component) {
        __topLevelComponents.push(component);
        addResizeListener();
		resizeComponent(component);
		container.appendChild(component.element);
	}

	public function removeComponent(component:Component) {
        __topLevelComponents.remove(component);
		container.removeChild(component.element);
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
		if (options == null || options.stage == null) {
			return Browser.document.body;
		}
		return  options.stage;
	}
	
    private var _hasListener:Bool = false;
    private function addResizeListener() {
        if (_hasListener == true) {
            return;
        }
        
        Browser.window.onresize = function(e) {
           for (c in __topLevelComponents) {
               resizeComponent(c);
           }
        }
        
        _hasListener = true;
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
	}
	
	//***********************************************************************************************************
	// Event Handlers
	//***********************************************************************************************************
	private function __onMouseEvent(event:js.html.MouseEvent) {
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