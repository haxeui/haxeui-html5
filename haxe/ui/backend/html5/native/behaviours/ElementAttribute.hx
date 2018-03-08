package haxe.ui.backend.html5.native.behaviours;

import haxe.ui.core.Behaviour;
import haxe.ui.util.Variant;
import js.html.Element;
import js.html.InputElement;
import js.html.ProgressElement;

@:keep
class ElementAttribute extends Behaviour {
    public override function set(value:Variant) {
        var el:Element = _component.element;
        var name:String = getConfigValue("name");
        if (name == null) {
            return;
        }

        var child:String = getConfigValue("child");
        if (child != null) {
            var list = el.getElementsByTagName(child);
            if (list.length == 0) {
                return;
            }
            el = list.item(0);
        }

        if (getConfigValueBool("remove", false) == true) {
            if (value == true) {
                el.removeAttribute(name);
            }
            return;
        }

        if (el.nodeName == "INPUT" && value != null) {
            var input:InputElement = cast el;
            if (value.isBool == true && name == "checked") {
                input.checked = value;
            } else if (name == "min") {
                input.min = value;
            } else if (name == "max") {
                input.max = value;
            } else if (name == "value") {
                input.value = value.toString();
            }
        } else if (el.nodeName == "PROGRESS" && value != null) {
            var progress:ProgressElement = cast el;
            if (name == "min") {
                //progress.min = value;
            } else if (name == "max") {
                progress.max = value;
            } else if (name == "value") {
                progress.value = value;
            }
        } else {
            el.setAttribute(name, value);
        }

        var removeIfNegative:Bool = getConfigValueBool("removeIfNegative", false);
        if ((value == null || (value.isBool == true && value == false)) && removeIfNegative == true) {
            el.removeAttribute(name);
            return;
        }
    }
    
    public override function get():Variant {
        var el:Element = _component.element;
        var name:String = getConfigValue("name");
        if (name == null) {
            return null;
        }

        var child:String = getConfigValue("child");
        if (child != null) {
            var list = el.getElementsByTagName(child);
            if (list.length == 0) {
                return null;
            }
            el = list.item(0);
        }
        
        var value:Variant = null;
        
        if (el.nodeName == "INPUT") {
            var input:InputElement = cast el;
            if (name == "checked") {
                value = input.checked;
            } else if (name == "min") {
                value = input.min;
            } else if (name == "max") {
                value = input.max;
            } else if (name == "value") {
                value = input.value;
            }
        } else if (el.nodeName == "PROGRESS") {
            var progress:ProgressElement = cast el;
            if (name == "min") {
                //value = progress.min;
            } else if (name == "max") {
                value = progress.max;
            } else if (name == "value") {
                value = progress.value;
            }
        } else {
            value = el.getAttribute(name);
        }
        
        return value;
    }
}