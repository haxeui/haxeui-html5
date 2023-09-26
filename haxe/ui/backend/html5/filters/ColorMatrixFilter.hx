package haxe.ui.backend.html5.filters;

import haxe.crypto.Md5;
import js.Browser;
import js.html.Element;

class ColorMatrixFilter implements ISVGFilter {
    public var values:Array<Float> = null;
    public var svg:Element = null;

    public function new(values:Array<Float>, svg:Element = null) {
        this.values = values;
        this.svg = svg;
    }

    public function build():Element {
        if (values == null) {
            return null;
        }
        var id = hash();
        var ns = "http://www.w3.org/2000/svg";
        var filter = Browser.document.createElementNS(ns, "filter");
        filter.setAttribute("id", id);

        var matrix = Browser.document.createElementNS(ns, "feColorMatrix");
        matrix.setAttribute("in", "SourceGraphic");
        matrix.setAttribute("type", "matrix");
        matrix.setAttribute("values", values.join(" "));
        filter.appendChild(matrix);
        svg.appendChild(filter);

        return filter;
    }

    public function hash() {
        if (values == null) {
            return null;
        }

        var s:StringBuf = new StringBuf();
        s.add("tint_");
        for (v in values) {
            s.add(v);
            s.add("_");
        }

        return Md5.encode(s.toString());
    }
}