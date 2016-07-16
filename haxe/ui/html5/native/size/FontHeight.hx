package haxe.ui.html5.native.size;

import haxe.ui.layouts.DelegateLayout.DelegateLayoutSize;

@:keep
class FontHeight extends DelegateLayoutSize {
    private override function get_width():Float {
        return component.width;
    }

    private override function get_height():Float {
        return HtmlUtils.measureText("|").height + getInt("incrementBy");
    }
}