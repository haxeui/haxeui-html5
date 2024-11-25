package haxe.ui.backend;

import haxe.io.Bytes;
import haxe.ui.assets.FontInfo;
import haxe.ui.assets.ImageInfo;
import haxe.ui.backend.html5.util.FontDetect;
import js.Browser;
import js.html.Blob;
import js.html.FontFace;
import js.html.URL;

class AssetsImpl extends AssetsBase {
    private override function getImageInternal(resourceId:String, callback:ImageInfo->Void) {
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

    private override function getImageFromHaxeResource(resourceId:String, callback:String->ImageInfo->Void) {
        var bytes = Resource.getBytes(resourceId);

        imageFromBytes(bytes, function(imageInfo) {
            if (imageInfo == null) {
                trace("WARNING: problem loading image from haxe resource: " + resourceId);
            }
            callback(resourceId, imageInfo);
        });
    }

    public override function imageFromBytes(bytes:Bytes, callback:ImageInfo->Void) {
        if (bytes == null) {
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
            Browser.window.console.log(e);
            callback(null);
        }
        
        var blob = new Blob([bytes.getData()], getBlobOptionsFromBytes(bytes));
        var blobUrl = URL.createObjectURL(blob);
        image.src = blobUrl;
        /*
        var base64:String = haxe.crypto.Base64.encode(bytes);
        image.src = "data:;base64," + base64;
        */
    }
    
    public override function imageToBytes(format:String, imageInfo:ImageInfo, callback:Bytes->Void) {
        callback(null);
    }

    private static var SVG_BYTE_SEQUENCE:Array<Int> = ['<'.charCodeAt(0),
                                                       's'.charCodeAt(0),
                                                       'v'.charCodeAt(0),
                                                       'g'.charCodeAt(0)];
    private function getBlobOptionsFromBytes(bytes:Bytes):js.html.BlobPropertyBag {
        if (bytes.get(0) == '<'.charCodeAt(0) && // could be an svg?
            containsByteSequence(bytes, SVG_BYTE_SEQUENCE)) {
            return { type: "image/svg+xml"};
        }
        return null;        
    }

    private function containsByteSequence(bytes:Bytes, seq:Array<Int>) {
        for (i in 0...bytes.length - seq.length) {
            var match = true;
            for (j in 0...seq.length) {
                if (bytes.get(i + j) != seq[j]) {
                    match = false;
                    break;
                }
            }
            if (match == true) {
                return true;
            }
        }
        return false;
    }

    private override function getFontInternal(resourceId:String, callback:FontInfo->Void) {
        var bytes = Resource.getBytes(resourceId);
        if (bytes == null) {
            FontDetect.onFontLoaded(resourceId, function(f) {
                var fontInfo = {
                    data: f
                }
                callback(fontInfo);
            }, function(f) {
                callback(null);
            });
            return;
        }

        getFontFromHaxeResource(resourceId, function(r, f) {
            callback(f);
        });
    }
    
    public override function imageInfoFromImageData(imageData:ImageData):ImageInfo {
        return {
            data: imageData,
            width: imageData.width,
            height: imageData.height
        }
    }
    
    private override function getFontFromHaxeResource(resourceId:String, callback:String->FontInfo->Void) {
        var bytes = Resource.getBytes(resourceId);
        if (bytes == null) {
            callback(resourceId, null);
            return;
        }
        
        var fontFamilyParts = resourceId.split("/");
        var fontFamily = fontFamilyParts[fontFamilyParts.length - 1];
        if (fontFamily.indexOf(".") != -1) {
            fontFamily = fontFamily.substr(0, fontFamily.indexOf("."));
        }
        
        var fontFace = new FontFace(fontFamily, bytes.getData());
        fontFace.load().then(function(loadedFace) {
            Browser.document.fonts.add(loadedFace);
            FontDetect.onFontLoaded(fontFamily, function(f) {
                var fontInfo = {
                    data: fontFamily
                }
                callback(resourceId, fontInfo);
            }, function(f) {
                callback(resourceId, null);
            });
        }).catchError(function(error) {
            #if debug
            trace("WARNING: problem loading font '" + resourceId + "' (" + error + ")");
            #end
            // error occurred
            callback(resourceId, null);
        });
    }
}