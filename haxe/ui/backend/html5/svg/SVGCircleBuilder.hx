package haxe.ui.backend.html5.svg;

import js.Browser;
import js.html.svg.CircleElement;

class SVGCircleBuilder {
    public var element:CircleElement = null;
    
    public function new() {
        element = cast Browser.document.createElementNS("http://www.w3.org/2000/svg", "circle");
    }
    
    public function id(value:String) {
        element.id = value;
        return this;
    }
    
    public function position(x:Float, y:Float) {
        element.cx.baseVal.value = x;
        element.cy.baseVal.value = y;
        return this;
    }
    
    public function radius(r:Float) {
        element.r.baseVal.value = r;
        return this;
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