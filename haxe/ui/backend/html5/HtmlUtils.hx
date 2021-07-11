package haxe.ui.backend.html5;

import haxe.ui.events.ValidationEvent;
import haxe.ui.geom.Size;
import haxe.ui.validation.ValidationManager;
import js.Browser;
import js.html.DivElement;
import js.html.Element;

class HtmlUtils {
    public static inline function px(value:Float):String {
        return '${value}px';
    }

    public static function color(value:Null<Int>):String {
        if (value == null) {
            return 'rgba(0, 0, 0, 0)';
        }
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

    public static function namedChild(el:Element, child:String, index:Int = 0):Element {
        if (child != null) {
            var list = el.getElementsByTagName(child);
            if (list.length == 0) {
                return null;
            }
            el = list.item(index);
        }
        
        return el;
    }
    
    public static var DIV_HELPER:DivElement;

    public static function __init__():Void {
        ValidationManager.instance.registerEvent(ValidationEvent.STOP, onValidationStop);
    }

    private static function onValidationStop(e:ValidationEvent):Void {
        if (DIV_HELPER != null) {
            /*
            removeElement(DIV_HELPER);
            DIV_HELPER = null;
            */
        }
    }

    public static function createDivHelper():Void
    {
        if (DIV_HELPER == null) {
            DIV_HELPER = Browser.document.createDivElement();
            DIV_HELPER.style.position = "absolute";
            DIV_HELPER.style.top = "-99999px"; // position off-screen!
            DIV_HELPER.style.left = "-99999px"; // position off-screen!
            //DIV_HELPER.style.height = "1.05em";
            Browser.document.body.appendChild(DIV_HELPER);
        }
    }

    public static function measureText(text:String, addWidth:Float = 0, addHeight:Float = 0, fontSize:Float = -1, fontName:String = null):Size {
        if (DIV_HELPER == null) {
            createDivHelper();
        }

        DIV_HELPER.style.width = "";
        DIV_HELPER.style.height = "";
        if (fontSize > 0) {
            DIV_HELPER.style.fontSize = px(fontSize);
        } else {
            DIV_HELPER.style.fontSize = "";
        }
        if (fontName != null) {
            DIV_HELPER.style.fontFamily = fontName;
        } else {
            DIV_HELPER.style.fontFamily = "";
        }
        DIV_HELPER.innerHTML = text;

        return new Size(DIV_HELPER.clientWidth + addWidth, DIV_HELPER.clientHeight + addHeight);
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
    
    private static var _isRetina:Null<Bool> = null;
    public static function isRetinaDisplay():Bool {
        if (_isRetina == null) {
            var query = "(-webkit-min-device-pixel-ratio: 2), (min-device-pixel-ratio: 2), (min-resolution: 192dpi)";
            if (Browser.window.matchMedia(query).matches) {
                _isRetina = true;
            } else {
                _isRetina = false;
            }
        }
        return _isRetina;
    }
}