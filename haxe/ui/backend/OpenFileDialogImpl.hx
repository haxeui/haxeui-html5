package haxe.ui.backend;

import haxe.ui.backend.OpenFileDialogBase;
import haxe.ui.backend.html5.FileSelector;
import haxe.ui.containers.dialogs.Dialogs.SelectedFileInfo;

using StringTools;

class OpenFileDialogImpl extends OpenFileDialogBase {
    private var _fileSelector:FileSelector = new FileSelector();
    
    public override function show() {
        var readMode = ReadMode.None;
        if (options.readContents == true) {
            if (options.readAsBinary == false) {
                readMode = ReadMode.Text;
            } else {
                readMode = ReadMode.Binary;
            }
        }
        _fileSelector.selectFile(onFileSelected, readMode, options.multiple, options.extensions);
    }
    
    private function onFileSelected(cancelled:Bool, files:Array<SelectedFileInfo>) {
        if (cancelled == false) {
            dialogConfirmed(files);
        } else {
            dialogCancelled();
        }
    }
}