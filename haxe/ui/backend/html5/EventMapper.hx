package haxe.ui.backend.html5;

class EventMapper {
    public static var HAXEUI_TO_DOM:Map<String, String> = [
        haxe.ui.events.MouseEvent.MOUSE_MOVE => "pointermove",
        haxe.ui.events.MouseEvent.MOUSE_OVER => "pointerenter",
        haxe.ui.events.MouseEvent.MOUSE_OUT => "pointerout",
        haxe.ui.events.MouseEvent.MOUSE_DOWN => "pointerdown",
        haxe.ui.events.MouseEvent.MOUSE_UP => "pointerup",
        haxe.ui.events.MouseEvent.CLICK => "click",
        haxe.ui.events.MouseEvent.DBL_CLICK => "dblclick",
        haxe.ui.events.MouseEvent.RIGHT_MOUSE_DOWN => "mousedown",
        haxe.ui.events.MouseEvent.RIGHT_MOUSE_UP => "mouseup",
        haxe.ui.events.MouseEvent.RIGHT_CLICK => "contextmenu",
        haxe.ui.events.UIEvent.CHANGE => "change",
        haxe.ui.events.KeyboardEvent.KEY_DOWN => "keydown",
        haxe.ui.events.KeyboardEvent.KEY_UP => "keyup",
        haxe.ui.events.ScrollEvent.CHANGE => "scroll"
    ];

    public static var DOM_TO_HAXEUI:Map<String, String> = [
        "pointermove" => haxe.ui.events.MouseEvent.MOUSE_MOVE,
        "pointerenter" => haxe.ui.events.MouseEvent.MOUSE_OVER,
        "pointerout" => haxe.ui.events.MouseEvent.MOUSE_OUT,
        "pointerdown" => haxe.ui.events.MouseEvent.MOUSE_DOWN,
        "pointerup" => haxe.ui.events.MouseEvent.MOUSE_UP,
        "click" => haxe.ui.events.MouseEvent.CLICK,
        "contextmenu" => haxe.ui.events.MouseEvent.RIGHT_CLICK,
        "dblclick" => haxe.ui.events.MouseEvent.DBL_CLICK,
        "change" => haxe.ui.events.UIEvent.CHANGE,
        "keydown" => haxe.ui.events.KeyboardEvent.KEY_DOWN,
        "keyup" => haxe.ui.events.KeyboardEvent.KEY_UP,
        "scroll" => haxe.ui.events.ScrollEvent.CHANGE
    ];
    
    public static var MOUSE_TO_TOUCH:Map<String, String> = [
        haxe.ui.events.MouseEvent.MOUSE_MOVE => "pointermove",
        haxe.ui.events.MouseEvent.MOUSE_DOWN => "pointerdown",
        haxe.ui.events.MouseEvent.MOUSE_UP => "pointerup"
    ];
    
    public static var TOUCH_TO_MOUSE:Map<String, String> = [
        "pointermove" => haxe.ui.events.MouseEvent.MOUSE_MOVE,
        "pointerout" => haxe.ui.events.MouseEvent.MOUSE_OUT,
        "pointerdown" => haxe.ui.events.MouseEvent.MOUSE_DOWN
    ];
}