package haxe.ui.backend.html5.svg;

import js.Browser;
import js.html.svg.LineElement;

class SVGLineBuilder {
    public var element:LineElement = null;
    
    public function new() {
        element = cast Browser.document.createElementNS("http://www.w3.org/2000/svg", "line");
    }
    
    public function id(value:String) {
        element.id = value;
        return this;
    }
    
    public function start(x:Float, y:Float) {
        element.x1.baseVal.value = x;
        element.y1.baseVal.value = y;
    }
    
    public function end(x:Float, y:Float) {
        element.x2.baseVal.value = x;
        element.y2.baseVal.value = y;
    }
    
    public function stroke(strokeStyle:SVGStrokeData) {
        if (strokeStyle.color != null) {
            element.setAttribute("stroke", strokeStyle.color);
        }
        if (strokeStyle.thickness != null) {
            element.setAttribute("stroke-width", Std.string(strokeStyle.thickness));
        }
    }
}