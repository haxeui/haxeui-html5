package haxe.ui.html5.native.behaviours;

import haxe.ui.core.Behaviour;
import haxe.ui.util.Variant;
import js.Browser;
import js.html.Element;
import js.html.SpanElement;

@:keep
class SpanText extends Behaviour {
    public override function set(value:Variant) {
        var el:Element = _component.element;
        var span:SpanElement = getSpan(el);
        if (span == null) {
            span = Browser.document.createSpanElement();
            span.style.display = "inline-block";
            span.style.verticalAlign = "middle";


            var style:String = getConfigValue("style");
            if (style != null) {
                var styles:Array<String> = style.split(";");
                for (s in styles) {
                    s = StringTools.trim(s);
                    if (s.length == 0) {
                        continue;
                    }
                    var parts = s.split(":");
                    span.style.setProperty(StringTools.trim(parts[0]), StringTools.trim(parts[1]));
                }
            }

            el.appendChild(span);
        }

        span.textContent = value;
    }

    private function getSpan(el:Element):SpanElement {
        var span:SpanElement = null;
        var list = el.getElementsByTagName("span");
        if (list.length != 0) {
            span = cast list.item(0);
        }
        return span;
    }
}