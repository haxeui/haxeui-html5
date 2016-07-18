package haxe.ui.backend;

import haxe.Timer;
import haxe.ui.core.Component;
import haxe.ui.backend.html5.HtmlUtils;
import js.Browser;
import js.html.CSSStyleDeclaration;
import js.html.DivElement;

class TextDisplayBase {
    public var element:DivElement;

    public var parentComponent:Component;

    public function new() {
        element = Browser.document.createDivElement();
        //element.style.display = "inline";
        element.style.position = "absolute";
        element.style.cursor = "default";
    }

    private var _text:String;
    public var text(get, set):String;
    private function get_text():String {
        return element.innerHTML;
    }
    private function set_text(value:String):String {
        if (value == _text) {
            return value;
        }

        element.innerHTML = value;
        _text = value;
        measureText();
        return value;
    }

    private var _left:Float = 0;
    public var left(get, set):Float;
    private function get_left():Float {
        return _left;
    }
    private function set_left(value:Float):Float {
        if (value == _left) {
            return value;
        }

        _left = value;
        updatePos();
        return value;
    }

    private var _top:Float = 0;
    public var top(get, set):Float;
    private function get_top():Float {
        return _top;
    }
    private function set_top(value:Float):Float {
        if (value == _top) {
            return value;
        }

        _top = value;
        updatePos();
        return value;
    }

    private var _width:Float = -1;
    public var width(get, set):Float;
    public function set_width(value:Float):Float {
        if (_width == value) {
            return value;
        }
        _width = value;
        updateSize();
        return value;
    }

    public function get_width():Float {
        return _width;
    }

    private var _height:Float = -1;
    public var height(get, set):Float;
    public function set_height(value:Float):Float {
        if (_height == value) {
            return value;
        }
        _height = value;
        updateSize();
        return value;
    }

    public function get_height() {
        return _height;
    }

    private var _textWidth:Float = 0;
    public var textWidth(get, null):Float;
    private function get_textWidth():Float {
        return _textWidth;
    }

    private var _textHeight:Float = 0;
    public var textHeight(get, null):Float;
    private function get_textHeight():Float {
        return _textHeight;
        /*
        if (element.offsetHeight > _textHeight) {
            return element.offsetHeight;
        }
        return _textHeight;
        */
    }

    private var _color:Int;
    public var color(get, set):Int;
    private function get_color():Int {
        return _color;
    }
    private function set_color(value:Int):Int {
        if (_color == value) {
            return value;
        }

        _color = value;
        element.style.color = HtmlUtils.color(_color);

        return value;
    }

    private static var ADDED_FONTS:Map<String, String> = new Map<String, String>();

    private var _rawFontName:String;
    private var _fontName:String;
    public var fontName(get, set):String;
    private function get_fontName():String {
        return _fontName;
    }
    private function set_fontName(value:String):String {
        if (_rawFontName == value) {
            measureText();
            return value;
        }
        _rawFontName = value;

        // TODO: probably a better way to do all this
        var customFont:Bool = false;
        if (value.indexOf(".") != -1) {
            customFont = true;
            var cssName = value.split("/").pop();
            var n = cssName.lastIndexOf(".");
            if (n != -1) {
                cssName = cssName.substring(0, n);
            }
            if (ADDED_FONTS.exists(value) == false) {
                var css = '@font-face { font-family: "${cssName}"; src: url("${value}"); }';
                var style = Browser.document.createElement("style");
                Browser.document.head.appendChild(style);
                style.innerHTML = css;
                ADDED_FONTS.set(value, cssName);
            }

            value = cssName;
        }

        if (_fontName == value) {
            measureText();
            return value;
        }
        _fontName = value;

        element.style.fontFamily = _fontName;
        measureText();
        //parentComponent.invalidate();
        parentComponent.invalidateLayout();

        if (customFont == true) {
            if (_checkSizeTimer == null) {
                _originalSize = element.clientWidth;
                _checkSizeTimer = new Timer(10);
                _checkSizeTimer.run = checkSize;
            }
        }

        return value;
    }

    private var _checkSizeTimer:Timer;
    private var _checkSizeCounter = 0;
    private var _originalSize:Float = 0;
    private function checkSize() {
        if (element.clientWidth != _originalSize) {
            _checkSizeCounter = 0;
            //parentComponent.invalidate();
            _checkSizeTimer.stop();
            _checkSizeTimer = null;
            return;
        }

        _checkSizeCounter++;
        if (_checkSizeCounter >= 50) {
            _checkSizeCounter = 0;
            //parentComponent.invalidate();
            _checkSizeTimer.stop();
            _checkSizeTimer = null;
            return;
        }

    }

    private var _fontSize:Float;
    public var fontSize(get, set):Null<Float>;
    private function get_fontSize():Null<Float> {
        return _fontSize;
    }
    private function set_fontSize(value:Null<Float>):Null<Float> {
        if (_fontSize == value) {
            return value;
        }
        _fontSize = value;
        element.style.fontSize = value + "px";
        measureText();
        return value;
    }

    //***********************************************************************************************************
    // Util functions
    //***********************************************************************************************************
    private function updatePos() {
        var style:CSSStyleDeclaration = element.style;
        style.left = HtmlUtils.px(_left);
        style.top = HtmlUtils.px(_top);
    }


    private function updateSize() {
        var style:CSSStyleDeclaration = element.style;
        if (width > 0) {
            style.width = HtmlUtils.px(width);
        }
        if (height > 0) {
            style.height = HtmlUtils.px(height);
        }
    }

    private function measureText() {
        var t:String = _text;
        if (t == null || t.length == 0) {
            t = " ";
        }

        var div = Browser.document.createElement("div");
        div.style.fontFamily = element.style.fontFamily;
        div.style.fontSize = element.style.fontSize;
        div.innerHTML = t;
        div.style.position = "absolute";
        div.style.top = "-99999px"; // position off-screen!
        div.style.left = "-99999px"; // position off-screen!
        Browser.document.body.appendChild(div);

        _textWidth = div.clientWidth + 2;
        _textHeight = div.clientHeight - 1;
        //div.remove();
        HtmlUtils.removeElement(div);
    }
}
