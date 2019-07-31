package haxe.ui.backend.html5.native.behaviours;

import haxe.ui.components.OptionBox.OptionBoxGroups;

class RadioGroup extends ElementAttribute {
    public override function validateData() {
        super.validateData();
        OptionBoxGroups.instance.add(_value, cast _component);
    }
}
