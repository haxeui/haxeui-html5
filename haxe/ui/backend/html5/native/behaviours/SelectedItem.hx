package haxe.ui.backend.html5.native.behaviours;

import haxe.ui.behaviours.Behaviour;
import haxe.ui.data.DataSource;
import js.html.SelectElement;

@:keep
@:access(haxe.ui.backend.ComponentBase)
class SelectedItem extends Behaviour {
    public override function getDynamic():Dynamic {
        var data:Dynamic = null;
        if (_component.element.nodeName == "SELECT") {
            if (_component.has("dataSource") == true) {
                var selectElement:SelectElement = cast(_component.element, SelectElement);
                var ds:DataSource<Dynamic> = cast _component.get("dataSource");
                data = ds.get(selectElement.selectedIndex);
            }
        }
        return data;
    }
}