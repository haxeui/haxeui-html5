package haxe.ui.backend;

import haxe.ui.backend.html5.HtmlUtils;
import haxe.ui.components.Label;
import js.Browser;
import js.html.CSSStyleDeclaration;
import js.html.Element;

class TextDisplayImpl extends TextBase {
    public var element:Element;

    public function new() {
        super();
        _displayData.multiline = false;
        element = createElement();
    }

    //***********************************************************************************************************
    // Validation functions
    //***********************************************************************************************************

    private var _html:String;
    private override function validateData() {
        var html:String = null;
        if (_text != null) {
            html = normalizeText(_text);
        } else if (_htmlText != null) {
            html = normalizeText(_htmlText, false);
        }
        if (html != null && _html != html) {
            element.innerHTML = html;
            _html = html;
            if (autoWidth == false) {
                _fixedWidth = false;
                _fixedHeight = false;
            }
        }
    }

    private var _rawFontName:String;
    private override function validateStyle():Bool {
        var measureTextRequired:Bool = false;
        if (_displayData.wordWrap == true && element.style.whiteSpace != null) {
            element.style.whiteSpace = "normal";
            element.style.wordBreak = "break-word";
            measureTextRequired = true;
        } else if (_displayData.wordWrap == false && element.style.whiteSpace != "pre") {
            element.style.whiteSpace = "pre";
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
                parentComponent.invalidateComponentLayout();
            }
        }

        if (measureTextRequired == true) {
            _fixedWidth = false;
            _fixedHeight = false;
        }
        
        return measureTextRequired;
    }

    private override function validatePosition() {
        var style:CSSStyleDeclaration = element.style;
        style.left = HtmlUtils.px(_left);
        style.top = HtmlUtils.px(_top);
    }

    private var _fixedWidth:Bool = false;
    private var _fixedHeight:Bool = false;
    private override function validateDisplay() {
        var style:CSSStyleDeclaration = element.style;
        var allowFixed = true;
        if (autoWidth == false && style.width != HtmlUtils.px(_width)) {
            allowFixed = false;
        }
        if (_width > 0 && autoWidth == false) {
            _fixedWidth = true;
            style.width = HtmlUtils.px(_width);
        }
        if (_height > 0 && autoWidth == false) {
            _fixedHeight = true;
            style.height = HtmlUtils.px(_height);
        }
        if (allowFixed == false) {
            _fixedHeight = false;
        }
    }

    private override function measureText() {
        if (_fixedWidth == true && _fixedHeight == true) {
            return;
        }
        if (HtmlUtils.DIV_HELPER == null) {
            HtmlUtils.createDivHelper();
        }

        var div = HtmlUtils.DIV_HELPER;
        setTempDivData(div);

        if (_fixedWidth == false) {
            _textWidth = div.clientWidth;
        }
        if (_fixedHeight == false) {
            _textHeight = div.clientHeight;
        }
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
        var t:String = null;
        if (_text != null) {
            t = normalizeText(_text);
        } else if (_htmlText != null) {
            t = normalizeText(_htmlText, false);
        }
        if (t == null || t.length == 0) {
            t = "|";
        }

        div.style.fontFamily = element.style.fontFamily;
        div.style.fontSize = element.style.fontSize;
        div.style.whiteSpace = element.style.whiteSpace;
        div.style.wordBreak = element.style.wordBreak;
        if (autoWidth == false) {
            div.style.width = (_width > 0) ? '${HtmlUtils.px(_width)}' : "";
        } else {
            div.style.width = "";
        }
        div.innerHTML = t;
    }

    private function normalizeText(text:String, escape:Bool = true):String {
        var html = text;
        if (escape == true) {
            html = HtmlUtils.escape(text);
        }
        html = StringTools.replace(html, "\\n", "\n");
        html = StringTools.replace(html, "\r\n", "<br/>");
        html = StringTools.replace(html, "\r", "<br/>");
        html = StringTools.replace(html, "\n", "<br/>");
        return html;
    }
    
    private var autoWidth(get, null):Bool;
    private function get_autoWidth():Bool {
        if ((parentComponent is Label)) {
            return cast(parentComponent, Label).autoWidth;
        }
        return false;
    }
    
    private override function get_supportsHtml():Bool {
        return true;
    }
    
    
    public override function measureTextWidth():Float {
        if (HtmlUtils.DIV_HELPER == null) {
            HtmlUtils.createDivHelper();
        }

        var div = HtmlUtils.DIV_HELPER;
        setTempDivData(div);
        div.style.width = "";
     
        return div.clientWidth;
    }
}
