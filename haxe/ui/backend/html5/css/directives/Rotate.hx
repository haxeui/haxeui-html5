package haxe.ui.backend.html5.css.directives;

import haxe.ui.core.Component;
import haxe.ui.styles.DirectiveHandler;
import haxe.ui.styles.ValueTools;
import haxe.ui.styles.elements.Directive;

class Rotate extends DirectiveHandler {
    public override function apply(component:Component, directive:Directive) {
        switch (directive.value) {
            case VNone:
                component.element.style.transform = null;
            case VNumber(v):    
                component.element.style.transform = 'rotate(${v}deg)';
            case _:
        }
    }
}