package haxe.ui.backend.html5.native.behaviours;

import haxe.ui.core.Behaviour;
import haxe.ui.util.Variant;
import js.html.Element;

@:keep
class ElementDisabled extends Behaviour {
    public override function set(value:Variant) {
        var el:Element = _component.element;
        if (value == true) {
            el.setAttribute("disabled", "true");
            for (child in el.children) {
                child.setAttribute("disabled", "true");
            }
        } else {
            el.removeAttribute("disabled");
            for (child in el.children) {
                child.removeAttribute("disabled");
            }
        }
    }
    
    public override function get():Variant {
        var el:Element = _component.element;
        return (el.getAttribute("disabled") == "true");
    }
}