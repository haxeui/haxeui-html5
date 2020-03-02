package haxe.ui.backend;

import haxe.ui.core.Screen;
import js.Browser;
import js.html.Element;

class AppImpl extends AppBase {
    public function new() {
    }
    
    private override function init(onReady:Void->Void, onEnd:Void->Void = null) {
        var title = Toolkit.backendProperties.getProp("haxe.ui.html5.title");
        if (title != null) {
            Screen.instance.title = title;
        }
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
            container: findContainer(Toolkit.backendProperties.getProp("haxe.ui.html5.container", "body"))
        };
    }

    private function findContainer(id:String):Element {
        var el:Element = null;
        if (id == "body") {
            el = Browser.document.body;
        } else if (id != null) {
            el = Browser.document.getElementById(id);
        }

        if (el == null) {
            el = Browser.document.body;
        }
        el.style.overflow = "hidden";
        return el;
    }
}
