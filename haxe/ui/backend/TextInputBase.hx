package haxe.ui.backend;

import js.Browser;
import js.html.Element;
import js.html.InputElement;

class TextInputBase extends TextDisplayBase {
    public function new() {
        super();
        element = Browser.document.createInputElement();
        //element.contentEditable = "true";
        element.style.border = "none";
        element.style.outline = "none";
        element.style.marginTop = "-1px";
        element.style.marginLeft = "-1px";
        element.style.whiteSpace = "nowrap";
        element.style.overflow = "hidden";
        element.style.cursor = "initial";
        element.style.position = "absolute";
    }

    private override function get_text():String {
        return cast(element, InputElement).value;
    }

    private override function set_text(value:String):String {
        var html:String = text2Html(value);
        cast(element, InputElement).value = html;

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
}
