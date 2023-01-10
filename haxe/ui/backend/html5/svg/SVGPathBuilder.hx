package haxe.ui.backend.html5.svg;

import js.Browser;
import js.html.svg.PathElement;

class SVGPathBuilder {
    public var element:PathElement = null;
    
    private var _d:StringBuf = new StringBuf();
    
    public function new() {
        element = cast Browser.document.createElementNS("http://www.w3.org/2000/svg", "path");
    }
    
    public function id(value:String) {
        element.id = value;
        return this;
    }
    
    public function moveTo(x:Float, y:Float, absolute:Bool = true) {
        if (absolute == true) {
            _d.add("M");
        } else {
            _d.add("m");
        }
        
        _d.add(x);
        _d.add(" ");
        _d.add(y);
        _d.add(" ");
        
        element.setAttribute("d", _d.toString());
        return this;
    }
    
    public function lineTo(x:Float, y:Float, absolute:Bool = true) {
        if (absolute == true) {
            _d.add("L");
        } else {
            _d.add("l");
        }
        
        _d.add(x);
        _d.add(" ");
        _d.add(y);
        _d.add(" ");
        
        element.setAttribute("d", _d.toString());
        return this;
    }
    
    public function cubicBezier(x1:Float, y1:Float, x2:Float, y2:Float, x:Float, y:Float, absolute:Bool = true) {
        if (absolute == true) {
            _d.add("C");
        } else {
            _d.add("c");
        }
        
        _d.add(x1);
        _d.add(" ");
        _d.add(y1);
        _d.add(" ");
        
        _d.add(x2);
        _d.add(" ");
        _d.add(y2);
        _d.add(" ");
        
        _d.add(x);
        _d.add(" ");
        _d.add(y);
        _d.add(" ");
        
        element.setAttribute("d", _d.toString());
        return this;
    }
    
    public function quadraticBezier(x1:Float, y1:Float, x:Float, y:Float, absolute:Bool = true) {
        if (absolute == true) {
            _d.add("Q");
        } else {
            _d.add("q");
        }
        
        _d.add(x1);
        _d.add(" ");
        _d.add(y1);
        _d.add(" ");
        
        _d.add(x);
        _d.add(" ");
        _d.add(y);
        _d.add(" ");
        
        element.setAttribute("d", _d.toString());
        return this;
    }
    
    public function close() {
        _d.add("Z ");
        element.setAttribute("d", _d.toString());
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
        if (fillStyle.opacity != null) {
            element.setAttribute("fill-opacity", Std.string(fillStyle.opacity));
        }
        return this;
    }
}
