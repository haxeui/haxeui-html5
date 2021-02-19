package haxe.ui.backend.html5.native.behaviours;

import haxe.ui.behaviours.DataBehaviour;
import js.html.Element;
import js.html.TextAreaElement;

@:keep
class ElementValue extends DataBehaviour {
    public override function validateData() {
        var el:Element = _component.element;
        if ((el is TextAreaElement)) {
            cast(el, TextAreaElement).value = StringTools.replace(_value, "\\n", "\n");
        } else {
            el.setAttribute("value", _value);
        }
    }
}