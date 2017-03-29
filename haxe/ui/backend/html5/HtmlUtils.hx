package haxe.ui.backend.html5;

import haxe.ui.util.Size;
import js.Browser;
import js.html.Element;

class HtmlUtils {
    public static inline function px(value:Float):String {
        return '${value}px';
    }

    public static function color(value:Int):String {
        return '#${StringTools.hex(value, 6)}';
    }

    public static function rgba(value:Int, alpha:Float = 1):String {
        var r:Int = (value >> 16) & 0xFF;
        var g:Int = (value >> 8) & 0xFF;
        var b:Int = value & 0xFF;
        return 'rgba(${r}, ${g}, ${b}, ${alpha})';
    }

    public static function escape(s):String {
        //s = StringTools.replace(s, "&", "&amp;");
        s = StringTools.replace(s, "\"", "&quot;");
        s = StringTools.replace(s, "'", "&#39;");
        s = StringTools.replace(s, "<", "&lt;");
        s = StringTools.replace(s, ">", "&gt;");
        return s;
    }

    public static function measureText(text:String, addWidth:Float = 0, addHeight:Float = 0):Size {
        var div = Browser.document.createElement("div");
        div.innerHTML = text;
        div.style.position = "absolute";
        div.style.top = "-99999px"; // position off-screen!
        div.style.left = "-99999px"; // position off-screen!
        Browser.document.body.appendChild(div);
        var size:Size = new Size(div.clientWidth + addWidth, div.clientHeight + addHeight);
        HtmlUtils.removeElement(div);
        return size;
    }

    private static var _dpi:Float = 0;
    public static var dpi(get, null):Float;
    public static function get_dpi():Float {
        if (_dpi != 0) {
            return _dpi;
        }

        var div = Browser.document.createElement("div");
        div.style.width = "1in";
        div.style.height = "1in";
        div.style.position = "absolute";
        div.style.top = "-99999px"; // position off-screen!
        div.style.left = "-99999px"; // position off-screen!
        Browser.document.body.appendChild(div);
        
        var devicePixelRatio:Null<Float> = Browser.window.devicePixelRatio;
        if (devicePixelRatio == null) {
            devicePixelRatio = 1;
        }
        
        _dpi = div.offsetWidth * devicePixelRatio;
        HtmlUtils.removeElement(div);
        return _dpi;
    }
    
    public static function swapElements(el1:Element, el2:Element) {
        el2.parentElement.insertBefore(el2, el1);
    }

    public static function insertBefore(el:Element, before:Element) {
        before.parentElement.insertBefore(before, el);
    }

    public static function removeElement(el:Element) {
        // el.remove() - IE is crap
        if  (el != null && el.parentElement != null) {
            el.parentElement.removeChild(el);
        }
    }
}