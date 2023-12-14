package haxe.ui.backend.html5.svg;

import js.Browser;
import js.html.svg.TextElement;

class SVGTextBuilder {
    public var element:TextElement = null;
    
    public function new() {
        element = cast Browser.document.createElementNS("http://www.w3.org/2000/svg", "text");
    }
    
    public function id(value:String) {
        element.id = value;
        return this;
    }
    
    public function value(value:String) {
        element.textContent = value;
        return this;
    }
    
    public function position(x:Float, y:Float) {
        element.setAttribute("x", Std.string(x));
        element.setAttribute("y", Std.string(y));
        return this;
    }
    
    public function offset(x:Float, y:Float) {
        element.setAttribute("dx", Std.string(x));
        element.setAttribute("dy", Std.string(y));
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
    
    public function font(fontStyle:SVGFontData) {
        if (fontStyle.size != null) {
            element.setAttribute("font-size", Std.string(fontStyle.size));
        }
        if (fontStyle.family != null) {
            element.setAttribute("font-family", fontStyle.family);
        }
        if (fontStyle.anchor != null) {
            element.setAttribute("text-anchor", fontStyle.anchor);
        }
    }
}