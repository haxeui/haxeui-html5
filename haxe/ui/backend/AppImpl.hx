package haxe.ui.backend;

import haxe.ui.ToolkitAssets;
import haxe.ui.core.Screen;
import js.Browser;
import js.html.Element;
import js.html.LinkElement;

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
            Browser.window.addEventListener("load", function(e) {
                onReady();
            });
        }
    }

    private override function getToolkitInit():ToolkitOptions {
        return {
            container: findContainer(Toolkit.backendProperties.getProp("haxe.ui.html5.container", "body")),
            useHybridScrollers: Toolkit.backendProperties.getProp("haxe.ui.html5.scrollers") == "hybrid",
            useNativeScrollers: Toolkit.backendProperties.getProp("haxe.ui.html5.scrollers") == "native",
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
    
    private override function set_icon(value:String):String {
        if (_icon == value) {
            return value;
        }
        _icon = value;
        
        var link:LinkElement = cast Browser.document.querySelector("link[rel~='icon']");
        if (link == null) {
            link = Browser.document.createLinkElement();
            link.rel = "icon";
            Browser.document.getElementsByTagName('head')[0].appendChild(link);
        }
        ToolkitAssets.instance.getImage(_icon, function(imageInfo) {
            if (imageInfo != null) {
                link.href = imageInfo.data.src;
            }
        });
        
        
        return value;
    }
}
