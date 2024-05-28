package haxe.ui.backend.html5.graphics;

import haxe.ui.backend.ComponentGraphicsBase;
import haxe.ui.backend.html5.svg.SVGBuilder;
import haxe.ui.backend.html5.svg.SVGPathBuilder;
import haxe.ui.backend.html5.svg.SVGStrokeData;
import haxe.ui.backend.html5.svg.SVGFillData;
import haxe.ui.core.Component;
import haxe.ui.geom.Point;
import haxe.ui.loaders.image.ImageLoader;
import haxe.ui.util.Color;
import haxe.ui.util.Variant;

class SVGGraphicsImpl extends ComponentGraphicsBase {
    private var _svg:SVGBuilder = null;

    private var currentPath:SVGPathBuilder;
    
    public function new(component:Component) {
        super(component);
        createSVG();
    }
    
    public override function clear() {
        _svg.clear();
    }
    
    private var _currentPosition:Point = new Point();
    public override function moveTo(x:Float, y:Float) {
        if (currentPath != null)  {
            currentPath.moveTo(x, y);
        } else {
            _currentPosition.x = x;
            _currentPosition.y = y;
        }
    }
    
    public override function lineTo(x:Float, y:Float) {
        if (currentPath == null)  {
            _svg.line(_currentPosition.x, _currentPosition.y, x, y);
        } else {
            currentPath.lineTo(x, y);
        }
        _currentPosition.x = x;
        _currentPosition.y = y;
    }
    
    public override function strokeStyle(color:Null<Color>, thickness:Null<Float> = 1, alpha:Null<Float> = 1) {
        var currentStrokeStyle:SVGStrokeData = {};
        if (thickness != null) {
            currentStrokeStyle.thickness = thickness;
        }
        currentStrokeStyle.color = colorToRGBA(color, alpha);
        if (currentPath == null) {
            _svg.currentStrokeStyle = currentStrokeStyle;
        } else {
            currentPath.stroke(currentStrokeStyle);
        }
    }    
    
    public override function fillStyle(color:Null<Color>, alpha:Null<Float> = 1) {
        var currentFillStyle:SVGFillData = {};
        currentFillStyle.color = colorToRGBA(color, alpha);
        if (currentPath == null) {
            _svg.currentFillStyle = currentFillStyle;
        } else {
            currentPath.fill(currentFillStyle);
        }
    }
    
    public override function circle(x:Float, y:Float, radius:Float) {
        _svg.circle(x, y, radius);
    }
    
    public override function curveTo(controlX:Float, controlY:Float, anchorX:Float, anchorY:Float) {
        path().quadraticBezier(controlX, controlY, anchorX, anchorY);
        _currentPosition.x = anchorX;
        _currentPosition.y = anchorY;
    }
    
    public override function cubicCurveTo(controlX1:Float, controlY1:Float, controlX2:Float, controlY2:Float, anchorX:Float, anchorY:Float) {
        path().cubicBezier(controlX1, controlY1, controlX2, controlY2, anchorX, anchorY);
        _currentPosition.x = anchorX;
        _currentPosition.y = anchorY;
    }
    
    public override function rectangle(x:Float, y:Float, width:Float, height:Float) {
        _svg.rectangle(x, y, width, height);
    }
    
    public override function setPixel(x:Float, y:Float, color:Color) {
        strokeStyle(null);
        fillStyle(color);
        rectangle(x, y, 1, 1);
    }

    public override function beginPath() {
        closePath();
        currentPath = _svg.path(_currentPosition.x, _currentPosition.y);
    }

    public override function closePath() {
        if (currentPath != null) {
            currentPath.close();
        }
        currentPath = null;
    }

    private inline function path():SVGPathBuilder {
        if (currentPath != null) {
            return currentPath;
        }
        return _svg.path(_currentPosition.x, _currentPosition.y);
    }
    
    private inline function colorToRGBA(color:Null<Color>, alpha:Null<Float> = 1) {
        if (color != null) {
            if (alpha < 1) {
                return 'rgba(${color.r}, ${color.g}, ${color.b}, ${alpha})';
            } else {
                return 'rgb(${color.r}, ${color.g}, ${color.b})';
            }
        }
        return "none";
    }

    public override function image(resource:Variant, x:Null<Float> = null, y:Null<Float> = null, width:Null<Float> = null, height:Null<Float> = null) {
        ImageLoader.instance.load(resource, function(imageInfo) {
            if (imageInfo != null) {
                if (x == null) x = 0;
                if (y == null) y = 0;
                if (width == null) width = imageInfo.width;
                if (height == null) height = imageInfo.height;
                _svg.image(imageInfo.data.src, x, y, width, height);
            } else {
                trace("could not load: " + resource);
            }
        });
    }

    private function createSVG() {
        if (_component.element == null) {
            return;
        }
        
        var existingElements = _component.element.getElementsByTagNameNS("http://www.w3.org/2000/svg", "svg");
        var existingElement = null;
        if (existingElements.length > 0) {
            existingElements.item(0);
        }
        
        _svg = new SVGBuilder(existingElement);
        if (existingElement == null) {
            _component.element.appendChild(_svg.element);
        }
    }
    
    public override function resize(width:Null<Float>, height:Null<Float>) {
        _svg.size(width, height);
    }
    
    private override function detach() {
        _svg.element.remove();
        _svg = null;
    }
}