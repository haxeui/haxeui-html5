package haxe.ui.core;

import haxe.ui.core.Platform;
import haxe.ui.html5.HtmlUtils;
import js.Browser;

class PlatformBase {
    public function getMetric(id:String):Float {
        switch (id) {
            case Platform.METRIC_VSCROLL_WIDTH:
                calcScrollSize();
                return _vscrollWidth;
            case Platform.METRIC_HSCROLL_HEIGHT:
                calcScrollSize();
                return _hscrollHeight;
        }
        return 0;
    }
    
    private static var _vscrollWidth:Float = -1;
    private static var _hscrollHeight:Float = -1;
    private static function calcScrollSize():Void {
        if (_vscrollWidth >= 0 && _hscrollHeight >= 0) {
            return;
        }

        var div = Browser.document.createElement("div");
		div.style.position = "absolute";
		div.style.top = "-99999px"; // position off-screen!
		div.style.left = "-99999px"; // position off-screen!
        div.style.height = "100px";        
        div.style.width = "100px";     
        div.style.overflow = "scroll";     
        Browser.document.body.appendChild(div);
        _vscrollWidth = div.offsetWidth - div.clientWidth;
        _hscrollHeight = div.offsetHeight - div.clientHeight;
        HtmlUtils.removeElement(div);
    }
}