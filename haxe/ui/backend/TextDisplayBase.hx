package haxe.ui.backend;

import haxe.ui.assets.FontInfo;
import haxe.ui.backend.html5.HtmlUtils;
import haxe.ui.core.Component;
import haxe.ui.core.TextDisplay.TextDisplayData;
import haxe.ui.styles.Style;
import js.Browser;
import js.html.CSSStyleDeclaration;
import js.html.Element;

class TextDisplayBase {
    private var _displayData:TextDisplayData = new TextDisplayData();

    public var element:Element;

    public var parentComponent:Component;

    public function new() {
        _displayData.multiline = false;

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

    private var _fontInfo:FontInfo;
    
    //***********************************************************************************************************
    // Validation functions
    //***********************************************************************************************************

    private function validateData() {
        var html:String = normalizeText(_text);
        element.innerHTML = html;
    }

    private function validateStyle():Bool {
        var measureTextRequired:Bool = false;
        
        if (_displayData.wordWrap == true && element.style.whiteSpace != null) {
            element.style.whiteSpace = "normal";
            measureTextRequired = true;
        } else if (_displayData.wordWrap == false && element.style.whiteSpace != "nowrap") {
            element.style.whiteSpace = "nowrap";
            measureTextRequired = true;
        }

        if (_textStyle != null) {
            if (element.style.textAlign != _textStyle.textAlign) {
                element.style.textAlign = _textStyle.textAlign;
            }

            var fontSizeValue = HtmlUtils.px(_textStyle.fontSize);
            if (element.style.fontSize != fontSizeValue) {
                element.style.fontSize = fontSizeValue;
                measureTextRequired = true;
            }

            if (_textStyle.fontBold == true && element.style.fontWeight != "bold") {
                element.style.fontWeight = "bold";
                measureTextRequired = true;
            }
            
            if (_textStyle.fontItalic == true && element.style.fontStyle != "italic") {
                element.style.fontStyle = "italic";
                measureTextRequired = true;
            }
            
            if (_textStyle.fontUnderline == true && element.style.textDecoration != "underline") {
                element.style.textDecoration = "underline";
                measureTextRequired = true;
            }
            
            var colorValue = HtmlUtils.color(_textStyle.color);
            if (element.style.color != colorValue) {
                element.style.color = colorValue;
            }

            if (_fontInfo != null && _fontInfo.data != _rawFontName) {
                element.style.fontFamily = _fontInfo.data;
                _rawFontName = _fontInfo.data;
                measureTextRequired = true;
                parentComponent.invalidateLayout();
            }
        }

        return measureTextRequired;
    }

    private function validatePosition() {
        var style:CSSStyleDeclaration = element.style;
        style.left = HtmlUtils.px(_left);
        style.top = HtmlUtils.px(_top);
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
