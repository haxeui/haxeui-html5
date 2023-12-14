package haxe.ui.backend.html5.filters;

import js.html.Element;

interface ISVGFilter {
    public var svg:Element;
    public function hash():String;
    public function build():Element;
}