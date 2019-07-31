package haxe.ui.backend.html5.native.behaviours;

import haxe.ui.behaviours.Behaviour;
import haxe.ui.util.Variant;
import js.html.Element;

@:keep
class ElementProperty extends Behaviour {
    public override function set(value:Variant) {
        var el:Element = _component.element;
        var name:String = getConfigValue("name");
        if (name == null) {
            return;
        }
        
        el = HtmlUtils.namedChild(el, getConfigValue("child"));
        Reflect.setProperty(el, name, value.toString());
    }
    
    public override function get():Variant {
        var el:Element = _component.element;
        var name:String = getConfigValue("name");
        if (name == null) {
            return null;
        }
        
        el = HtmlUtils.namedChild(el, getConfigValue("child"));
        return Variant.fromDynamic(Reflect.getProperty(el, name));
    }
}