package haxe.ui.backend.html5.css.directives;

import haxe.ui.core.Component;
import haxe.ui.styles.DirectiveHandler;
import haxe.ui.styles.ValueTools;
import haxe.ui.styles.elements.Directive;

class ClipPath extends DirectiveHandler {
    public override function apply(component:Component, directive:Directive) {
        switch (directive.value) {
            case VNone:
                component.element.style.clipPath = null;
            case VCall(f, vl):
                if (f == "inset") {
                    switch (vl[0]) {
                        case VComposite(vl):
                            var v0 = ValueTools.calcDimension(vl[0]);
                            var v1 = ValueTools.calcDimension(vl[1]);
                            var v2 = ValueTools.calcDimension(vl[2]);
                            var v3 = ValueTools.calcDimension(vl[3]);
                            component.element.style.clipPath = 'inset(${v0}px ${v1}px ${v2}px ${v3}px)';
                        case _:
                    }
                }
            case _:
        }
    }
}