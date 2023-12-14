package haxe.ui.backend.html5.filters;

import js.Browser;
import js.html.Element;

class FilterCache {
    public static function filterInstance(filter:ISVGFilter):Element {
        var hash = filter.hash();
        var s = svg();

        var el = null;
        for (child in s.children) {
            if (child.id == hash) {
                el = child;
                break;
            }
        }

        if (el == null) {
            filter.svg = s;
            el = filter.build();
            if (el != null) {
                s.appendChild(el);
            }
        }


        var refCount:Null<Int> = null;
        if (el.dataset.refCount != null) {
            refCount = Std.parseInt(el.dataset.refCount);
        }
        if (refCount == null) {
            refCount = 0;
        }
        refCount++;
        el.dataset.refCount = Std.string(refCount);

        return el;
    }

    public static function dereferenceFilterInstance(id:String) {
        var s = svg();
        
        var el = null;
        for (child in s.children) {
            if (child.id == id) {
                el = child;
                break;
            }
        }

        if (el == null) {
            return;
        }

        var refCount:Null<Int> = null;
        if (el.dataset.refCount != null) {
            refCount = Std.parseInt(el.dataset.refCount);
        }
        if (refCount == null) {
            refCount = 0;
        }
        refCount--;
        if (refCount <= 0) {
            s.removeChild(el);
        }
        el.dataset.refCount = Std.string(refCount);
    }

    private static var _svg:Element = null;
    private static function svg():Element {
        if (_svg != null) {
            return _svg;
        }

        _svg = Browser.document.createElementNS("http://www.w3.org/2000/svg", "svg");
        _svg.style.position = "absolute";
        _svg.style.top = "-99999px"; // position off-screen!
        _svg.style.left = "-99999px"; // position off-screen!
        _svg.style.visibility = "none";
        Browser.document.body.appendChild(_svg);
        return _svg;
    }
}