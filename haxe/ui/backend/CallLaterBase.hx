package haxe.ui.backend;

import js.Browser;

class CallLaterBase {
    public function new(fn:Void->Void) {
        Browser.window.requestAnimationFrame(function(timestamp) {
            fn();
        });
    }
}
