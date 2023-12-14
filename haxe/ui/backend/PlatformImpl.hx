package haxe.ui.backend;

import haxe.ui.backend.html5.HtmlUtils;
import haxe.ui.core.Platform;
import js.Browser;

class PlatformImpl extends PlatformBase {
    public override function getMetric(id:String):Float {
        switch (id) {
            case Platform.METRIC_VSCROLL_WIDTH:
                calcScrollSize();
                return _vscrollWidth;
            case Platform.METRIC_HSCROLL_HEIGHT:
                calcScrollSize();
                return _hscrollHeight;
        }
        return super.getMetric(id);
    }
    
    public override function getSystemLocale():String {
        var systemLocale = null;
        var htmlTag = Browser.document.body.parentElement;
        if (htmlTag != null) {
            systemLocale = htmlTag.lang;
        }

        if (systemLocale == null) {
            systemLocale = Browser.navigator.language;
        }
        return systemLocale;
    }

    private static var _vscrollWidth:Float = -1;
    private static var _hscrollHeight:Float = -1;
    private static function calcScrollSize() {
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
    
    public override function perf():Float {
        return Browser.window.performance.now();
    }
}