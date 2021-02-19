package haxe.ui.backend.html5.native.layouts;

import haxe.ui.core.Component;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.geom.Size;
import js.html.Element;
import js.html.ImageElement;
import js.html.SpanElement;

@:keep
class ButtonLayout extends DefaultLayout {
    public function new() {
        super();
    }

    public override function calcAutoSize(exclusions:Array<Component> = null):Size {
        //var size:Size = super.calcAutoSize();

        var textSize:Size = HtmlUtils.measureText(component.text, 0, 0, component.style.fontSize, component.style.fontName);

        var iconCX:Float = getIconWidth();
        var iconCY:Float = getIconHeight();
        var cx:Float = textSize.width;
        var cy:Float = textSize.height;
        var iconPosition:String = component.style.iconPosition;
        if (iconPosition == "top" || iconPosition == "bottom") {
            if (iconCX > cx) {
                cx = iconCX;
            }
            cy += iconCY + component.style.verticalSpacing;
        } else {
            cx += iconCX + component.style.horizontalSpacing;
            if (iconCY > cy) {
                cy = iconCY;
            }
        }

        var size:Size = new Size(cx, cy);
        size.width += paddingLeft + paddingRight;// + 6;
        size.height += paddingTop + paddingBottom;// + 2;

        return size;
    }

    private override function repositionChildren() {
        var el:Element = component.element;
        if (el.childElementCount == 2) {
            var first:Element = el.firstElementChild;
            var last:Element = el.lastElementChild;

            switch (component.style.iconPosition) {
                case "top" | "left" | null:
                    if ((first is ImageElement) == false) {
                        HtmlUtils.swapElements(first, last);
                    }
                case "right" | "bottom":
                    if ((last is ImageElement) == false) {
                        HtmlUtils.swapElements(first, last);
                    }
                default:    
            }

            var img:ImageElement = getIcon();
            if (img != null) {
                switch (component.style.iconPosition) {
                    case "top":
                        img.style.marginBottom = HtmlUtils.px(_component.style.verticalSpacing);
                    case "left":
                        img.style.marginRight = HtmlUtils.px(_component.style.horizontalSpacing);
                    case "bottom":
                        img.style.marginTop = HtmlUtils.px(_component.style.verticalSpacing);
                    case "right":
                        img.style.marginLeft = HtmlUtils.px(_component.style.horizontalSpacing);
                    default:
                        img.style.marginRight = HtmlUtils.px(_component.style.horizontalSpacing);
                }
            }

            var text:SpanElement = getText();
            if (text != null) {
                switch (component.style.iconPosition) {
                    case "left" | "right" | null:
                        text.style.display = "inline-block";
                    case "top" | "bottom":
                        text.style.display = "block";
                    default:    
                }
            }
        }
    }

    private function getIconWidth():Float {
        var cx:Float = 0;
        var icon:ImageElement = getIcon();
        if (icon != null) {
            cx = icon.offsetWidth;
        }
        return cx;
    }

    private function getIconHeight():Float {
        var cy:Float = 0;
        var icon:ImageElement = getIcon();
        if (icon != null) {
            cy = icon.offsetHeight;
        }
        return cy;
    }

    private function getIcon():ImageElement {
        var img:ImageElement = null;
        var el:Element = component.element;
        var list = el.getElementsByTagName("img");
        if (list != null && list.length == 1) {
            img = cast list.item(0);
        }
        return img;
    }

    private function getText():SpanElement {
        var span:SpanElement = null;
        var el:Element = component.element;
        var list = el.getElementsByTagName("span");
        if (list != null && list.length == 1) {
            span = cast list.item(0);
        }
        return span;
    }
}