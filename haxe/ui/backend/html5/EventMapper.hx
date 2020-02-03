package haxe.ui.backend.html5;
import haxe.ui.events.KeyboardEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.ScrollEvent;
import haxe.ui.events.UIEvent;

class EventMapper {
    public static var HAXEUI_TO_DOM:Map<String, String> = [
        haxe.ui.events.MouseEvent.MOUSE_MOVE => "mousemove",
        haxe.ui.events.MouseEvent.MOUSE_OVER => "mouseover",
        haxe.ui.events.MouseEvent.MOUSE_OUT => "mouseout",
        haxe.ui.events.MouseEvent.MOUSE_DOWN => "mousedown",
        haxe.ui.events.MouseEvent.MOUSE_UP => "mouseup",
        haxe.ui.events.MouseEvent.CLICK => "click",
		haxe.ui.events.MouseEvent.DBL_CLICK => "dblclick",
        haxe.ui.events.UIEvent.CHANGE => "change",
        haxe.ui.events.KeyboardEvent.KEY_DOWN => "keydown",
        haxe.ui.events.KeyboardEvent.KEY_UP => "keyup",
        haxe.ui.events.ScrollEvent.CHANGE => "scroll"
    ];

    public static var DOM_TO_HAXEUI:Map<String, String> = [
        "mousemove" => haxe.ui.events.MouseEvent.MOUSE_MOVE,
        "mouseover" => haxe.ui.events.MouseEvent.MOUSE_OVER,
        "mouseout" => haxe.ui.events.MouseEvent.MOUSE_OUT,
        "mousedown" => haxe.ui.events.MouseEvent.MOUSE_DOWN,
        "mouseup" => haxe.ui.events.MouseEvent.MOUSE_UP,
        "touchmove" => haxe.ui.events.MouseEvent.MOUSE_MOVE,
        "touchstart" => haxe.ui.events.MouseEvent.MOUSE_DOWN,
        "touchend" => haxe.ui.events.MouseEvent.MOUSE_UP,
        "click" => haxe.ui.events.MouseEvent.CLICK,
		"dblclick" => haxe.ui.events.MouseEvent.DBL_CLICK,
        "change" => haxe.ui.events.UIEvent.CHANGE,
        "keydown" => haxe.ui.events.KeyboardEvent.KEY_DOWN,
        "keyup" => haxe.ui.events.KeyboardEvent.KEY_UP,
        "scroll" => haxe.ui.events.ScrollEvent.CHANGE
    ];
    
    public static var MOUSE_TO_TOUCH:Map<String, String> = [
        haxe.ui.events.MouseEvent.MOUSE_MOVE => "touchmove",
        haxe.ui.events.MouseEvent.MOUSE_DOWN => "touchstart",
        haxe.ui.events.MouseEvent.MOUSE_UP => "touchend"
    ];
    
    public static var TOUCH_TO_MOUSE:Map<String, String> = [
        "touchmove" => haxe.ui.events.MouseEvent.MOUSE_MOVE,
        "touchstart" => haxe.ui.events.MouseEvent.MOUSE_OUT,
        "touchend" => haxe.ui.events.MouseEvent.MOUSE_DOWN
    ];
}