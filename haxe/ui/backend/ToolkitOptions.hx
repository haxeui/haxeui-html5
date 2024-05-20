package haxe.ui.backend;

import js.html.Element;

typedef ToolkitOptions = {
    ?container:Element,
    ?useNativeScrollers:Null<Bool>,
    ?useHybridScrollers:Null<Bool>,
    ?throttleMouseWheelPlatforms:Array<String>,
    ?throttleMouseWheelTimestampDelta:Null<Float>
}
