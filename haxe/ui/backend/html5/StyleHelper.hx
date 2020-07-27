package haxe.ui.backend.html5;

import haxe.ui.assets.ImageInfo;
import haxe.ui.backend.ComponentImpl;
import haxe.ui.geom.Rectangle;
import haxe.ui.geom.Slice9;
import haxe.ui.styles.Style;
import js.html.CSSStyleDeclaration;
import js.html.CanvasRenderingContext2D;
import js.html.Element;
import js.html.Image;

class StyleHelper {
    @:access(haxe.ui.backend.ComponentImpl)
    public static function apply(component:ComponentImpl, width:Float, height:Float, style:Style) {
        var element:Element = component.element;
        var css:CSSStyleDeclaration = element.style;

        var slice:Rectangle = null;
        if (style.backgroundImageSliceTop != null &&
            style.backgroundImageSliceLeft != null &&
            style.backgroundImageSliceBottom != null &&
            style.backgroundImageSliceRight != null) {
            slice = new Rectangle(style.backgroundImageSliceLeft,
                                  style.backgroundImageSliceTop,
                                  style.backgroundImageSliceRight - style.backgroundImageSliceLeft,
                                  style.backgroundImageSliceBottom - style.backgroundImageSliceTop);
        }

        if (slice != null) {
            width = Math.fround(width);
            height = Math.fround(height);
        }

        css.width = HtmlUtils.px(width);
        css.height = HtmlUtils.px(height);

        // border size
        if (style.borderLeftSize != null &&
            style.borderLeftSize == style.borderRightSize &&
            style.borderLeftSize == style.borderBottomSize &&
            style.borderLeftSize == style.borderTopSize) { // full border

            if (style.borderLeftSize > 0) {
                css.borderWidth = HtmlUtils.px(style.borderLeftSize);
                css.borderStyle = "solid";
            } else {
                css.removeProperty("border-width");
                css.removeProperty("border-style");
            }
        } else if (style.borderLeftSize == null &&
            style.borderRightSize == null &&
            style.borderBottomSize == null &&
            style.borderTopSize == null) { // no border
            css.removeProperty("border-width");
            css.removeProperty("border-style");
        } else { // compound border
            if (style.borderTopSize != null && style.borderTopSize > 0) {
               css.borderTopWidth = HtmlUtils.px(style.borderTopSize);
               css.borderTopStyle = "solid";
            } else {
                css.removeProperty("border-top-width");
                css.removeProperty("border-top-style");
            }

            if (style.borderLeftSize != null && style.borderLeftSize > 0) {
               css.borderLeftWidth = HtmlUtils.px(style.borderLeftSize);
               css.borderLeftStyle = "solid";
            } else {
                css.removeProperty("border-left-width");
                css.removeProperty("border-left-style");
            }

            if (style.borderBottomSize != null && style.borderBottomSize > 0) {
               css.borderBottomWidth = HtmlUtils.px(style.borderBottomSize);
               css.borderBottomStyle = "solid";
            } else {
                css.removeProperty("border-bottom-width");
                css.removeProperty("border-bottom-style");
            }

            if (style.borderRightSize != null && style.borderRightSize > 0) {
               css.borderRightWidth = HtmlUtils.px(style.borderRightSize);
               css.borderRightStyle = "solid";
            } else {
                css.removeProperty("border-right-width");
                css.removeProperty("border-right-style");
            }
        }

        // border colour
        if (style.borderLeftColor != null &&
            style.borderLeftColor == style.borderRightColor &&
            style.borderLeftColor == style.borderBottomColor &&
            style.borderLeftColor == style.borderTopColor) {

            if (style.borderOpacity == null) {
                css.borderColor = HtmlUtils.color(style.borderLeftColor);
            } else {
                css.borderColor = HtmlUtils.rgba(style.borderLeftColor, style.borderOpacity);
            }
        } else if (style.borderLeftColor == null &&
            style.borderRightColor == null &&
            style.borderBottomColor == null &&
            style.borderTopColor == null) {
            css.removeProperty("border-color");
        } else {
            if (style.borderTopColor != null) {
                if (style.borderOpacity == null) {
                    css.borderTopColor = HtmlUtils.color(style.borderTopColor);
                } else {
                    css.borderTopColor = HtmlUtils.rgba(style.borderTopColor, style.borderOpacity);
                }
            } else {
                css.removeProperty("border-top-color");
            }

            if (style.borderLeftColor != null) {
                if (style.borderOpacity == null) {
                    css.borderLeftColor = HtmlUtils.color(style.borderLeftColor);
                } else {
                    css.borderLeftColor = HtmlUtils.rgba(style.borderLeftColor, style.borderOpacity);
                }
            } else {
                css.removeProperty("border-left-color");
            }

            if (style.borderBottomColor != null) {
                if (style.borderOpacity == null) {
                    css.borderBottomColor = HtmlUtils.color(style.borderBottomColor);
                } else {
                    css.borderBottomColor = HtmlUtils.rgba(style.borderBottomColor, style.borderOpacity);
                }
            } else {
                css.removeProperty("border-bottom-color");
            }

            if (style.borderRightColor != null) {
                if (style.borderOpacity == null) {
                    css.borderRightColor = HtmlUtils.color(style.borderRightColor);
                } else {
                    css.borderRightColor = HtmlUtils.rgba(style.borderRightColor, style.borderOpacity);
                }
            } else {
                css.removeProperty("border-right-color");
            }
        }

        // background
        var background:Array<String> = [];
        if (style.backgroundColor != null) {
            if (style.backgroundColorEnd != null && style.backgroundColorEnd != style.backgroundColor) {
                css.removeProperty("background-color");
                var gradientStyle = style.backgroundGradientStyle;
                if (gradientStyle == null) {
                    gradientStyle = "vertical";
                }

                if (style.backgroundOpacity != null) {
                    if (gradientStyle == "vertical") {
                        background.push('linear-gradient(to bottom, ${HtmlUtils.rgba(style.backgroundColor, style.backgroundOpacity)}, ${HtmlUtils.rgba(style.backgroundColorEnd, style.backgroundOpacity)})');
                    } else if (gradientStyle == "horizontal") {
                        background.push('linear-gradient(to right, ${HtmlUtils.rgba(style.backgroundColor, style.backgroundOpacity)}, ${HtmlUtils.rgba(style.backgroundColorEnd, style.backgroundOpacity)})');
                    }
                } else {
                    if (gradientStyle == "vertical") {
                        background.push('linear-gradient(to bottom, ${HtmlUtils.color(style.backgroundColor)}, ${HtmlUtils.color(style.backgroundColorEnd)})');
                    } else if (gradientStyle == "horizontal") {
                        background.push('linear-gradient(to right, ${HtmlUtils.color(style.backgroundColor)}, ${HtmlUtils.color(style.backgroundColorEnd)})');
                    }
                }
            } else {
                css.removeProperty("background");
                if (style.backgroundOpacity != null) {
                    css.backgroundColor = HtmlUtils.rgba(style.backgroundColor, style.backgroundOpacity);
                } else {
                    css.backgroundColor = HtmlUtils.color(style.backgroundColor);
                }
            }
        } else {
            css.removeProperty("background");
            css.removeProperty("background-color");
        }

        if (style.borderRadius != null && style.borderRadius > 0
            && (style.borderRadiusTopLeft == null || style.borderRadiusTopLeft == style.borderRadius)
            && (style.borderRadiusTopRight == null || style.borderRadiusTopRight == style.borderRadius)
            && (style.borderRadiusBottomLeft == null || style.borderRadiusBottomLeft == style.borderRadius)
            && (style.borderRadiusBottomRight == null || style.borderRadiusBottomRight == style.borderRadius)) {
            css.borderRadius = HtmlUtils.px(style.borderRadius);
        } else if ((style.borderRadiusTopLeft != null && style.borderRadiusTopLeft > 0)
            || (style.borderRadiusTopRight != null && style.borderRadiusTopRight > 0)
            || (style.borderRadiusBottomLeft != null && style.borderRadiusBottomLeft > 0)
            || (style.borderRadiusBottomRight != null && style.borderRadiusBottomRight > 0)) {
                if (style.borderRadiusTopLeft != null && style.borderRadiusTopLeft > 0) {
                    css.borderTopLeftRadius = HtmlUtils.px(style.borderRadiusTopLeft);
                } else {
                    css.removeProperty("border-top-left-radius");
                }
                if (style.borderRadiusTopRight != null && style.borderRadiusTopRight > 0) {
                    css.borderTopRightRadius = HtmlUtils.px(style.borderRadiusTopRight);
                } else {
                    css.removeProperty("border-top-right-radius");
                }
                if (style.borderRadiusBottomLeft != null && style.borderRadiusBottomLeft > 0) {
                    css.borderBottomLeftRadius = HtmlUtils.px(style.borderRadiusBottomLeft);
                } else {
                    css.removeProperty("border-bottom-left-radius");
                }
                if (style.borderRadiusBottomRight != null && style.borderRadiusBottomRight > 0) {
                    css.borderBottomRightRadius = HtmlUtils.px(style.borderRadiusBottomRight);
                } else {
                    css.removeProperty("border-bottom-right-radius");
                }
        } else {
            css.removeProperty("border-radius");
        }

        // background image
        if (style.backgroundImage != null) {
            Toolkit.assets.getImage(style.backgroundImage, function(imageInfo:ImageInfo) {
                if (imageInfo == null) {
                    return;
                }

                var imageRect:Rectangle = new Rectangle(0, 0, imageInfo.width, imageInfo.height);
                if (style.backgroundImageClipTop != null &&
                    style.backgroundImageClipLeft != null &&
                    style.backgroundImageClipBottom != null &&
                    style.backgroundImageClipRight != null) {
                        imageRect = new Rectangle(style.backgroundImageClipLeft,
                                                  style.backgroundImageClipTop,
                                                  style.backgroundImageClipRight - style.backgroundImageClipLeft,
                                                  style.backgroundImageClipBottom - style.backgroundImageClipTop);
                }

                if (slice == null) {
                    if (imageRect.width == imageInfo.width && imageRect.height == imageInfo.height) {
                        background.push('url(${imageInfo.data.src})');
                        if (style.backgroundImageRepeat == null) {
                            css.backgroundRepeat = "no-repeat";
                        } else if (style.backgroundImageRepeat == "repeat") {
                            css.backgroundRepeat = "repeat";
                        } else if (style.backgroundImageRepeat == "stretch") {
                            css.backgroundRepeat = "no-repeat";
                            css.backgroundSize = '${HtmlUtils.px(width)} ${HtmlUtils.px(height)}';
                        }
                        background.reverse();
                        css.background = background.join(",");
                    } else {
                        var canvas = component.getCanvas(width, height);
                        var ctx:CanvasRenderingContext2D = canvas.getContext2d();
                        ctx.clearRect(0, 0, width, height);
                        paintBitmap(ctx, cast imageInfo.data, imageRect, new Rectangle(0, 0, width, height));
                    }
                } else {
                    var rects:Slice9Rects = Slice9.buildRects(width, height, imageRect.width, imageRect.height, slice);
                    var srcRects:Array<Rectangle> = rects.src;
                    var dstRects:Array<Rectangle> = rects.dst;

                    var canvas = component.getCanvas(width, height);
                    var ctx:CanvasRenderingContext2D = canvas.getContext2d();
                    ctx.clearRect(0, 0, width, height);
                    ctx.imageSmoothingEnabled = false;

                    for (i in 0...srcRects.length) {
                        var srcRect = new Rectangle(srcRects[i].left + imageRect.left,
                                                    srcRects[i].top + imageRect.top,
                                                    srcRects[i].width,
                                                    srcRects[i].height);
                        var dstRect = dstRects[i];
                        paintBitmap(ctx, cast imageInfo.data, srcRect, dstRect);
                    }
                }
            });
        } else {
            component.removeCanvas();
            css.background = background[0];
        }
    }

    private static function paintBitmap(ctx:CanvasRenderingContext2D, img:Image, srcRect:Rectangle, dstRect:Rectangle) {
        if (srcRect.width == 0 || srcRect.height == 0) {
            return;
        }
        if (dstRect.width == 0 || dstRect.height == 0) {
            return;
        }
        ctx.drawImage(img, Std.int(srcRect.left), Std.int(srcRect.top), Std.int(srcRect.width), Std.int(srcRect.height), Std.int(dstRect.left), Std.int(dstRect.top), Std.int(dstRect.width), Std.int(dstRect.height));
    }
}