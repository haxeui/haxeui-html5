package haxe.ui.backend;

import haxe.ui.backend.html5.HtmlUtils;
import js.Browser;
import js.html.CSSStyleDeclaration;
import js.html.ImageElement;

class ImageDisplayImpl extends ImageBase {
    public var element:ImageElement;

    public function new() {
        super();
        element = Browser.document.createImageElement();
        element.style.position = "absolute";
        element.style.borderRadius = "inherit";
        element.style.setProperty("pointer-events", "none");
        element.style.setProperty("image-rendering", "pixelated");
        element.style.setProperty("image-rendering", "-moz-crisp-edges");
        element.style.setProperty("image-rendering", "crisp-edges");
    }

    public override function dispose() {
        if (element != null) {
            HtmlUtils.removeElement(element);
        }
    }

    //***********************************************************************************************************
    // Validation functions
    //***********************************************************************************************************

    private override function validateData() {
        if (element.src != _imageInfo.data.src) {
            element.src = _imageInfo.data.src;
        }
    }

    private override function validatePosition() {
        var style:CSSStyleDeclaration = element.style;
        style.left = HtmlUtils.px(_left);
        style.top = HtmlUtils.px(_top);
    }

    private override function validateDisplay() {
        var style:CSSStyleDeclaration = element.style;
        style.width = HtmlUtils.px(_imageWidth);
        style.height = HtmlUtils.px(_imageHeight);

        if (_imageClipRect != null) {
            var clipValue = 'rect(${HtmlUtils.px(-_top + _imageClipRect.top)},${HtmlUtils.px(-_left + _imageClipRect.left + _imageClipRect.width)},${HtmlUtils.px(-_top + _imageClipRect.top + _imageClipRect.height)},${HtmlUtils.px(-_left + _imageClipRect.left)})';
            if (element.style.clip != clipValue) {
                element.style.clip = clipValue;
            }
        } else if (element.style.clip != null) {
            element.style.removeProperty("clip");
        }
    }
}
