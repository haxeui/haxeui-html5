package haxe.ui.backend;

import haxe.ui.backend.html5.HtmlUtils;
import haxe.ui.backend.html5.text.TextMeasurer;
import haxe.ui.components.Label;
import js.Browser;
import js.html.CSSStyleDeclaration;
import js.html.Element;

#if cache_text_metrics
typedef TextMetricsCache = {
    var text:String;
    var width:Float;
    var textWidth:Float;
    var textHeight:Float;
}
#end

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
    private var _isHTML:Bool = false;
    private override function validateData() {
        var html:String = null;
        if (_text != null) {
            html = normalizeText(_text);
            _isHTML = false;
        } else if (_htmlText != null) {
            html = normalizeHtmlText(_htmlText, false);
            _isHTML = true;
        }
        if (html != null && _html != html) {
            if (_isHTML == false) {
                element.textContent = html;
            } else {
                element.innerHTML = html;
            }

            _html = html;
            if (autoWidth == true) {
                _fixedWidth = false;
            }
            if (autoHeight == true) {
                _fixedHeight = false;
            }
        }
    }

    private var _rawFontName:String;
    private override function validateStyle():Bool {
        var measureTextRequired:Bool = false;
        if (_displayData.wordWrap == true && element.style.whiteSpace != null) {
            element.style.whiteSpace = "pre-wrap";
            element.style.wordBreak = "break-word";
            measureTextRequired = true;
        } else if (_displayData.wordWrap == false && element.style.whiteSpace != "pre") {
            element.style.whiteSpace = "pre";
            measureTextRequired = true;
        }

        if (_displayData.selectable == true && element.style.userSelect != "text") {
            element.style.userSelect = "text";
        } else if (_displayData.selectable == false && element.style.userSelect != null) {
            element.style.removeProperty("user-select");
            element.style.userSelect = null;
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
            } else if ((_textStyle.fontBold == null || _textStyle.fontBold == false) && element.style.fontWeight == "bold") {
                element.style.removeProperty("font-weight");
                measureTextRequired = true;
            }
            
            if (_textStyle.fontItalic == true && element.style.fontStyle != "italic") {
                element.style.fontStyle = "italic";
                measureTextRequired = true;
            } else if ((_textStyle.fontItalic == null || _textStyle.fontItalic == false) && element.style.fontStyle == "italic") {
                element.style.removeProperty("font-style");
                measureTextRequired = true;
            }
            
            if (_textStyle.fontUnderline == true && element.style.textDecoration != "underline") {
                element.style.textDecoration = "underline";
                measureTextRequired = true;
            } else if ((_textStyle.fontUnderline == null || _textStyle.fontUnderline == false) && element.style.textDecoration == "underline") {
                element.style.removeProperty("text-decoration");
                measureTextRequired = true;
            }
            
            if (_textStyle.fontStrikeThrough == true && element.style.textDecoration != "line-through") {
                element.style.textDecoration = "line-through";
                measureTextRequired = true;
            } else if ((_textStyle.fontStrikeThrough == null || _textStyle.fontStrikeThrough == false) && element.style.textDecoration == "line-through") {
                element.style.removeProperty("text-decoration");
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
            if (autoWidth == true) {
                _fixedWidth = false;
            }
            if (autoHeight == true) {
                _fixedHeight = false;
            }
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
        if (_height > 0 && autoHeight == false) {
            _fixedHeight = true;
            style.height = HtmlUtils.px(_height);
        }
        if (allowFixed == false) {
            _fixedHeight = false;
        }

        if (parentComponent != null && parentComponent.style != null) {
            if (parentComponent.style.borderLeftSize != null && parentComponent.style.borderLeftSize > 0) {
                style.marginLeft = '-${parentComponent.style.borderLeftSize - 1}px';
            }
            if (parentComponent.style.borderTopSize != null && parentComponent.style.borderTopSize > 0) {
                style.marginTop = '-${parentComponent.style.borderTopSize - 1}px';
            }
        }
    }

    #if cache_text_metrics
    private var _cachedMetrics:TextMetricsCache = null;
    #end
    private override function measureText() {
        if (_fixedWidth == true && _fixedHeight == true) {
            return;
        }

        #if cache_text_metrics
        if (_cachedMetrics != null) {
            if (_cachedMetrics.width == _width && _cachedMetrics.text == _text) {
                _textWidth = _cachedMetrics.textWidth;
                _textHeight = _cachedMetrics.textHeight;
                return;
            }
        }
        #end

        var t:String = null;
        var isHtml = false;
        if (_text != null) {
            t = normalizeText(_text);
        } else if (_htmlText != null) {
            t = normalizeHtmlText(_htmlText, false);
            isHtml = true;
        }
        if (t == null || t.length == 0) {
            t = "|";
        }
        var w = null;
        if (autoWidth == false) {
            w = (_width > 0) ? _width : null;
        }
        var size = TextMeasurer.instance.measureText({
            text: t,
            width: w,
            fontFamily: element.style.fontFamily,
            fontSize: element.style.fontSize,
            fontBold: (element.style.fontWeight == "bold"),
            fontItalic: (element.style.fontStyle == "italic"),
            whiteSpace: element.style.whiteSpace,
            wordBreak: element.style.wordBreak,
            isHtml: isHtml
        });

        if (_fixedWidth == false) {
            _textWidth = size.width + 2;
        }
        if (_fixedHeight == false) {
            _textHeight = size.height + 2;
        }

        #if cache_text_metrics
        _cachedMetrics = {
            text: _text,
            width: _width,
            textWidth: _textWidth,
            textHeight: _textHeight
        }
        #end
    }

    //***********************************************************************************************************
    // Util functions
    //***********************************************************************************************************

    private function createElement():Element {
        var el:Element = Browser.document.createDivElement();
        //el.style.display = "inline";
        el.style.marginTop = "1px";
        el.style.marginLeft = "1px";
        el.style.position = "absolute";
        el.style.cursor = "inherit";
        //el.style.lineHeight = "1em";

        return el;
    }

    private function normalizeText(text:String):String {
        text = StringTools.replace(text, "\\n", "\n");
        return text;
    }
    
    private function normalizeHtmlText(text:String, escape:Bool = true):String {
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
    
    private var autoHeight(get, null):Bool;
    private function get_autoHeight():Bool {
        if ((parentComponent is Label)) {
            return cast(parentComponent, Label).autoHeight;
        }
        return false;
    }
    
    private override function get_supportsHtml():Bool {
        return true;
    }
}
