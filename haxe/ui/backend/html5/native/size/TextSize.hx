package haxe.ui.backend.html5.native.size;

import haxe.ui.layouts.DelegateLayout.DelegateLayoutSize;

@:keep
class TextSize extends DelegateLayoutSize {
    private override function get_width():Float {
//        var size = HtmlUtils.measureText(component.text, 0, 0, component.style.fontSize, component.style.fontName);
        var size = HtmlUtils.measureText(component.text, 0, 0, component.computedStyle.font.size, component.computedStyle.font.family);
        return size.width + getInt("incrementWidthBy");
    }

    private override function get_height():Float {
//        var size = HtmlUtils.measureText(component.text, 0, 0, component.style.fontSize, component.style.fontName);
        var size = HtmlUtils.measureText(component.text, 0, 0, component.computedStyle.font.size, component.computedStyle.font.family);
        return size.height + getInt("incrementHeightBy");
    }
}