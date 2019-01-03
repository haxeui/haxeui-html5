package haxe.ui.backend;

import haxe.ui.geom.Rectangle;
import haxe.ui.assets.ImageInfo;
import haxe.ui.core.Component;
import haxe.ui.backend.html5.HtmlUtils;
import js.Browser;
import js.html.CSSStyleDeclaration;
import js.html.ImageElement;

class ImageDisplayBase {
    public var parentComponent:Component;
    public var aspectRatio:Float = 1; // width x height

    public var element:ImageElement;

    public function new() {
        element = Browser.document.createImageElement();
        element.style.position = "absolute";
        element.style.setProperty("pointer-events", "none");
    }

    private var _left:Float = 0;
    private var _top:Float = 0;
    private var _imageWidth:Float = 0;
    private var _imageHeight:Float = 0;
    private var _imageInfo:ImageInfo;
    private var _imageClipRect:Rectangle;

    public function dispose() {
        if (element != null) {
            HtmlUtils.removeElement(element);
        }
    }

    //***********************************************************************************************************
    // Validation functions
    //***********************************************************************************************************

    private function validateData() {
        if (element.src != _imageInfo.data.src) {
            element.src = _imageInfo.data.src;
        }
    }

    private function validatePosition() {
        var style:CSSStyleDeclaration = element.style;
        style.left = HtmlUtils.px(_left);
        style.top = HtmlUtils.px(_top);
    }

    private function validateDisplay() {
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
