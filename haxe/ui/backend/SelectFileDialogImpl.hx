package haxe.ui.backend;

import haxe.io.Bytes;
import haxe.ui.backend.SelectFileDialogBase;
import haxe.ui.containers.dialogs.Dialog.DialogButton;
import haxe.ui.util.Timer;
import js.Browser;
import js.html.FileReader;
import js.html.InputElement;

using StringTools;

class SelectFileDialogImpl extends SelectFileDialogBase {
    private var _fileInput:InputElement;
    
    public override function show() {
        validateOptions();
        createFileInput();
        _fileInput.click();
    }
    
    private var _hasChanged:Bool = false;
    private function onFileInputChanged(e) {
        _hasChanged = true;
        if (callback != null) {
            var infos:Array<SelectedFileInfo> = [];
            var files:Array<Dynamic> = [];
            var selectedFiles:Dynamic = e.target.files;
            for (i in 0...selectedFiles.length) {
                var selectedFile = selectedFiles[i];
                var info:SelectedFileInfo = {
                    name: selectedFile.name,
                    isBinary: false
                }
                infos.push(info);
                files.push(selectedFile);
            }
            
            if (options.readContents == false) {
                callback(DialogButton.OK, infos);
            } else {
                readFileContents(infos.copy(), files, function() {
                    callback(DialogButton.OK, infos);
                });
            }
        }
        destroyFileInput();
    }
    
    private function readFileContents(infos:Array<SelectedFileInfo>, files:Array<Dynamic>, callback:Void->Void) {
        if (infos.length == 0) {
            callback();
            return;
        }
        
        var info:SelectedFileInfo = infos.shift();
        var file:Dynamic = files.shift();
        var reader = new FileReader();
        if (options.readAsBinary == false) {
            reader.readAsText(file, "UTF-8");
        } else {
            reader.readAsArrayBuffer(file);
        }
        
        reader.onload = function(readerEvent) {
            var result:Dynamic = readerEvent.target.result;
            if (options.readAsBinary == false) {
                info.isBinary = false;
                info.text = result;
            } else {
                info.isBinary = true;
                info.bytes = Bytes.ofData(result);
            }
            
            readFileContents(infos, files, callback);
        }
    }
    
    private function onWindowFocus(e) { // js doesnt allow you to know when dialog has been cancelled, so lets use a window focus event
        Timer.delay(function() {
            destroyFileInput();
            if (_hasChanged == false) {
                if (callback != null) {
                    callback(DialogButton.CANCEL, null);
                }
            }
        }, 100);
    }
    
    private function createFileInput() {
        _hasChanged = false;
        
        Browser.window.addEventListener("focus", onWindowFocus);
        
        _fileInput = Browser.document.createInputElement();
        _fileInput.type = "file";
        _fileInput.id = "fileInput_" + Date.now().toString().replace("-", "_").replace(":", "_").replace(" ", "_");
        _fileInput.style.display = "none";
        if (options.multiple == true) {
            _fileInput.multiple = true;
        }
        _fileInput.onchange = onFileInputChanged;
        Browser.document.body.appendChild(_fileInput);
    }
    
    private function destroyFileInput() {
        if (_fileInput == null) {
            return;
        }
        
        Browser.window.removeEventListener("focus", onWindowFocus);
        
        _fileInput.onchange = null;
        Browser.document.body.removeChild(_fileInput);
        _fileInput = null;
    }
}