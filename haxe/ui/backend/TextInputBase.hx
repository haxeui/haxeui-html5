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
    }

    private var _password:Bool = false;
    private var _hscrollPos:Float = 0;
    private var _vscrollPos:Float = 0;

    private function onKeyUp(e) {
        if (Std.is(parentComponent, TextArea)) {
            _text = cast(element, TextAreaElement).value;
        } else {
            _text = cast(element, InputElement).value;
        }
    }

    //***********************************************************************************************************
    // Validation functions
    //***********************************************************************************************************

    private override function validateData() {
        if (_text != null) {
            var html:String = normalizeText(_text);
            if (Std.is(element, InputElement)) {
                cast(element, InputElement).value = html;
            } else if (Std.is(element, TextAreaElement)) {
                cast(element, TextAreaElement).value = html;
            }
        }
    }

    private override function validateStyle():Bool {
        var measureTextRequired:Bool = false;

        if ((_multiline == false && Std.is(element, InputElement) == false)
            || (_multiline == true && Std.is(element, TextAreaElement) == false)) {

            var newElement:Element = createElement();
            element.parentElement.appendChild(newElement);
            HtmlUtils.removeElement(element);

            element.removeEventListener("keyup", onKeyUp);

            element = newElement;

            measureTextRequired = true;
        }

        if (Std.is(element, InputElement)) {
            var inputElement:InputElement = cast element;

            if (_password == true && inputElement.type != "password") {
                inputElement.type = "password";
            } else if (_password == false && inputElement.type != "") {
                inputElement.type = "";
            }
        }

        var hscrollValue = Std.int(_hscrollPos);
        if (element.scrollLeft != hscrollValue) {
            element.scrollLeft = hscrollValue;
        }

        var vscrollValue = Std.int(_vscrollPos);
        if (element.scrollTop != vscrollValue) {
            element.scrollTop = vscrollValue;
        }

        return super.validateStyle() || measureTextRequired;
    }

    private override function measureText() {
        if (Std.is(element, TextAreaElement)) {
            _textWidth = cast(element, TextAreaElement).scrollWidth;
            _textHeight = cast(element, TextAreaElement).scrollHeight;
        } else {
            super.measureText();
        }
    }

    //***********************************************************************************************************
    // Util functions
    //***********************************************************************************************************

    private override function createElement():Element {
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
            el.style.whiteSpace = "nowrap";
            el.onkeydown = function(e) {
                if (e.keyCode == 9 || e.which == 9) {
                    e.preventDefault();
                    e.stopImmediatePropagation();
                    e.stopPropagation();

                    var ta:TextAreaElement = cast(el, TextAreaElement);
                    var s = ta.selectionStart;
                    ta.value = ta.value.substring(0, ta.selectionStart) + "\t" + ta.value.substring(ta.selectionEnd);
                    ta.selectionEnd = s + 1;

                    return false;
                }
                return true;
            }
        }

        el.addEventListener("keyup", onKeyUp);

        return el;
    }

    private override function setTempDivData(div:Element) {
        var t:String = _text;
        if (t == null || t.length == 0) {
            t = "|";
        }

        div.style.fontFamily = element.style.fontFamily;
        div.style.fontSize = element.style.fontSize;
        div.style.width = "";
        div.innerHTML = normalizeText(t);
    }

    private override function normalizeText(text:String):String {
        return StringTools.replace(text, "\\n", "\n");
    }
}
