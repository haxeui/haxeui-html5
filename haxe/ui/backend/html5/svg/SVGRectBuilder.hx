package haxe.ui.backend.html5.svg;

import js.Browser;
import js.html.svg.RectElement;

class SVGRectBuilder {
    public var element:RectElement = null;

    public function new() {
        element = cast Browser.document.createElementNS("http://www.w3.org/2000/svg", "rect");
    }
    
    public function id(value:String) {
        element.id = value;
        return this;
    }
    
    public function position(x:Float, y:Float) {
        element.x.baseVal.value = x;
        element.y.baseVal.value = y;
    }
    
    public function size(width:Float, height:Float) {
        element.width.baseVal.value = width;
        element.height.baseVal.value = height;
    }
    
    public function stroke(strokeStyle:SVGStrokeData) {
        if (strokeStyle.color != null) {
            element.setAttribute("stroke", strokeStyle.color);
        }
        if (strokeStyle.thickness != null) {
            element.setAttribute("stroke-width", Std.string(strokeStyle.thickness));
        }
        return this;
    }
    
    public function fill(fillStyle:SVGFillData) {
        if (fillStyle.color != null) {
            element.setAttribute("fill", fillStyle.color);
        }
        return this;
    }
}
