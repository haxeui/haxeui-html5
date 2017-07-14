package haxe.ui.backend;

import haxe.Timer;
import haxe.ui.core.Component;
import haxe.ui.backend.html5.HtmlUtils;
import haxe.ui.styles.Style;
import js.Browser;
import js.html.CSSStyleDeclaration;
import js.html.Element;

class TextDisplayBase {
    private static var ADDED_FONTS:Map<String, String> = new Map<String, String>();

    public var element:Element;

    public var parentComponent:Component;

    public function new() {
        _multiline = false;

        element = createElement();
    }

    private var _text:String;
    private var _left:Float = 0;
    private var _top:Float = 0;
    private var _width:Float = -1;
    private var _height:Float = -1;
    private var _textWidth:Float = 0;
    private var _textHeight:Float = 0;
    private var _rawFontName:String;
    private var _textStyle:Style;
    private var _multiline:Bool = true;
    private var _wordWrap:Bool = false;

    private var _checkSizeTimer:Timer;
    private var _checkSizeCounter:Int = 0;
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

    //***********************************************************************************************************
    // Validation functions
    //***********************************************************************************************************

    private function validateData() {
        var html:String = normalizeText(_text);
        element.innerHTML = html;
    }

    private function validateStyle():Bool {
        var measureTextRequired:Bool = false;
        if (_wordWrap == true && element.style.whiteSpace != null) {
            element.style.removeProperty("white-space");
            measureTextRequired = true;
        } else if (_wordWrap == false && element.style.whiteSpace != "nowrap") {
            element.style.whiteSpace = "nowrap";
            measureTextRequired = true;
        }

        if (element.style.textAlign != _textStyle.textAlign) {
            element.style.textAlign = _textStyle.textAlign;
        }

        var fontSizeValue = HtmlUtils.px(_textStyle.fontSize);
        if (element.style.fontSize != fontSizeValue) {
            element.style.fontSize = fontSizeValue;
            measureTextRequired = true;
        }

        var colorValue = HtmlUtils.color(_textStyle.color);
        if (element.style.color != colorValue) {
            element.style.color = colorValue;
        }

        var fontName:String = _textStyle.fontName;
        if (fontName != _rawFontName) {
            var customFont:Bool = false;
            if (fontName.indexOf(".") != -1) {
                customFont = true;
                var cssName = fontName.split("/").pop();
                var n = cssName.lastIndexOf(".");
                if (n != -1) {
                    cssName = cssName.substring(0, n);
                }
                if (ADDED_FONTS.exists(fontName) == false) {
                    var css = '@font-face { font-family: "${cssName}"; src: url("${fontName}"); }';
                    var style = Browser.document.createElement("style");
                    Browser.document.head.appendChild(style);
                    style.innerHTML = css;
                    ADDED_FONTS.set(fontName, cssName);
                }

                fontName = cssName;
            }

            if (_rawFontName != fontName) {
                _rawFontName = fontName;

                element.style.fontFamily = _rawFontName;
                parentComponent.invalidateLayout();

                if (customFont == true) {
                    if (_checkSizeTimer == null) {
                        _originalSize = element.clientWidth;
                        _checkSizeTimer = new Timer(10);
                        _checkSizeTimer.run = checkSize;
                    }
                }
            }

            measureTextRequired = true;
        }

        return measureTextRequired;
    }

    private function validatePosition() {
        var style:CSSStyleDeclaration = element.style;
        style.left = HtmlUtils.px(_left - 1);
        style.top = HtmlUtils.px(_top - 1);
    }

    private function validateDisplay() {
        var style:CSSStyleDeclaration = element.style;
        if (_width > 0) {
            style.width = HtmlUtils.px(_width);
        }
        if (_height > 0) {
            style.height = HtmlUtils.px(_height);
        }
    }

    private function measureText() {
        if (HtmlUtils.DIV_HELPER == null) {
            HtmlUtils.createDivHelper();
        }

        var div = HtmlUtils.DIV_HELPER;
        setTempDivData(div);

        _textWidth = div.clientWidth + 2;
        _textHeight = div.clientHeight;
    }

    //***********************************************************************************************************
    // Util functions
    //***********************************************************************************************************

    private function createElement():Element {
        var el:Element = Browser.document.createDivElement();
        //el.style.display = "inline";
        el.style.position = "absolute";
        el.style.cursor = "inherit";

        return el;
    }

    private function setTempDivData(div:Element) {
        var t:String = _text;
        if (t == null || t.length == 0) {
            t = "|";
        }

        div.style.fontFamily = element.style.fontFamily;
        div.style.fontSize = element.style.fontSize;
        div.style.width = (_width > 0) ? '${HtmlUtils.px(_width)}' : "";
        div.innerHTML = normalizeText(t);
    }

    private function normalizeText(text:String):String {
        var html:String = HtmlUtils.escape(text);
        html = StringTools.replace(html, "\\n", "\n");
        html = StringTools.replace(html, "\r\n", "<br/>");
        html = StringTools.replace(html, "\r", "<br/>");
        html = StringTools.replace(html, "\n", "<br/>");
        return html;
    }
}
