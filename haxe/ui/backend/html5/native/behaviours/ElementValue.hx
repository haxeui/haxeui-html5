package haxe.ui.backend.html5.native.behaviours;

import haxe.ui.core.Behaviour;
import haxe.ui.util.Variant;
import js.html.Element;
import js.html.TextAreaElement;

@:keep
class ElementValue extends Behaviour {
    public override function set(value:Variant) {
        var el:Element = _component.element;
        if (Std.is(el, TextAreaElement)) {
            cast(el, TextAreaElement).value = StringTools.replace(value, "\\n", "\n");
        } else {
            el.setAttribute("value", value);
        }
    }

    public override function get():Variant {
        var el:Element = _component.element;
        return el.textContent;
    }
}