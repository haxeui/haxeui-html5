package haxe.ui.backend.html5.native.behaviours;

import haxe.ui.core.Behaviour;
import haxe.ui.data.DataSource;
import haxe.ui.util.Variant;
import js.html.Element;
import js.html.OptionElement;
import js.Browser;

@:keep
@:access(haxe.ui.backend.ComponentBase)
class SelectDataSource extends Behaviour {
    public override function set(value:Variant) {
        var ds:DataSource<Dynamic> = value;
        var el:Element = _component.element;
        while (el.childElementCount > 0) {
            el.removeChild(el.children[0]);
        }

        if (ds != null) {
            for (n in 0...ds.size) {
                var item = ds.get(n);
                if (item.value != null) {
                    var option:OptionElement = Browser.document.createOptionElement();
                    option.text = item.value;
                    el.appendChild(option);
                }
            }
        }

        _component.set("dataSource", ds);
    }
}