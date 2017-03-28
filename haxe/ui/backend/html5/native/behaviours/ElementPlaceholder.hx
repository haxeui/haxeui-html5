package haxe.ui.backend.html5.native.behaviours;

import js.html.InputElement;
import haxe.ui.core.Behaviour;
import haxe.ui.util.Variant;
import js.html.Element;
import js.html.TextAreaElement;

@:keep
class ElementPlaceholder extends Behaviour {
    public override function set(value:Variant) {
        var el:Element = _component.element;
        if (Std.is(el, TextAreaElement)) {
            cast(el, TextAreaElement).placeholder = value;
        } else if (Std.is(el, InputElement)){
            cast(el, InputElement).placeholder = value;
        }
    }

    public override function get():Variant {
        var el:Element = _component.element;
        if (Std.is(el, TextAreaElement)) {
            return cast(el, TextAreaElement).placeholder;
        } else if (Std.is(el, InputElement)){
            return cast(el, InputElement).placeholder;
        } else {
            return null;
        }
    }
}