package haxe.ui.html5.native.size;

import haxe.ui.layouts.DelegateLayout.DelegateLayoutSize;

@:keep
@:access(haxe.ui.core.Component)
class ComponentSize extends DelegateLayoutSize {
    public function new() {

    }

    private override function get_width():Float {
        var w = component.componentWidth;
        if (w == null || w <= 0) {
            w = getInt("defaultWidth");
        }
        return w;
    }

    private override function get_height():Float {
        var h = component.componentHeight;
        if (h == null || h <= 0) {
            h = getInt("defaultHeight");
        }
        return h;
    }
}