package haxe.ui.backend.html5;

import haxe.ui.filters.Blur;
import haxe.ui.filters.BoxShadow;
import haxe.ui.filters.DropShadow;
import haxe.ui.filters.Filter;
import haxe.ui.filters.Grayscale;
import js.html.Element;

class FilterHelper {
    public static function applyFilters(element:Element, filters:Array<Filter>) {
        if (filters != null && filters.length > 0) {
            var cssProperties:Map<String, Array<String>> = new Map<String, Array<String>>();
            for (filter in filters) {
                if ((filter is DropShadow)) {
                    var dropShadow:DropShadow = cast filter;
                    if (dropShadow.inner == false) {
                        addProp(cssProperties, '${dropShadow.distance}px ${dropShadow.distance + 2}px ${dropShadow.blurX - 1}px ${dropShadow.blurY - 1}px ${HtmlUtils.rgba(dropShadow.color, dropShadow.alpha)}', "box-shadow");
                    } else {
                        addProp(cssProperties, 'inset ${dropShadow.distance}px ${dropShadow.distance}px ${dropShadow.blurX}px 0px ${HtmlUtils.rgba(dropShadow.color, dropShadow.alpha)}', "box-shadow");
                    }
                } else if ((filter is BoxShadow)) {
                    var boxShadow:BoxShadow = cast filter;
                    if (boxShadow.inset == false) {
                        addProp(cssProperties, '${boxShadow.offsetX}px ${boxShadow.offsetY}px ${boxShadow.blurRadius}px ${boxShadow.spreadRadius}px ${HtmlUtils.rgba(boxShadow.color, boxShadow.alpha)}', "box-shadow");
                    } else {
                        addProp(cssProperties, 'inset ${boxShadow.offsetX}px ${boxShadow.offsetY}px ${boxShadow.blurRadius}px ${boxShadow.spreadRadius}px ${HtmlUtils.rgba(boxShadow.color, boxShadow.alpha)}', "box-shadow");
                    }
                } else if ((filter is Blur)) {
                    var blur:Blur = cast filter;
                    addProps(cssProperties, 'blur(${blur.amount}px)', ["-webkit-filter", "-moz-filter", "-o-filter", "filter"]);
                } else if ((filter is Grayscale)) {
                    var grayscale:Grayscale = cast filter;
                    addProps(cssProperties, 'grayscale(${grayscale.amount}%)', ["-webkit-filter", "-moz-filter", "-o-filter", "filter"]);
                } else {
                    trace("WARNING: unrecognized filter type: " + Type.getClassName(Type.getClass(filter)));
                }
            }

            for (key in cssProperties.keys()) {
                var values = cssProperties.get(key);
                element.style.setProperty(key, values.join(", "));
            }
        } else {
            element.style.filter = null;
            element.style.boxShadow = null;
            element.style.removeProperty("box-shadow");
            element.style.removeProperty("-webkit-filter");
            element.style.removeProperty("-moz-filter");
            element.style.removeProperty("-o-filter");
            element.style.removeProperty("filter");
        }
    }

    private static inline function addProps(cssProperties:Map<String, Array<String>>, value:String, names:Array<String>) {
        for (name in names) {
            addProp(cssProperties, value, name);
        }
    }

    private static inline function addProp(cssProperties:Map<String, Array<String>>, value:String, name:String) {
        if (!cssProperties.exists(name)) {
            cssProperties.set(name, []);
        }
        cssProperties.get(name).push(value);
    }
}