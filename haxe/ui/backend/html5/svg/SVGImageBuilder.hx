package haxe.ui.backend.html5.svg;

import js.Browser;
import js.html.svg.ImageElement;

class SVGImageBuilder {
    public var element:ImageElement  = null;
    
    public function new() {
        element = cast Browser.document.createElementNS("http://www.w3.org/2000/svg", "image");
    }
    
    public function position(x:Float, y:Float) {
        element.x.baseVal.value = x;
        element.y.baseVal.value = y;
    }
    
    public function size(width:Float, height:Float) {
        element.width.baseVal.value = width;
        element.height.baseVal.value = height;
    }
    
    public function href(uri:String) {
        element.href.baseVal = uri;
    }
}