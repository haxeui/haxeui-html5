package haxe.ui.backend.html5.native.builders;

import haxe.ui.containers.Box;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.layouts.LayoutFactory;

class ScrollViewBuilder extends CompositeBuilder {
    private var _contents:Box;
    
    public override function create() {
        createContentContainer("vertical");
    }
    
    public override function addComponent(child:Component):Component {
        if (child.hasClass("scrollview-contents") == false) {
            return _contents.addComponent(child);
        }
        return null;
        
    }
    
    public override function addComponentAt(child:Component, index:Int):Component {
        if (child.hasClass("scrollview-contents") == false) {
            return _contents.addComponentAt(child, index);
        }
        return null;
    }
    
    public override function removeComponent(child:Component, dispose:Bool = true, invalidate:Bool = true):Component {
        if (child.hasClass("scrollview-contents") == false) {
            return _contents.removeComponent(child, dispose, invalidate);
        }
        return null;
    }
    
    public override function getComponentIndex(child:Component):Int {
        return _contents.getComponentIndex(child);
    }
    
    public override function setComponentIndex(child:Component, index:Int):Component {
        if (child.hasClass("scrollview-contents") == false) {
            return _contents.setComponentIndex(child, index);
        }
        return null;
    }
    
    public override function getComponentAt(index:Int):Component {
        return _contents.getComponentAt(index);
    }
    
    
    private function createContentContainer(layoutName:String) {
        if (_contents == null) {
            _contents = new Box();
            _contents.addClass("scrollview-contents");
            _contents.id = "scrollview-contents";
            _contents.layout = LayoutFactory.createFromName(layoutName); // TODO: temp
            _component.addComponent(_contents);
        }
    }
}