package haxe.ui.backend.html5;

class EventMapper {
    public static var HAXEUI_TO_DOM:Map<String, String> = [
        haxe.ui.core.MouseEvent.MOUSE_MOVE => "mousemove",
        haxe.ui.core.MouseEvent.MOUSE_OVER => "mouseover",
        haxe.ui.core.MouseEvent.MOUSE_OUT => "mouseout",
        haxe.ui.core.MouseEvent.MOUSE_DOWN => "mousedown",
        haxe.ui.core.MouseEvent.MOUSE_UP => "mouseup",
        haxe.ui.core.MouseEvent.CLICK => "click"
    ];

    public static var DOM_TO_HAXEUI:Map<String, String> = [
        "mousemove" => haxe.ui.core.MouseEvent.MOUSE_MOVE,
        "mouseover" => haxe.ui.core.MouseEvent.MOUSE_OVER,
        "mouseout" => haxe.ui.core.MouseEvent.MOUSE_OUT,
        "mousedown" => haxe.ui.core.MouseEvent.MOUSE_DOWN,
        "mouseup" => haxe.ui.core.MouseEvent.MOUSE_UP,
        "click" => haxe.ui.core.MouseEvent.CLICK
    ];
}