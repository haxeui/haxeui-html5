package haxe.ui.backend.html5.native.size;

import haxe.ui.layouts.DelegateLayout.DelegateLayoutSize;

@:keep
class TextSize extends DelegateLayoutSize {
    public function new() {

    }

    private override function get_width():Float {
        var size = HtmlUtils.measureText(component.text);
        return size.width + getInt("incrementWidthBy");
    }

    private override function get_height():Float {
        var size = HtmlUtils.measureText(component.text);
        return size.height + getInt("incrementHeightBy");
    }
}