package haxe.ui.backend.html5.native.behaviours;

import haxe.ui.ToolkitAssets;
import haxe.ui.assets.ImageInfo;
import haxe.ui.core.Behaviour;
import haxe.ui.util.Variant;
import js.Browser;
import js.html.Element;
import js.html.ImageElement;

@:keep
class ElementImage extends Behaviour {
    public override function set(value:Variant) {
        if (value.isNull) {
            return;
        }

        var el:Element = _component.element;
        var img:ImageElement = null;
        var list = el.getElementsByTagName("img");
        if (list != null && list.length == 1) {
            img = cast list.item(0);
        } else {
            img = Browser.document.createImageElement();
            img.style.display = "inline";
            img.style.verticalAlign = "middle";
            img.style.marginTop = "-1px";
            el.appendChild(img);
        }

        ToolkitAssets.instance.getImage(value, function(image:ImageInfo) {
            if (image != null && image.data != null) {
               img.src = image.data.src;
               _component.invalidateLayout();
            }
        });
    }

    public override function get():Variant {
        var el:Element = _component.element;
        return null;
    }
}