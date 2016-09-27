package haxe.ui.backend.html5;

import haxe.ui.util.Size;
import js.Browser;
import js.html.Element;

class HtmlUtils {
    public inline static function px(value:Float) {
        return '${value}px';
    }

    public static function color(value:Int) {
        return '#${StringTools.hex(value, 6)}';
    }

    public static function rgba(value:Int, alpha:Float = 1) {
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

    public static function swapElements(el1:Element, el2:Element) {
        el2.parentNode.insertBefore(el2, el1);
    }

    public static function insertBefore(el:Element, before:Element) {
        before.parentNode.insertBefore(before, el);
    }

    public static function removeElement(el:Element) {
        // el.remove() - IE is crap
        if  (el != null && el.parentElement != null) {
            el.parentElement.removeChild(el);
        }
    }
}