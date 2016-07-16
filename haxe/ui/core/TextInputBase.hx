package haxe.ui.core;

class TextInputBase extends TextDisplayBase {
    public function new() {
        super();
        element.contentEditable = "true";
        element.style.outline = "none";
        element.style.marginTop = "-1px";
        element.style.marginLeft = "-1px";
        element.style.whiteSpace = "nowrap";
        element.style.overflow = "hidden";
        element.style.cursor = "initial";
    }
}
