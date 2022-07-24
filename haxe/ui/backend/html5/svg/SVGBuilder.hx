package haxe.ui.backend.html5.svg;

import js.Browser;
import js.html.svg.SVGElement;

class SVGBuilder {
    public var element:SVGElement = null;
    
    public function new(existingElement:SVGElement = null, width:Null<Float> = null, height:Null<Float> = null) {
        if (existingElement == null) {
            element = cast Browser.document.createElementNS("http://www.w3.org/2000/svg", "svg");
        } else {
            element = existingElement;
        }
        if (width != null) {
            element.setAttribute("width", Std.string(width));
        }
        if (height != null) {
            element.setAttribute("height", Std.string(height));
        }
    }
    
    public function size(width:Float, height:Float) {
        element.setAttribute("width", Std.string(width));
        element.setAttribute("height", Std.string(height));
    }
    
    public function shapeRendering(value:String) { // crispEdges
        element.setAttribute("shape-rendering", value);
    }
    
    public function clear() {
        element.innerHTML = "";
    }
    
    public var currentStrokeStyle:SVGStrokeData = {};
    public function strokeStyle(strokeStyle:SVGStrokeData) {
        if (strokeStyle.color != null) {
            currentStrokeStyle.color = strokeStyle.color;
        }
        if (strokeStyle.thickness != null) {
            currentStrokeStyle.thickness = strokeStyle.thickness;
        }
        if (strokeStyle.alpha != null) {
            currentStrokeStyle.alpha = strokeStyle.alpha;
        }
    }
    
    public function clearStrokeStyle() {
        currentStrokeStyle = {};
    }
    
    public var currentFillStyle:SVGFillData = {};
    public function fillStyle(fillStyle:SVGFillData) {
        if (fillStyle.color != null) {
            currentFillStyle.color = fillStyle.color;
        }
    }
    
    public function clearFillStyle() {
        currentFillStyle = {};
    }
    
    public var currentFontStyle:SVGFontData = {};
    public function fontStyle(fontStyle:SVGFontData) {
        if (fontStyle.size != null) {
            currentFontStyle.size = fontStyle.size;
        }
        if (fontStyle.family != null) {
            currentFontStyle.family = fontStyle.family;
        }
        if (fontStyle.anchor != null) {
            currentFontStyle.anchor = fontStyle.anchor;
        }
    }
    
    public function clearFontStyle() {
        currentFontStyle = {};
    }
    
    public function line(x1:Float, y1:Float, x2:Float, y2:Float) {
        var builder = new SVGLineBuilder();
        builder.start(x1, y1);
        builder.end(x2, y2);
        builder.stroke(currentStrokeStyle);
        element.append(builder.element);
        return builder;
    }
    
    public function rectangle(x:Float, y:Float, width:Float, height:Float) {
        var builder = new SVGRectBuilder();
        builder.position(x, y);
        builder.size(width, height);
        builder.stroke(currentStrokeStyle);
        builder.fill(currentFillStyle);
        element.append(builder.element);
        return builder;
    }
    
    public function circle(x:Float, y:Float, r:Float) {
        var builder = new SVGCircleBuilder();
        builder.position(x, y);
        builder.radius(r);
        builder.stroke(currentStrokeStyle);
        builder.fill(currentFillStyle);
        element.append(builder.element);
        return builder;
    }
    
    public function text(value:String, x:Float, y:Float) {
        var builder = new SVGTextBuilder();
        builder.position(x, y);
        builder.value(value);
        builder.stroke(currentStrokeStyle);
        builder.fill(currentFillStyle);
        builder.font(currentFontStyle);
        element.append(builder.element);
        return builder;
    }
    
    public function path(x:Null<Float> = null, y:Null<Float> = null, absolute:Bool = true) {
        var builder = new SVGPathBuilder();
        if (x != null && y != null) {
            builder.moveTo(x, y, absolute);
        }
        element.append(builder.element);
        builder.stroke(currentStrokeStyle);
        builder.fill(currentFillStyle);
        return builder;
    }
    
    public function image(href:String, x:Null<Float> = null, y:Null<Float> = null, width:Null<Float> = null, height:Null<Float> = null) {
        var builder = new SVGImageBuilder();
        if (x != null && y != null) {
            builder.position(x, y);
        }
        if (width != null && height != null) {
            builder.size(width, height);
        }
        builder.href(href);
        element.append(builder.element);
        return builder;
    }
}
