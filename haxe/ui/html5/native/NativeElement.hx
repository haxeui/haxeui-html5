package haxe.ui.html5.native;

import haxe.ui.components.Slider;
import haxe.ui.core.Component;
import haxe.ui.styles.Style;
import js.Browser;
import js.html.Element;
import js.html.InputElement;
import js.html.SpanElement;

@:keep
class NativeElement {
	private var _component:Component;

	public var config:Map<String, String> = null;
	
	public function new(component:Component) {
		_component = component;
	}
	
	public function create():Element {
		var nodeType:String = getConfigValue("nodeType", "div");
		var el:Element = Browser.document.createElement(nodeType);
		
		var type:String = getConfigValue("type");
		if (type != null) {
			el.setAttribute("type", type);
		}
		
		var orient:String = getConfigValue("orient");
		if (orient != null) {
			el.setAttribute("orient", orient);
		}
		
		var style:String = getConfigValue("style");
		if (style != null) {
			var styles:Array<String> = style.split(";");
			for (s in styles) {
				s = StringTools.trim(s);
				if (s.length == 0) {
					continue;
				}
				var parts = s.split(":");
				el.style.setProperty(StringTools.trim(parts[0]), StringTools.trim(parts[1]));
			}
		}
		
		if (nodeType == "input" && type == "range") {
			el.addEventListener("change", onChange);
		}
		
		return el;
	}
	
    public function paint():Void {
        var el:Element = _component.element;
        var style:Style = _component.style;
        var nodeType:String = el.nodeName.toLowerCase();
        if (nodeType == "button") {
            var list = el.getElementsByTagName("span");
            if (list != null && list.length > 0) {
                var span:SpanElement = cast list.item(0);
                if (style.color != null) {
                    span.style.color = HtmlUtils.color(style.color);
                }
            }
        } else if (nodeType == "label") {
            if (style.color != null) {
                el.style.color = HtmlUtils.color(style.color);
            }
        }
    }
    
	private function onChange(e) {
		if (Std.is(_component, Slider)) {
			var input:InputElement = cast _component.element;
			cast(_component, Slider).pos = Std.parseFloat(input.value);
		}
	}
	
	public function getConfigValue(name:String, defaultValue:String = null):String {
		if (config == null) {
			return defaultValue;
		}
		if (config.exists(name) == false) {
			return defaultValue;
		}
		return config.get(name);
	}
}