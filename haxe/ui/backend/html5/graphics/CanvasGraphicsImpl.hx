package haxe.ui.backend.html5.graphics;

import haxe.io.Bytes;
import haxe.ui.backend.ComponentGraphicsBase;
import haxe.ui.core.Component;
import haxe.ui.util.Color;
import js.Browser;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.ImageData;

class CanvasGraphicsImpl extends ComponentGraphicsBase {
    private var _canvas:CanvasElement = null;
    private var _ctx:CanvasRenderingContext2D = null;
    private var _hasSize:Bool = false;
    
    public function new(component:Component) {
        super(component);
        createCanvas();
    }
    
    public override function fillStyle(color:Null<Color>, alpha:Null<Float> = 1) {
        if (_hasSize == false) {
            return super.fillStyle(color, alpha);
        }
        _ctx.fillStyle = 'rgb(${color.r}, ${color.g}, ${color.b})';
    }
    
    public override function rectangle(x:Float, y:Float, width:Float, height:Float) {
        if (_hasSize == false) {
            return super.rectangle(x, y, width, height);
        }
        _ctx.fillRect(x, y, width, height);
    }

    public override function setPixel(x:Float, y:Float, color:Color) {
        if (_hasSize == false) {
            return super.setPixel(x, y, color);
        }
        _ctx.fillStyle = 'rgb(${color.r}, ${color.g}, ${color.b})';
        _ctx.fillRect(x, y, 1, 1);
    }

    private function createCanvas() {
        if (_component.element == null) {
            return;
        }
        
        _canvas = Browser.document.createCanvasElement();
        _component.element.appendChild(_canvas);
        
        _ctx = _canvas.getContext2d();
    }
    
    public override function setPixels(pixels:Bytes) {
        if (_hasSize == false) {
            return super.setPixels(pixels);
        }
        
        #if (haxe_ver < 4.0)
        var imageData = new ImageData(new js.html.Uint8ClampedArray(pixels.getData()), _ctx.canvas.width, _ctx.canvas.height);
        #else
        var imageData = new ImageData(new js.lib.Uint8ClampedArray(pixels.getData()), _ctx.canvas.width, _ctx.canvas.height);
        #end
        
        /*
        var imageData = _ctx.createImageData(_ctx.canvas.width, _ctx.canvas.height);
        for (y in 0..._ctx.canvas.height) {
            for (x in 0..._ctx.canvas.width) {
                var i = y * (_ctx.canvas.width * 4) + x * 4;
                imageData.data[i + 0] = pixels.get(i + 0);
                imageData.data[i + 1] = pixels.get(i + 1);
                imageData.data[i + 2] = pixels.get(i + 2);
                imageData.data[i + 3] = pixels.get(i + 3);
            }
        }
        */
        _ctx.putImageData(imageData, 0, 0);
    }
    
    public override function resize(width:Null<Float>, height:Null<Float>) {
        _canvas.width = Std.int(width);
        _canvas.height = Std.int(height);
        if (width > 0 && height > 0) {
            if (_hasSize == false) {
                _hasSize = true;
                replayDrawCommands();
            }
        }
    }
    
    private override function detach() {
        _canvas.remove();
        _canvas = null;
        _ctx = null;
    }
}