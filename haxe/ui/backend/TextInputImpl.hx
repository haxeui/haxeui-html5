package haxe.ui.backend;

import haxe.ui.backend.html5.HtmlUtils;
import js.Browser;
import js.html.CSSStyleDeclaration;
import js.html.Element;
import js.html.InputElement;
import js.html.TextAreaElement;

class TextInputImpl extends TextDisplayImpl {
    public override function focus() {
        #if (haxe_ver >= 4)
        js.Syntax.code('{0}.focus({preventScroll: true})', element);
        #else
        untyped __js__('{0}.focus({preventScroll: true})', element);
        #end
        //element.focus();
    }
    
    public override function blur() {
        element.blur();
    }
    
    private function onChangeEvent(e) {
        var newText = null;
        if ((element is TextAreaElement)) {
            newText = cast(element, TextAreaElement).value;
        } else {
            newText = cast(element, InputElement).value;
        }
        
        if (newText != _text) {
            _text = newText;
            measureText();
            if (_inputData.onChangedCallback != null) {
                _inputData.onChangedCallback();
            }
        }
    }

    private function onScroll(e) {
        _inputData.hscrollPos = element.scrollLeft;
        _inputData.vscrollPos = element.scrollTop;
        
        _inputData.hscrollMax = _textWidth - _width;
        _inputData.hscrollPageSize = (_width * _inputData.hscrollMax) / _textWidth;
        
        _inputData.vscrollMax = _textHeight - _height;
        _inputData.vscrollPageSize = (_height * _inputData.vscrollMax) / _textHeight;
        
        if (_inputData.onScrollCallback != null) {
            _inputData.onScrollCallback();
        }
    }
    
    //***********************************************************************************************************
    // Validation functions
    //***********************************************************************************************************

    private override function validateData() {
        if (_text != null) {
            var html:String = normalizeText(_text);
            if ((element is InputElement)) {
                cast(element, InputElement).value = html;
            } else if ((element is TextAreaElement)) {
                cast(element, TextAreaElement).value = html;
            }
        }
        
        var hscrollValue = Std.int(_inputData.hscrollPos);
        if (element.scrollLeft != hscrollValue) {
            element.scrollLeft = hscrollValue;
        }

        var vscrollValue = Std.int(_inputData.vscrollPos);
        if (element.scrollTop != vscrollValue) {
            element.scrollTop = vscrollValue;
        }
    }

    @:access(haxe.ui.core.Component)
    private override function validateStyle():Bool {
        var measureTextRequired:Bool = false;

        if ((_displayData.multiline == false && (element is InputElement) == false)
            || (_displayData.multiline == true && (element is TextAreaElement) == false)) {
            var newElement:Element = createElement();
            element.parentElement.appendChild(newElement);
            HtmlUtils.removeElement(element);

            element.removeEventListener("input", onChangeEvent);
            element.removeEventListener("propertychange", onChangeEvent);
            element.removeEventListener("scroll", onScroll);

            element = newElement;
            validateData();

            measureTextRequired = true;
        }

        if ((element is InputElement)) {
            var inputElement:InputElement = cast element;
            if (_inputData.password == true && inputElement.type != "password") {
                inputElement.type = "password";
            } else if (_inputData.password == false && inputElement.type != "") {
                inputElement.type = "";
            }
        }
        
        if (parentComponent.disabled || parentComponent._interactivityDisabled == true) { // TODO: bit of a haxeui builder hack here, not ideal, but for now its fine
            #if !haxeui_builder
            element.style.cursor = "not-allowed";
            #end
            if ((element is InputElement)) {
                cast(element, InputElement).disabled = true;
            } else if ((element is TextAreaElement)) {
                cast(element, TextAreaElement).disabled = true;
            }
        } else {
            element.style.cursor = null;
            if ((element is InputElement)) {
                cast(element, InputElement).disabled = false;
            } else if ((element is TextAreaElement)) {
                cast(element, TextAreaElement).disabled = false;
            }
        }
        
        return super.validateStyle() || measureTextRequired;
    }

    private override function measureText() {
        var div = HtmlUtils.getDivHelper("haxeui-text-input-div-helper");
        setTempDivData(div);
        HtmlUtils.releaseDivHelper(div);

        _textWidth = div.clientWidth;
        _textHeight = div.clientHeight + 2;
        
        _inputData.hscrollMax = _textWidth - _width;
        _inputData.hscrollPageSize = (_width * _inputData.hscrollMax) / _textWidth;
        
        _inputData.vscrollMax = _textHeight - _height;
        _inputData.vscrollPageSize = (_height * _inputData.vscrollMax) / _textHeight;
    }

    private var _selectionStartIndex:Int = 0;
    private override function get_selectionStartIndex():Int {
        return _selectionStartIndex;
    }
    private override function set_selectionStartIndex(value:Int):Int {
        _selectionStartIndex = value;
        applySelection();
        return value;
    }
    
    private var _selectedEndIndex = -1;
    private override function get_selectionEndIndex():Int {
        return _selectedEndIndex;
    }
    private override function set_selectionEndIndex(value:Int):Int {
        _selectedEndIndex = value;
        applySelection();
        return value;
    }
    
    private function applySelection() {
        if (_selectionStartIndex < 0 || _selectedEndIndex < 0) {
            return;
        }
        
        if (_text != null && _selectedEndIndex > _text.length) {
            _selectedEndIndex = _text.length;
        }
        
        if ((element is InputElement)) {
            cast(element, InputElement).setSelectionRange(_selectionStartIndex, _selectedEndIndex);
        } else if ((element is TextAreaElement)) {
            cast(element, TextAreaElement).setSelectionRange(_selectionStartIndex, _selectedEndIndex);
        }
    }
    
    //***********************************************************************************************************
    // Util functions
    //***********************************************************************************************************

    private override function createElement():Element {
        if (element != null) {
            element.removeEventListener("input", onChangeEvent);
            element.removeEventListener("propertychange", onChangeEvent);
            element.removeEventListener("scroll", onScroll);
        }
        
        var el:Element = null;
        if (_displayData.multiline == false) {
            el = Browser.document.createInputElement();
            el.style.border = "none";
            el.style.outline = "none";
            el.style.whiteSpace = "pre";
            el.style.overflow = "hidden";
            el.style.cursor = "initial";
            el.style.position = "absolute";
            el.style.backgroundColor = "inherit";
            el.style.padding = "0px";
            //el.style.marginLeft = "-1px";
            //el.style.marginTop = "-1px";
            el.spellcheck = false;
        } else {
            el = Browser.document.createTextAreaElement();
            el.style.border = "none";
            el.style.resize = "none";
            el.style.outline = "none";
            el.style.lineHeight = "1.4";
            el.style.padding = "0px";
            el.style.margin = "0px";
            el.style.bottom = "0px"; // chrome only?
            el.style.right = "0px"; // chrome only?
            el.style.overflow = "hidden";
            el.style.cursor = "initial";
            el.style.position = "absolute";
            el.style.backgroundColor = "inherit";
            el.style.whiteSpace = "pre-wrap";
            el.id = "textArea";
            el.spellcheck = false;
            el.onkeydown = function(e) {
                if (e.keyCode == 9 || e.which == 9) {
                    e.preventDefault();
                    e.stopImmediatePropagation();
                    e.stopPropagation();

                    var ta:TextAreaElement = cast(el, TextAreaElement);
                    var s = ta.selectionStart;
                    ta.value = ta.value.substring(0, ta.selectionStart) + "\t" + ta.value.substring(ta.selectionEnd);
                    ta.selectionEnd = s + 1;

                    return false;
                }
                return true;
            }
        }

        el.addEventListener("input", onChangeEvent);
        el.addEventListener("propertychange", onChangeEvent);
        el.addEventListener("scroll", onScroll);

        return el;
    }

    private override function validatePosition() {
        var x = _left;
        var y = _top;
        if (_displayData.multiline == false && parentComponent != null && parentComponent.style != null) {
            if (parentComponent.style.borderLeftSize != null) {
                x -= parentComponent.style.borderLeftSize;
            }
            if (parentComponent.style.borderTopSize != null) {
                y -= parentComponent.style.borderTopSize;
            }
        }
        var style:CSSStyleDeclaration = element.style;
        style.left = HtmlUtils.px(x);
        style.top = HtmlUtils.px(y);
    }
    
    private function setTempDivData(div:Element) {
        var t:String = _text;
        if (t == null || t.length == 0) {
            t = "|";
        }
        
        div.style.fontFamily = element.style.fontFamily;
        div.style.fontSize = element.style.fontSize;
        div.style.whiteSpace = element.style.whiteSpace;
        div.style.lineHeight = element.style.lineHeight;
        if ((element is TextAreaElement)) {
            div.style.wordBreak = element.style.wordBreak;
        }
        if (autoWidth == false) {
            div.style.width = (_width > 0) ? '${HtmlUtils.px(_width)}' : "";
        } else {
            div.style.width = "";
        }
        var normalizedText = super.normalizeText(t);
        normalizedText = StringTools.replace(normalizedText, "<", "&lt;");
        normalizedText = StringTools.replace(normalizedText, ">", "&gt;");
        if (_displayData.multiline == true) {
            normalizedText += "<br>";
        }
        div.innerHTML = normalizedText;
    }
}
