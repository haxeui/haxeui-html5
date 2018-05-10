package haxe.ui.backend.html5.native.behaviours;

import haxe.ui.ToolkitAssets;
import haxe.ui.assets.ImageInfo;
import haxe.ui.core.Behaviour;
import haxe.ui.core.DataBehaviour;
import haxe.ui.util.ImageLoader;
import haxe.ui.util.Variant;
import js.Browser;
import js.html.Element;
import js.html.ImageElement;

@:keep
class ElementImage extends DataBehaviour {
    public override function validateData() {
        if (_value.isNull) {
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

        var imageLoader:ImageLoader = new ImageLoader(_value);
        imageLoader.load(function(imageInfo) {
            if (imageInfo != null) {
               img.src = imageInfo.data.src;
               _component.invalidateComponentLayout();
            }
        });
        
        ToolkitAssets.instance.getImage(_value, function(image:ImageInfo) {
            if (image != null && image.data != null) {
            }
        });
    }
}