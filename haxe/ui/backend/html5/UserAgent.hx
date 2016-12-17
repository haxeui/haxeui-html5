package haxe.ui.backend.html5;

import js.Browser;

class UserAgent {
    private static var _instance:UserAgent;
    public static var instance(get, null):UserAgent;
    private static function get_instance():UserAgent {
        if (_instance == null) {
            _instance = new UserAgent();
        }
        return _instance;
    }

    // far from bullet proof and easy to fake - will do for now
    public function new() {
        var ua:String = Browser.navigator.userAgent;

        if (ua.indexOf("Opera") != -1 || ua.indexOf('OPR') != -1) {
            _opera = true;
        } else if (ua.indexOf("Chrome") != -1) {
            _chrome = true;
        } else if (ua.indexOf("Safari") != -1) {
            _safari = true;
        } else if (ua.indexOf("Firefox") != -1) {
            _firefox = true;
        } else if (ua.indexOf("MSIE") != -1) {
            _msie = true;
        } else {
            _unknown = true;
        }
    }

    private var _opera:Bool;
    public var opera(get, null):Bool;
    private function get_opera():Bool {
        return _opera;
    }

    private var _chrome:Bool;
    public var chrome(get, null):Bool;
    private function get_chrome():Bool {
        return _chrome;
    }

    private var _safari:Bool;
    public var safari(get, null):Bool;
    private function get_safari():Bool {
        return _safari;
    }

    private var _firefox:Bool;
    public var firefox(get, null):Bool;
    private function get_firefox():Bool {
        return _firefox;
    }

    private var _msie:Bool;
    public var msie(get, null):Bool;
    private function get_msie():Bool {
        return _msie;
    }

    private var _unknown:Bool;
    public var unknown(get, null):Bool;
    private function get_unknown():Bool {
        return _unknown;
    }
}