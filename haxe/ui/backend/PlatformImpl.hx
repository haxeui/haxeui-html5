package haxe.ui.backend;

import haxe.ui.backend.html5.HtmlUtils;
import haxe.ui.core.Platform;
import haxe.ui.core.Screen;
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

    public var useNativeScrollers(get, null):Bool;
    private function get_useNativeScrollers():Bool @:privateAccess {
        if (Screen.instance._options == null) {
            return false;
        }
        if (Screen.instance._options.useNativeScrollers == null) {
            return false;
        }
        return Screen.instance._options.useNativeScrollers;
    }

    public var throttleMouseWheelPlatforms(get, null):Array<String>;
    private function get_throttleMouseWheelPlatforms():Array<String> @:privateAccess {
        if (Screen.instance._options == null) {
            return ["mac"];
        }
        if (Screen.instance._options.throttleMouseWheelPlatforms == null) {
            return ["mac"];
        }
        return Screen.instance._options.throttleMouseWheelPlatforms;
    }

    public var throttleMouseWheelTimestampDelta(get, null):Null<Float>;
    private function get_throttleMouseWheelTimestampDelta():Null<Float> @:privateAccess {
        if (Screen.instance._options == null) {
            return 20;
        }
        if (Screen.instance._options.throttleMouseWheelTimestampDelta == null) {
            return 20;
        }
        return Screen.instance._options.throttleMouseWheelTimestampDelta;
    }

    public var shouldThrottleMouseWheel(get, null):Bool;
    private function get_shouldThrottleMouseWheel():Bool {
        var platforms = throttleMouseWheelPlatforms;
        if (isMac && platforms.indexOf("mac") != -1) {
            return true;
        }
        if (isLinux && platforms.indexOf("linux") != -1) {
            return true;
        }
        if (isWindows && platforms.indexOf("windows") != -1) {
            return true;
        }
        return false;
    }
}