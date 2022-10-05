package haxe.ui.backend.html5.text;

import haxe.ui.backend.html5.svg.SVGBuilder;
import js.Browser;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.DivElement;
import js.html.TextMetrics;

typedef MeasureTextOptions = {
    var text:String;
    @:optional var width:Null<Float>;
    @:optional var fontFamily:String;
    @:optional var fontSize:String;
    @:optional var whiteSpace:String;
    @:optional var wordBreak:String;
    @:optional var isHtml:Bool;
}

interface ITextMeasurer {
    function measureText(options:MeasureTextOptions):{width:Float, height:Float};
}

private class DivTextMeasurer implements ITextMeasurer {
    private var _div:DivElement = null;

    public function new() {
        _div = Browser.document.createDivElement();
        _div.style.position = "absolute";
        _div.style.top = "-99999px"; // position off-screen!
        _div.style.left = "-99999px"; // position off-screen!
        Browser.document.body.appendChild(_div);
    }

    public function measureText(options:MeasureTextOptions):{width:Float, height:Float} {
        _div.style.fontFamily = options.fontFamily;
        _div.style.fontSize = options.fontSize;
        _div.style.whiteSpace = options.whiteSpace;
        _div.style.wordBreak = options.wordBreak;
        if (options.width != null) {
            _div.style.width = HtmlUtils.px(options.width);
        } else {
            _div.style.width = "";
        }

        if (options.isHtml == false) {
            _div.textContent = options.text;
        } else {
            _div.innerHTML = options.text;
        }

        return {width: _div.clientWidth, height: _div.clientHeight};
    }
}

private class CanvasTextMeasurer implements ITextMeasurer {
    private static var _canvas:CanvasElement = null;
    private static var _ctx:CanvasRenderingContext2D = null;
    public function new() {
        if (_canvas == null) {
            _canvas = Browser.document.createCanvasElement();
            _canvas.style.position = "absolute";
            _canvas.style.top = "-99999px"; // position off-screen!
            _canvas.style.left = "-99999px"; // position off-screen!
            Browser.document.body.appendChild(_canvas);

            _ctx = _canvas.getContext2d();
        }
    }

    public function measureText(options:MeasureTextOptions):{width:Float, height:Float} {
        _ctx.textBaseline = 'top';
        if (options.fontSize == null || options.fontSize == "") {
            options.fontSize = "13px";
        }

        _ctx.font = options.fontSize + " " + options.fontFamily;
        var tm:Dynamic = _ctx.measureText(options.text);

        var width = tm.width;
        var actualHeight = tm.actualBoundingBoxAscent + tm.actualBoundingBoxDescent;
        var fontHeight:Float = tm.fontBoundingBoxAscent + tm.fontBoundingBoxDescent;
        //fontHeight = Math.ceil(fontHeight);
        if (options.width != null) {
            var lines = splitLines(options.text, Std.int(options.width));
            width = options.width;
            fontHeight = (lines.length * fontHeight) + lines.length;
        }

        width = Math.ceil(width);
        fontHeight = Math.ceil(fontHeight);
        return {width: width, height: fontHeight};
        //return null;
    }

    private function splitLines(text:String, maxWidth:Int):Array<String> {
        var lines = new Array<String>();
        var inputLines = text.split("\n");
        var biggestWidth:Float = 0;
        for (line in inputLines) {
            var tw = Math.ceil(_ctx.measureText(line).width);
            if (tw > maxWidth) {
                var words = Lambda.list(line.split(" "));
                while (!words.isEmpty()) {
                    line = words.pop();
                    tw = Math.ceil(_ctx.measureText(line).width);
                    biggestWidth = Math.max(biggestWidth, tw);
                    var nextWord = words.pop();
                    while (nextWord != null && (tw = Math.ceil(_ctx.measureText(line + " " + nextWord).width)) <= maxWidth) {
                        biggestWidth = Math.max(biggestWidth, tw);
                        line += " " + nextWord;
                        nextWord = words.pop();
                    }
                    lines.push(line);
                    if (nextWord != null) {
                        words.push(nextWord);
                    }
                }
            } else {
                biggestWidth = Math.max(biggestWidth, tw);
                if (line != '') {
                    lines.push(line);
                }
            }
        } 
        return lines;
    }
}

class TextMeasurer {
    private static var _instance:ITextMeasurer = null;
    public static var instance(get, null):ITextMeasurer;
    private static function get_instance():ITextMeasurer {
        if (_instance == null) {
            #if rapid_text_metrics
            _instance = new CanvasTextMeasurer();
            #else
            _instance = new DivTextMeasurer();
            #end
        }
        return _instance;
    }
}