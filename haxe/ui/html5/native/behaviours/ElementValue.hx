package haxe.ui.html5.native.behaviours;

import haxe.ui.core.Behaviour;
import haxe.ui.util.Variant;
import js.html.Element;

@:keep
class ElementValue extends Behaviour {
	public override function set(value:Variant) {
		var el:Element = _component.element;
		el.setAttribute("value", value);
	}
	
	public override function get():Variant {
		var el:Element = _component.element;
		return el.textContent;
	}
}