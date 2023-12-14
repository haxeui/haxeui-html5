package haxe.ui.backend;
import haxe.ui.util.html5.FileSaver;

class SaveFileDialogImpl extends SaveFileDialogBase {
    private var _fileSaver:FileSaver = new FileSaver();
    
    public override function show() {
        if (fileInfo == null || (fileInfo.text == null && fileInfo.bytes == null)) {
            throw "Nothing to write";
        }
        
        if (fileInfo.text != null) {
            _fileSaver.saveText(fileInfo.name, fileInfo.text, onSaveResult);
        } else if (fileInfo.bytes != null) {
            _fileSaver.saveBinary(fileInfo.name, fileInfo.bytes, onSaveResult);
        }
    }
    
    private function onSaveResult(r:Bool) {
        if (r == true) {
            dialogConfirmed();
        } else {
            dialogCancelled();
        }
    }
}