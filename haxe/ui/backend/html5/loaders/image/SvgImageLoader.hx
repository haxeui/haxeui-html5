package haxe.ui.backend.html5.loaders.image;

import haxe.ui.assets.ImageInfo;
import haxe.ui.loaders.image.ImageLoaderBase;
import haxe.ui.util.Variant;
import js.Browser;
import js.html.Blob;
import js.html.Image;
import js.html.URL;

using StringTools;

class SvgImageLoader extends ImageLoaderBase {
    public override function load(resource:Variant, callback:ImageInfo->Void) {
        var image = new Image();
        var svgData:String = resource.toString();
        if (svgData.startsWith("svg://")) {
            svgData = svgData.substr("svg://".length);
        }
        var svg = new Blob([svgData], {type: "image/svg+xml;charset=utf-8"});
        var url = URL.createObjectURL(svg);
        image.onload = function() {
            callback({
                data:image,
                width: image.width,
                height: image.height
            });
        }
        image.onerror = function(e) {
            trace(e);
            callback(null);
        }
        image.src = url;
    }
}