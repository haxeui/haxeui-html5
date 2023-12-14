package haxe.ui.backend;

import haxe.ui.events.UIEvent;

@:allow(haxe.ui.backend.ScreenImpl)
@:allow(haxe.ui.backend.ComponentImpl)
class EventImpl extends EventBase {
    @:noCompletion private var _originalEvent:js.html.Event;
    
    public override function cancel() {
        if (_originalEvent != null) {
            _originalEvent.preventDefault();
            _originalEvent.stopImmediatePropagation();
            _originalEvent.stopPropagation();                
        }
    }
    
    @:noCompletion private override function postClone(event:UIEvent) {
        event._originalEvent = this._originalEvent;
    }
}