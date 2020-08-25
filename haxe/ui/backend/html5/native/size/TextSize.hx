package haxe.ui.backend.html5.native.size;

import haxe.ui.layouts.DelegateLayout.DelegateLayoutSize;

@:keep
class TextSize extends DelegateLayoutSize {
    private override function get_width():Float {
        var text = component.text;
        if (text == null) {
            text = "";
        }
        var size = HtmlUtils.measureText(text, 0, 0, component.style.fontSize, component.style.fontName);
        return size.width + getInt("incrementWidthBy");
    }

    private override function get_height():Float {
        var text = component.text;
        if (text == null) {
            text = "|";
        }
        var size = HtmlUtils.measureText(text, 0, 0, component.style.fontSize, component.style.fontName);
        return size.height + getInt("incrementHeightBy");
    }
}