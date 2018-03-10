package haxe.ui.backend.html5.native.size;

import haxe.ui.components.VerticalProgress;
import haxe.ui.components.VerticalSlider;
import haxe.ui.layouts.DelegateLayout.DelegateLayoutSize;

@:keep
class ElementSize extends DelegateLayoutSize {
    private override function get_width():Float {
        var w:Float = component.element.offsetWidth;
        if (Std.is(component, VerticalSlider)) {
            if (w == component.element.offsetHeight) {
                w = 21;
            }
        } else if (Std.is(component, VerticalProgress)) {
            if (component.element.offsetWidth > component.element.offsetHeight) {
                w = component.element.offsetHeight;
            }
        }
        return w;
    }

    private override function get_height():Float {
        var h:Float = component.element.offsetHeight;
        if (Std.is(component, VerticalProgress)) {
            if (component.element.offsetWidth > component.element.offsetHeight) {
               h = component.element.offsetWidth;
            }
        }
        return h;
    }
}