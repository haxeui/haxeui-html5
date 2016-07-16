package haxe.ui.html5.native;

import haxe.ui.components.CheckBox;
import haxe.ui.components.OptionBox;
import haxe.ui.core.Component;
import js.Browser;
import js.html.Element;
import js.html.InputElement;
import js.html.LabelElement;

@:keep
class LabeledInputElement extends NativeElement {
	public function new(component:Component) {
		super(component);
	}
	
	public override function create():Element {
		var type:String = getConfigValue("type", "button");
		var input:InputElement = Browser.document.createInputElement();
		input.style.display = "inline";
		input.style.verticalAlign = "middle";
		input.style.margin = "0";
		input.style.marginRight = "2px";
		input.type = type;
		
		var label:LabelElement = Browser.document.createLabelElement();
		label.appendChild(input);
		
		if (type == "checkbox" || type == "radio") {
			input.addEventListener("change", onChange);
		}
		
		return label;
	}
	
	private override function onChange(e) {
		var type:String = getConfigValue("type", "button");
		if (type == "checkbox" || type == "radio") {
			var label:LabelElement = cast _component.element;
			var input:InputElement = cast label.getElementsByTagName("input").item(0);
			if (type == "checkbox") {
				var checkbox:CheckBox = cast _component;
				checkbox.selected = input.checked;
			} else if (type == "radio") {
				var optionbox:OptionBox = cast _component;
				optionbox.selected = input.checked;
			}
		}
	}
}