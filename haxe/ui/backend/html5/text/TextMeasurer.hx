package haxe.ui.backend.html5.text;

import haxe.ui.backend.html5.svg.SVGBuilder;
import js.Browser;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.DivElement;
import js.html.TextMetrics;

using StringTools;

typedef MeasureTextOptions = {
    var text:String;
    @:optional var width:Null<Float>;
    @:optional var fontFamily:String;
    @:optional var fontSize:String;
    @:optional var fontBold:Bool;
    @:optional var fontItalic:Bool;
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
    }

    public function measureText(options:MeasureTextOptions):{width:Float, height:Float} {
        if (_div == null) {
            _div = Browser.document.createDivElement();
            _div.style.position = "absolute";
            _div.style.top = "-99999px"; // position off-screen!
            _div.style.left = "-99999px"; // position off-screen!
            Browser.document.body.appendChild(_div);
        }
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

#if rapid_text_metrics
private class CanvasTextMeasurer extends DivTextMeasurer {
    // somewhat ported from: https://github.com/bezoerb/text-metrics

    private static var _canvas:CanvasElement = null;
    private static var _ctx:CanvasRenderingContext2D = null;
    private static var _lastOptions:MeasureTextOptions = null;
    private static var _lastResult:{width:Float, height:Float} = null;
    public function new() {
        super();
        if (_canvas == null) {
            _canvas = Browser.document.createCanvasElement();
            _canvas.style.position = "absolute";
            _canvas.style.top = "-99999px"; // position off-screen!
            _canvas.style.left = "-99999px"; // position off-screen!
            Browser.document.body.appendChild(_canvas);

            _ctx = _canvas.getContext2d();
            var dpr = Browser.window.devicePixelRatio != null ? Browser.window.devicePixelRatio : 1;
            var bsr = if (Reflect.hasField(_ctx, "webkitBackingStorePixelRatio")) {
                Reflect.field(_ctx, "webkitBackingStorePixelRatio");
            } else if (Reflect.hasField(_ctx, "mozBackingStorePixelRatio")) {
                Reflect.field(_ctx, "mozBackingStorePixelRatio");
            } else if (Reflect.hasField(_ctx, "msBackingStorePixelRatio")) {
                Reflect.field(_ctx, "msBackingStorePixelRatio");
            } else if (Reflect.hasField(_ctx, "oBackingStorePixelRatio")) {
                Reflect.field(_ctx, "oBackingStorePixelRatio");
            } else if (Reflect.hasField(_ctx, "backingStorePixelRatio")) {
                Reflect.field(_ctx, "backingStorePixelRatio");
            } else {
                1;
            }
            _ctx.setTransform(dpr / bsr, 0, 0, dpr / bsr, 0, 0);
        }
    }

    public override function measureText(options:MeasureTextOptions):{width:Float, height:Float} {
        if (_lastOptions != null && options.fontFamily == _lastOptions.fontFamily
                                 && options.fontSize == _lastOptions.fontSize
                                 && options.fontBold == _lastOptions.fontBold
                                 && options.fontItalic == _lastOptions.fontItalic
                                 && options.isHtml == _lastOptions.isHtml
                                 && options.text == _lastOptions.text
                                 && options.whiteSpace == _lastOptions.whiteSpace
                                 && options.width == _lastOptions.width
                                 && options.wordBreak == _lastOptions.wordBreak) {
                return _lastResult;
            }

        if (options.isHtml) {
            return super.measureText(options);
        }
        var normalizedText = normalizeText(options.text);
        _ctx.textBaseline = 'top';
        if (options.fontSize == null || options.fontSize == "") {
            options.fontSize = "13px";
        }

        if (normalizedText.trim() == "|" || normalizedText.trim() == "-") {
            normalizedText = "X";
            //return { width:0, height: Std.parseInt(options.fontSize) * 1.2};
        }

        var fontString = "";
        if (options.fontItalic) {
            fontString += "italic ";
        }
        if (options.fontBold) {
            fontString += "bold ";
        }
        fontString += options.fontSize + " " + options.fontFamily;
        _ctx.font = fontString;
        var tm:Dynamic = _ctx.measureText(normalizedText);

        var width = tm.width;
        var actualHeight = tm.actualBoundingBoxAscent + tm.actualBoundingBoxDescent;
        var fontHeight:Float = tm.fontBoundingBoxAscent + tm.fontBoundingBoxDescent;
        //fontHeight = Math.ceil(fontHeight);
        if (Math.isNaN(fontHeight)) {
            // fallback, fontBoundingBoxAscent / fontBoundingBoxDescent hidden behind a setting on FF... fun! 
            fontHeight = Std.parseInt(options.fontSize) * 1.2;
        }

        if (options.width != null) {
            var lines = computeLinesDefault(normalizedText, options.width);
            width = options.width;
            // original:
            // fontHeight = (lines.length * fontHeight) + lines.length;
            fontHeight = (lines.length * fontHeight);
        } else if (normalizedText.indexOf("\n") != -1) {
            var lines = computeLinesDefault(normalizedText, Std.int(0xffffff));
            var max:Float = 0;
            for (l in lines) {
                var t = _ctx.measureText(l);
                if (t.width > max) {
                    max = t.width;
                }
            }
            width = max;
            // original:
            // fontHeight = (lines.length * fontHeight) + lines.length;
            fontHeight = (lines.length * fontHeight);
        }

        width = Math.ceil(width);
        fontHeight = Math.ceil(fontHeight);

        _lastOptions = options;
        _lastResult = {width: width, height: fontHeight};

        return _lastResult;
    }

    private function normalizeText(text:String):String {
        return text.replace("_", " ");
    }

    private static function computeLinesDefault(text:String, max:Float):Array<String> {
        var lines = [];
        var parts = [];
        var breakpoints:Array<{chr:String, type:String}> = [];
        var line = "";
        var part = "";

        if (text == null || text.length == 0) {
            return [];
        }

        for (i in 0...text.length) {
            var chr = text.charAt(i);
            var type = checkBreak(chr);
            if (part == '' && type == 'BAI') {
                continue;
            }

            if (type != null) {
                breakpoints.push({chr: chr, type: type});
                parts.push(part);
                part = "";
            } else {
                part += chr;
            }
        }

        if (part != null && part.length > 0) {
            parts.push(part);
        }

        for (i in 0...parts.length) {
            var part = parts[i];
            if (i == 0) {
                line = part;
            }

            var breakpoint = breakpoints[i - 1];
            if (breakpoint == null) {
                continue;
            }
            // Special treatment as we only render the soft hyphen if we need to split
            var chr = breakpoint.type == 'SHY' ? '' : breakpoint.chr;
            if (breakpoint.type == 'BK') {
                lines.push(line);
                line = part;
                continue;
            }

            // Measure width
            var rawWidth = _ctx.measureText(line + chr + part).width;
            var width = Math.round(rawWidth);
            if (width <= max) {
                line += chr + part;
                continue;
            }

            // Line is to long, we split at the breakpoint
            switch (breakpoint.type) {
                case 'SHY':
                    lines.push(line + '-');
                    line = part;
                case 'BA':    
                    lines.push(line + chr);
                    line = part;
                case 'BAI':    
                    lines.push(line);
                    line = part;
                case 'BB':    
                    lines.push(line);
                    line = chr + part;
                case 'B2':    
                    if (_ctx.measureText(line + chr).width <= max) {
                        lines.push(line + chr);
                        line = part;
                    } else if (_ctx.measureText(chr + part).width <= max) {
                        lines.push(line);
                        line = chr + part;
                    } else {
                        lines.push(line);
                        lines.push(chr);
                        line = part;
                    }
                case _:
                    throw 'Undefined break';
            }
        }

        if (line.length > 0) {
            lines.push(line);
        }
        if (lines.length > 0) { 
            if (_ctx.measureText(lines[lines.length - 1]).width > max) { 
                lines.push(""); 
            } 
        }
        
        return lines;
    }

    /*
    B2  Break Opportunity Before and After  Em dash Provide a line break opportunity before and after the character
    BA  Break After Spaces, hyphens Generally provide a line break opportunity after the character
    BB  Break Before    Punctuation used in dictionaries    Generally provide a line break opportunity before the character
    HY  Hyphen  HYPHEN-MINUS    Provide a line break opportunity after the character, except in numeric context
    CB  Contingent Break Opportunity    Inline objects  Provide a line break opportunity contingent on additional information
    */

    // B2 Break Opportunity Before and After - http://www.unicode.org/reports/tr14/#B2
    private static var B2 = ['\u2014'];
    private static var SHY = ['\u00AD'];

    // BA: Break After (remove on break) - http://www.unicode.org/reports/tr14/#BA
    private static var BAI = [
        // Spaces
        '\u0020',
        '\u1680',
        '\u2000',
        '\u2001',
        '\u2002',
        '\u2003',
        '\u2004',
        '\u2005',
        '\u2006',
        '\u2008',
        '\u2009',
        '\u200A',
        '\u205F',
        '\u3000',
        // Tab
        '\u0009',
        // ZW Zero Width Space - http://www.unicode.org/reports/tr14/#ZW
        '\u200B',
        // Mandatory breaks not interpreted by html
        // orginally:
        //'\u2028',
        //'\u2029',
        // new, to fix issues with es5 and obsfucators
        //'\n',
        //'\r\n'
    ];

    private static var BA = [
        // Hyphen
        '\u058A',
        '\u2010',
        '\u2012',
        '\u2013',
        // Visible Word Dividers
        '\u05BE',
        '\u0F0B',
        '\u1361',
        '\u17D8',
        '\u17DA',
        '\u2027',
        '\u007C',
        // Historic Word Separators
        '\u16EB',
        '\u16EC',
        '\u16ED',
        '\u2056',
        '\u2058',
        '\u2059',
        '\u205A',
        '\u205B',
        '\u205D',
        '\u205E',
        '\u2E19',
        '\u2E2A',
        '\u2E2B',
        '\u2E2C',
        '\u2E2D',
        '\u2E30',
        '\u10100',
        '\u10101',
        '\u10102',
        '\u1039F',
        '\u103D0',
        '\u1091F',
        '\u12470',
    ];

    // BB: Break Before - http://www.unicode.org/reports/tr14/#BB
    private static var BB = ['\u00B4', '\u1FFD'];

    // BK: Mandatory Break (A) (Non-tailorable) - http://www.unicode.org/reports/tr14/#BK
    private static var BK = ['\u000A', '\n', '\r', '\r\n'];

    private static function checkBreak(chr:String):String {
        if (B2.indexOf(chr) != -1) {
            return "B2";
        } else if (BAI.indexOf(chr) != -1) {
            return "BAI";
        } else if (SHY.indexOf(chr) != -1) {
            return "SHY";
        } else if (BA.indexOf(chr) != -1) {
            return "BA";
        } else if (BB.indexOf(chr) != -1) {
            return "BB";
        } else if (BK.indexOf(chr) != -1) {
            return "BK";
        }
        return null;
    }
}

#end

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