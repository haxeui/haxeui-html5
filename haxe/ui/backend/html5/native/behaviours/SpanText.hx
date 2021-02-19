package haxe.ui.backend.html5.native.behaviours;

import haxe.ui.behaviours.DataBehaviour;
import js.Browser;
import js.html.Element;
import js.html.InputElement;
import js.html.SpanElement;

@:keep
class SpanText extends DataBehaviour {
    public override function validateData() {
        var el:Element = _component.element;
        var span:SpanElement = getSpan(el);
        var checkbox:InputElement = getInput(el, "checkbox");
        if (_value.isNull) {
            HtmlUtils.removeElement(span);
            if (checkbox != null) {
                checkbox.style.marginTop = "-15px";
            }
            return;
        }

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

            if (checkbox != null) {
                checkbox.style.marginTop = "0";
            }
            el.appendChild(span);
        }

        var invalidate:Bool = false;
        if (_component.autoWidth == true) {
            _component.element.style.width = null;
            invalidate = true;
        }
        if (_component.autoHeight == true) {
            _component.element.style.height = null;
            invalidate = true;
        }

        span.textContent = _value;
        if (invalidate == true) {
            _component.invalidateComponentLayout();
        }
    }

    private function getSpan(el:Element):SpanElement {
        var span:SpanElement = null;
        var list = el.getElementsByTagName("span");
        if (list.length != 0) {
            span = cast list.item(0);
        }
        return span;
    }

    private function getInput(el:Element, type:String):InputElement {
        var input:InputElement = null;
        var list = el.getElementsByTagName("input");
        if (list.length != 0) {
            for (n in 0...list.length) {
                var child = list.item(n);
                if ((child is InputElement) && cast(child, InputElement).type == type) {
                    input = cast child;
                    break;
                }
            }
        }
        return input;
    }
}