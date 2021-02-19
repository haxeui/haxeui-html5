package haxe.ui.backend.html5.native;

import haxe.ui.core.Component;
import js.Browser;
import js.html.Element;
import js.html.InputElement;

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
        el.style.boxSizing = "border-box";

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
                if (StringTools.startsWith(StringTools.trim(parts[0]), "-webkit") && UserAgent.instance.chrome == false) {
                    // skip manually as firefox supports webkit css extensions
                    continue;
                }
                el.style.setProperty(StringTools.trim(parts[0]), StringTools.trim(parts[1]));
            }
        }

        /*
        if (nodeType == "input" && type == "range") {
            el.addEventListener("change", onChange);
        }
        */

        return el;
    }

    /*
    private function onChange(e) {
        if ((_component is Slider)) {
            var input:InputElement = cast _component.element;
            cast(_component, Slider).pos = Std.parseFloat(input.value);
        }
    }
    */

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