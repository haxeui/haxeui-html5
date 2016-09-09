package haxe.ui.backend;
import js.Browser;

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
}
