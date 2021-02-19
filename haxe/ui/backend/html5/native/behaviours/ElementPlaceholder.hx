package haxe.ui.backend.html5.native.behaviours;

import haxe.ui.behaviours.Behaviour;
import js.html.InputElement;
import haxe.ui.util.Variant;
import js.html.Element;
import js.html.TextAreaElement;

@:keep
class ElementPlaceholder extends Behaviour {
    public override function set(value:Variant) {
        var el:Element = _component.element;
        if ((el is TextAreaElement)) {
            cast(el, TextAreaElement).placeholder = value;
        } else if ((el is InputElement)){
            cast(el, InputElement).placeholder = value;
        }
    }

    public override function get():Variant {
        var el:Element = _component.element;
        if ((el is TextAreaElement)) {
            return cast(el, TextAreaElement).placeholder;
        } else if ((el is InputElement)){
            return cast(el, InputElement).placeholder;
        } else {
            return null;
        }
    }
}