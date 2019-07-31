package haxe.ui.backend.html5.native.behaviours;

import haxe.ui.behaviours.DataBehaviour;
import js.html.Element;

@:keep
class ElementAttribute extends DataBehaviour {
    public override function validateData() {
        var el:Element = _component.element;
        var name:String = getConfigValue("name");
        if (name == null) {
            return;
        }

        el = HtmlUtils.namedChild(el, getConfigValue("child"));

        if (getConfigValueBool("remove", false) == true) {
            if (_value == true) {
                el.removeAttribute(name);
            }
            return;
        }
        
        el.setAttribute(name, _value);
        
        var removeIfNegative:Bool = getConfigValueBool("removeIfNegative", false);
        if ((_value == null || (_value.isBool == true && _value == false)) && removeIfNegative == true) {
            el.removeAttribute(name);
            return;
        }
    }
}