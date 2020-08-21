package haxe.ui.backend.html5.native.behaviours;
import haxe.ui.behaviours.DataBehaviour;
import js.html.SelectElement;

@:dox(hide) @:noCompletion
class SelectedIndex extends DataBehaviour {
    private override function validateData() {
        if (_component.element.nodeName == "SELECT") {
            var selectElement:SelectElement = cast(_component.element, SelectElement);
            selectElement.selectedIndex = _value;
            
        }
    }
}