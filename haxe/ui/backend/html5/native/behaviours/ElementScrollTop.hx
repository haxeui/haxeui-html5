package haxe.ui.backend.html5.native.behaviours;

import haxe.ui.core.Behaviour;
import haxe.ui.util.Variant;

@:keep
class ElementScrollTop extends Behaviour {
    public override function set(value:Variant) {
        _component.element.scrollTop = value;
    }
    
    public override function get():Variant {
        return _component.element.scrollTop;
    }
}