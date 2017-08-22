package haxe.ui.backend;
import haxe.ui.backend.html5.EventMapper;
import haxe.ui.backend.html5.HtmlUtils;
import haxe.ui.backend.html5.StyleHelper;
import haxe.ui.backend.html5.UserAgent;
import haxe.ui.backend.html5.native.NativeElement;
import haxe.ui.core.UIEvent;

import js.Browser;
import js.html.CanvasElement;
import js.html.DivElement;
import js.html.Element;
import js.html.MutationObserver;
import js.html.MutationRecord;
import js.html.Node;
import haxe.ui.components.VProgress;
import haxe.ui.containers.Header;
import haxe.ui.containers.ScrollView;
import haxe.ui.containers.TableView;
import haxe.ui.core.Component;
import haxe.ui.core.ImageDisplay;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.Screen;
import haxe.ui.core.ScrollEvent;
import haxe.ui.core.TextDisplay;
import haxe.ui.core.TextInput;
import haxe.ui.core.UIEvent;
import haxe.ui.styles.Style;
import haxe.ui.components.TextArea;
import haxe.ui.components.Image;
import haxe.ui.core.KeyboardEvent;
import haxe.ui.components.TextField;
class CanvasBase extends haxe.ui.core.Component  {
    private static var _mutationObserver:MutationObserver;
    private static var elementToComponent:Map<Node, Component> = new Map<Node, Component>();
    public function new() {
        super();
    }
    override public function handleCreate(native:Bool) {trace("create the damned canvas");
        var newElement = null;
        if (native == true) {
                var component:Component = cast(this, Component);
                var nativeConfig:Map<String, String> = component.getNativeConfigProperties();
                if (nativeConfig != null && nativeConfig.exists("class")) {
                    _nativeElement = Type.createInstance(Type.resolveClass(nativeConfig.get("class")), [this]);
                    _nativeElement.config = nativeConfig;
                    newElement = _nativeElement.create();
                }


            if (newElement != null) {
                newElement.style.position = "absolute";

                if (element != null) {
                    var p = element.parentElement;
                    if (p != null) {
                        elementToComponent.remove(element);
                        p.replaceChild(newElement, element);
                    }
                }

                element = newElement;

                remapEvents();
            }
        }

        if (newElement == null) {
            newElement = Browser.document.createElement("CANVAS");

            newElement.style.setProperty("-webkit-touch-callout", "none");
            newElement.style.setProperty("-webkit-user-select", "none");
            newElement.style.setProperty("-khtml-user-select", "none");
            newElement.style.setProperty("-moz-user-select", "none");
            newElement.style.setProperty("-ms-user-select", "none");
            newElement.style.setProperty("user-select", "none");
            newElement.style.position = "absolute";

            if (Std.is(this, Image)) {
                newElement.style.boxSizing = "initial";
            }

            if (element != null) {
                var p = element.parentElement;
                if (p != null) {
                    elementToComponent.remove(element);
                    p.replaceChild(newElement, element);
                }
            }

            element = newElement;
            elementToComponent.set(element, cast(this, Component));
            _nativeElement = null;

            remapEvents();
        }
    }
}
