package haxe.ui.backend;
import haxe.io.Bytes;
import haxe.ui.core.Component;
import haxe.ui.util.Color;
import haxe.ui.util.Variant;

class ComponentGraphicsImpl extends ComponentGraphicsBase {    
    private var _impl:ComponentGraphicsBase;
    
    public function new(component:Component) {
        super(component);
        _impl = new haxe.ui.backend.html5.graphics.SVGGraphicsImpl(component);
    }
    
    public override function clear() {
        _impl.clear();
    }
    
    public override function setPixel(x:Float, y:Float, color:Color) {
        _impl.setPixel(x, y, color);
    }
    
    public override function setPixels(pixels:Bytes) {
        _impl.setPixels(pixels);
    }
    
    public override function moveTo(x:Float, y:Float) {
        _impl.moveTo(x, y);
    }
    
    public override function lineTo(x:Float, y:Float) {
        _impl.lineTo(x, y);
    }
    
    public override function strokeStyle(color:Null<Color>, thickness:Null<Float> = 1, alpha:Null<Float> = 1) {
        _impl.strokeStyle(color, thickness, alpha);
    }    
    
    public override function fillStyle(color:Null<Color>, alpha:Null<Float> = 1) {
        _impl.fillStyle(color, alpha);
    }
    
    public override function circle(x:Float, y:Float, radius:Float) {
        _impl.circle(x, y, radius);
    }
    
    public override function curveTo(controlX:Float, controlY:Float, anchorX:Float, anchorY:Float) {
        _impl.curveTo(controlX, controlY, anchorX, anchorY);
    }
    
    public override function cubicCurveTo(controlX1:Float, controlY1:Float, controlX2:Float, controlY2:Float, anchorX:Float, anchorY:Float) {
        _impl.cubicCurveTo(controlX1, controlY1, controlX2, controlY2, anchorX, anchorY);
    }
    
    public override function rectangle(x:Float, y:Float, width:Float, height:Float) {
        _impl.rectangle(x, y, width, height);
    }
    
    public override function image(resource:Variant, x:Null<Float> = null, y:Null<Float> = null, width:Null<Float> = null, height:Null<Float> = null) {
        _impl.image(resource, x, y, width, height);
    }
    
    public override function resize(width:Null<Float>, height:Null<Float>) {
        _impl.resize(width, height);
    }
    
    public override function setProperty(name:String, value:String) {
        if (name == "html5.graphics.method") {
            if (value == "svg") {
                if (_impl != null) {
                    _impl.detach();
                }
                _impl = new haxe.ui.backend.html5.graphics.SVGGraphicsImpl(_component);
            } else if (value == "canvas") {
                if (_impl != null) {
                    _impl.detach();
                }
                _impl = new haxe.ui.backend.html5.graphics.CanvasGraphicsImpl(_component);
            }
        } else {
            _impl.setProperty(name, value);
        }
    }
}