package haxe.ui.backend;

import js.Browser;

class CallLaterImpl {
    public function new(fn:Void->Void) {
        Browser.window.requestAnimationFrame(function(timestamp) {
            fn();
        });
    }
}
