package haxe.ui.backend;

import haxe.ui.backend.html5.HtmlUtils;
import haxe.ui.components.TextArea;
import js.Browser;
import js.html.Element;
import js.html.InputElement;
import js.html.TextAreaElement;

class TextInputBase extends TextDisplayBase {
    public function new() {
        super();
        _multiline = false;
        createElement();
    }

    private function createElement():Element {
        var el:Element = null;
        if (_multiline == false) {
            el = Browser.document.createInputElement();
            el.style.border = "none";
            el.style.outline = "none";
            el.style.whiteSpace = "nowrap";
            el.style.overflow = "hidden";
            el.style.cursor = "initial";
            el.style.position = "absolute";
            el.style.backgroundColor = "inherit";
        } else {
            el = Browser.document.createTextAreaElement();
            el.style.border = "none";
            el.style.resize = "none";
            el.style.outline = "none";
            el.style.lineHeight = "1.4";
            el.style.padding = "5px";
            el.style.overflow = "hidden";
            el.style.cursor = "initial";
            el.style.position = "absolute";
            el.style.backgroundColor = "inherit";
        }
        return el;
    }
    
    @:access(haxe.ui.components.TextArea)
    private override function set_multiline(value:Bool):Bool {
        if (value == _multiline) {
            return value;
        }

        _multiline = value;
        if (_multiline == false) {
            if (element != null) {
                element.removeEventListener("keydown", onKeyDown);
                element.removeEventListener("keyup", onKeyUp);
            }
            
            var newElement:Element = createElement();
            if (element != null && element.parentElement != null) {
                element.parentElement.appendChild(newElement);
                HtmlUtils.removeElement(element);
            }
            element = newElement;
        } else {
            var newElement:Element = createElement();
            element.parentElement.appendChild(newElement);
            HtmlUtils.removeElement(element);
            element = newElement;

            element.addEventListener("keydown", onKeyDown);
            element.addEventListener("keyup", onKeyUp);
            
        }

        return value;
    }
    
    @:access(haxe.ui.components.TextArea)
    private function onKeyDown(e) {
        if (Std.is(parentComponent, TextArea)) {
            cast(parentComponent, TextArea).checkScrolls();
        }
    }
    
    @:access(haxe.ui.components.TextArea)
    private function onKeyUp(e) {
        if (Std.is(parentComponent, TextArea)) {
            cast(parentComponent, TextArea).checkScrolls();
        }
    }
    
    public var vscrollPos(get, set):Float;
    private function get_vscrollPos():Float {
        return element.scrollTop;
    }
    private function set_vscrollPos(value:Float):Float {
        element.scrollTop = Std.int(value);
        return value;
    }
    
    private override function get_text():String {
        if (Std.is(element, TextAreaElement)) {
            return cast(element, TextAreaElement).value;
        }
        return cast(element, InputElement).value;
    }

    private override function get_textHeight():Float {
        if (Std.is(element, TextAreaElement)) {
            return cast(element, TextAreaElement).scrollHeight;
        }
        return super.get_textHeight();
    }
    
    private override function set_text(value:String):String {
        var html:String = normalizeText(value);
        if (Std.is(element, InputElement)) {
            cast(element, InputElement).value = html;
        } else if (Std.is(element, TextAreaElement)) {
            cast(element, TextAreaElement).value = html;
        }

        _dirty = true;
        _text = value;
        measureText();
        return value;
    }
    
    private override function createTempDiv(html:String):Element {
        var div = super.createTempDiv(html);
        div.style.width = "";
        return div;
    }
    
    private override function normalizeText(text:String):String {
        return StringTools.replace(text, "\\n", "\n");
    }
}
