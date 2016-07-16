package haxe.ui;

import haxe.ui.assets.FontInfo;
import haxe.ui.assets.ImageInfo;
import js.Browser;

class AssetsBase {
    public function new() {

    }

    private function getTextDelegate(resourceId:String):String {
        return null;
    }

    private function getImageInternal(resourceId:String, callback:ImageInfo->Void):Void {
        var bytes = Resource.getBytes(resourceId);
        if (bytes != null) {
            callback(null);
            return;
        }

        var image = Browser.document.createImageElement();
        image.onload = function(e) {
            var imageInfo:ImageInfo = {
                width: image.width,
                height: image.height,
                data: cast image
            }
            callback(imageInfo);
        }
        image.onerror = function(e) {
            callback(null);
        }
        image.src = resourceId;

    }

    private function getImageFromHaxeResource(resourceId:String, callback:String->ImageInfo->Void) {
        var image = Browser.document.createImageElement();
        var bytes = Resource.getBytes(resourceId);
        image.onload = function(e) {
            var imageInfo:ImageInfo = {
                width: image.width,
                height: image.height,
                data: cast image
            }
            callback(resourceId, imageInfo);
        }

        var base64:String = haxe.crypto.Base64.encode(bytes);
        image.src = "data:image/png;base64," + base64;
    }

    private function getFontInternal(resourceId:String, callback:FontInfo->Void):Void {
        callback(null);
    }

    private function getFontFromHaxeResource(resourceId:String, callback:String->FontInfo->Void) {
        callback(resourceId, null);
    }
}