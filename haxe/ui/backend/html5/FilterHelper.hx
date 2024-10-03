package haxe.ui.backend.html5;

import haxe.ui.backend.html5.filters.ColorMatrixFilter;
import haxe.ui.backend.html5.filters.FilterCache;
import haxe.ui.backend.html5.filters.ISVGFilter;
import haxe.ui.filters.Blur;
import haxe.ui.filters.Brightness;
import haxe.ui.filters.BoxShadow;
import haxe.ui.filters.Contrast;
import haxe.ui.filters.DropShadow;
import haxe.ui.filters.Filter;
import haxe.ui.filters.Grayscale;
import haxe.ui.filters.HueRotate;
import haxe.ui.filters.Invert;
import haxe.ui.filters.Saturate;
import haxe.ui.filters.Tint;
import haxe.ui.util.Color;
import js.html.Element;

class FilterHelper {
    public static function applyFilters(element:Element, filters:Array<Filter>) {
        if (filters != null && filters.length > 0) {
            var cssProperties:Map<String, Array<String>> = new Map<String, Array<String>>();
            var hasBoxShadow = false;
            for (filter in filters) {
                if ((filter is DropShadow)) {
                    var dropShadow:DropShadow = cast filter;
                    if (dropShadow.inner == false) {
                        addProp(cssProperties, '${dropShadow.distance}px ${dropShadow.distance + 2}px ${dropShadow.blurX - 1}px ${dropShadow.blurY - 1}px ${HtmlUtils.rgba(dropShadow.color, dropShadow.alpha)}', "box-shadow");
                    } else {
                        addProp(cssProperties, 'inset ${dropShadow.distance}px ${dropShadow.distance}px ${dropShadow.blurX}px 0px ${HtmlUtils.rgba(dropShadow.color, dropShadow.alpha)}', "box-shadow");
                    }
                } else if ((filter is BoxShadow)) {
                    hasBoxShadow = true;
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
                } else if ((filter is Tint)) {
                    var svgFilter = tintToSvg(cast filter);
                    var svgFilterInstance = FilterCache.filterInstance(svgFilter);
                    if (svgFilterInstance != null) {
                        addProps(cssProperties, 'url(#${svgFilterInstance.id})', ["-webkit-filter", "-moz-filter", "-o-filter", "filter"]);
                    }
                    var currentFilters = getFilterInstanceIds(element.style.filter);
                    for (currentFilter in currentFilters) {
                        FilterCache.dereferenceFilterInstance(currentFilter);
                    }
                } else if ((filter is Contrast)) {
                    var contrast:Contrast = cast filter;
                    addProps(cssProperties, 'contrast(${contrast.multiplier})', ["-webkit-filter", "-moz-filter", "-o-filter", "filter"]);
                } else if ((filter is HueRotate)) {
                    var hueRotate:HueRotate = cast filter;
                    addProps(cssProperties, 'hue-rotate(${hueRotate.angleDegree}deg)', ["-webkit-filter", "-moz-filter", "-o-filter", "filter"]);
                } else if ((filter is Saturate)) {
                    var saturate:Saturate = cast filter;
                    addProps(cssProperties, 'saturate(${saturate.multiplier})', ["-webkit-filter", "-moz-filter", "-o-filter", "filter"]);
                } else if ((filter is Brightness)) {
                    var brightness:Brightness = cast filter;
                    addProps(cssProperties, 'brightness(${brightness.multiplier})', ["-webkit-filter", "-moz-filter", "-o-filter", "filter"]);
                } else if ((filter is Invert)) {
                    var invert:Invert = cast filter;
                    addProps(cssProperties, 'invert(${invert.multiplier})', ["-webkit-filter", "-moz-filter", "-o-filter", "filter"]);
                } else {
                    trace("WARNING: unrecognized filter type: " + Type.getClassName(Type.getClass(filter)));
                }
            }

            if (!hasBoxShadow) {
                element.style.boxShadow = null;
                element.style.removeProperty("box-shadow");
            }
            for (key in cssProperties.keys()) {
                var values = cssProperties.get(key);
                if (key == "box-shadow") {
                    element.style.setProperty(key, values.join(", "));
                } else {
                    element.style.setProperty(key, values.join(" "));
                }
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

    // These numbers come from the CIE XYZ Color Model
    private static inline var LUMA_R = 0.212671;
    private static inline var LUMA_G = 0.71516;
    private static inline var LUMA_B = 0.072169;
    private static function tintToSvg(tint:Tint):ISVGFilter {
        var color:Color = cast tint.color;

        var r:Float = color.r / 255;
        var g:Float = color.g / 255;
        var b:Float = color.b / 255;
        var q:Float = 1 - tint.amount;

        var rA:Float = tint.amount * r;
        var gA:Float = tint.amount * g;
        var bA:Float = tint.amount * b;
        
        var filter = new ColorMatrixFilter([
            q + rA * LUMA_R, rA * LUMA_G, rA * LUMA_B, 0, 0,
            gA * LUMA_R, q + gA * LUMA_G, gA * LUMA_B, 0, 0,
            bA * LUMA_R, bA * LUMA_G, q + bA * LUMA_B, 0, 0,
            0, 0, 0, 1, 0]);
        
        return filter;
    }

    private static function getFilterInstanceIds(s:String):Array<String> {
        if (s == null) {
            return [];
        }
        var ids = [];

        var n1 = s.indexOf('url("#');
        while (n1 != -1) {
            var n2 = s.indexOf('")', n1 + 6);
            if (n2 == -1) {
                break;
            }

            var id = s.substring(n1 + 6, n2);
            ids.push(id);
            
            n1 = s.indexOf('url("#', n2);
        }

        return ids;
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