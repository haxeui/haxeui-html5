package haxe.ui.backend;

import haxe.ui.Preloader.PreloadItem;
import js.html.Element;
import js.Browser;

class AppBase {
    public function new() {

    }

    private function build() {

    }

    private function init(onReady:Void->Void, onEnd:Void->Void = null) {
        if (Browser.document.readyState == "complete") {
            onReady();
        } else {
            Browser.document.body.onload = function(e) {
                onReady();
            }
        }
        
    }

    private function getToolkitInit():Dynamic {
        return {
            container: findContainer(Toolkit.backendProperties.getProp("haxe.ui.html5.container"))
        };
    }

    public function start() {

    }

    private function buildPreloadList():Array<PreloadItem> {
        return [];
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
