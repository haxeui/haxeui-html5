package haxe.ui.backend.html5;

class EventMapper {
    public static var HAXEUI_TO_DOM:Map<String, String> = [
        haxe.ui.core.MouseEvent.MOUSE_MOVE => "mousemove",
        haxe.ui.core.MouseEvent.MOUSE_OVER => "mouseover",
        haxe.ui.core.MouseEvent.MOUSE_OUT => "mouseout",
        haxe.ui.core.MouseEvent.MOUSE_DOWN => "mousedown",
        haxe.ui.core.MouseEvent.MOUSE_UP => "mouseup",
        haxe.ui.core.MouseEvent.CLICK => "click",
        haxe.ui.core.UIEvent.CHANGE => "change",
        haxe.ui.core.KeyboardEvent.KEY_DOWN => "keydown",
        haxe.ui.core.KeyboardEvent.KEY_UP => "keyup"
    ];

    public static var DOM_TO_HAXEUI:Map<String, String> = [
        "mousemove" => haxe.ui.core.MouseEvent.MOUSE_MOVE,
        "mouseover" => haxe.ui.core.MouseEvent.MOUSE_OVER,
        "mouseout" => haxe.ui.core.MouseEvent.MOUSE_OUT,
        "mousedown" => haxe.ui.core.MouseEvent.MOUSE_DOWN,
        "mouseup" => haxe.ui.core.MouseEvent.MOUSE_UP,
        "touchmove" => haxe.ui.core.MouseEvent.MOUSE_MOVE,
        "touchstart" => haxe.ui.core.MouseEvent.MOUSE_DOWN,
        "touchend" => haxe.ui.core.MouseEvent.MOUSE_UP,
        "click" => haxe.ui.core.MouseEvent.CLICK,
        "change" => haxe.ui.core.UIEvent.CHANGE,
        "keydown" => haxe.ui.core.KeyboardEvent.KEY_DOWN,
        "keyup" => haxe.ui.core.KeyboardEvent.KEY_UP
    ];
    
    public static var MOUSE_TO_TOUCH:Map<String, String> = [
        haxe.ui.core.MouseEvent.MOUSE_MOVE => "touchmove",
        haxe.ui.core.MouseEvent.MOUSE_DOWN => "touchstart",
        haxe.ui.core.MouseEvent.MOUSE_UP => "touchend"
    ];
    
    public static var TOUCH_TO_MOUSE:Map<String, String> = [
        "touchmove" => haxe.ui.core.MouseEvent.MOUSE_MOVE,
        "touchstart" => haxe.ui.core.MouseEvent.MOUSE_OUT,
        "touchend" => haxe.ui.core.MouseEvent.MOUSE_DOWN
    ];
}