package haxe.ui.backend;

import js.Browser;
import js.html.Element;

class AppImpl extends AppBase {
    public function new() {
    }
    
    private override function init(onReady:Void->Void, onEnd:Void->Void = null) {
        if (Browser.document.readyState == "complete") {
            onReady();
        } else {
            Browser.document.body.onload = function(e) {
                onReady();
            }
        }
    }

    private override function getToolkitInit():ToolkitOptions {
        return {
            container: findContainer(Toolkit.backendProperties.getProp("haxe.ui.html5.container"))
        };
    }

    private function findContainer(id:String):Element {
        var el:Element = null;
        if (id == "body") {
            el = Browser.document.body;
        }

        if (el == null) {
            el = Browser.document.body;
        }
        el.style.overflow = "hidden";
        return el;
    }
}
