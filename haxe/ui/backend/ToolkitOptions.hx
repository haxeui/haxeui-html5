package haxe.ui.backend;

import js.html.Element;

typedef ToolkitOptions = {
    ?container:Element,
    ?throttleMouseWheelPlatforms:Array<String>,
    ?throttleMouseWheelTimestampDelta:Null<Float>
}
