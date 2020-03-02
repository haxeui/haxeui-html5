package haxe.ui.backend.html5;

import haxe.ui.assets.ImageInfo;
import haxe.ui.backend.ComponentImpl;
import haxe.ui.core.Component;
import haxe.ui.styles.Style;
import haxe.ui.geom.Rectangle;
import haxe.ui.geom.Slice9;
import haxe.ui.styles.Style2;
import js.Browser;
import js.html.CSSStyleDeclaration;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.Element;
import js.html.Image;

class StyleHelper {
    @:access(haxe.ui.core.ComponentImpl)
    public static function apply(component:ComponentImpl, width:Float, height:Float, style:Style) {
        var element:Element = component.element;
        var css:CSSStyleDeclaration = element.style;

        css.width = HtmlUtils.px(width);
        css.height = HtmlUtils.px(height);

        
        var style2:Style2 = component.computedStyle;
        var newBorderStyle:Bool = false;
        
        if (style2.border != null && style2.border.isEmpty == false) {
            if (style2.border.isCompound == false) { // full border
                if (style2.border.left != null && style2.border.left.isEmpty == false) {
                    if (style2.border.left.width != null) {
                        css.borderWidth = HtmlUtils.px(style2.border.left.width);
                        css.borderStyle = "solid";
                    } else {
                        css.removeProperty("border-width");
                        css.removeProperty("border-style");
                    }
                    if (style2.border.left.color != null && style2.border.left.color.isNone == false) {
                        if (style2.border.opacity == null) {
                            css.borderColor = HtmlUtils.color(style2.border.left.color);
                        } else {
                            css.borderColor = HtmlUtils.rgba(style2.border.left.color, style2.border.opacity);
                        }
                    } else {
                        css.removeProperty("border-color");
                    }
                }
                newBorderStyle = true;
            } else { // compound border
                // top
                if (style2.border.top != null && style2.border.top.isEmpty == false) {
                    if (style2.border.top.width != null) {
                        css.borderTopWidth = HtmlUtils.px(style2.border.top.width);
                        css.borderTopStyle = "solid";
                    } else {
                        css.removeProperty("border-top-width");
                        css.removeProperty("border-top-style");
                    }
                    if (style2.border.top.color != null && style2.border.top.color.isNone == false) {
                        if (style2.border.opacity == null) {
                            css.borderTopColor = HtmlUtils.color(style2.border.top.color);
                        } else {
                            css.borderTopColor = HtmlUtils.rgba(style2.border.top.color, style2.border.opacity);
                        }
                    } else {
                        css.removeProperty("border-top-color");
                    }
                }
                // left
                if (style2.border.left != null && style2.border.left.isEmpty == false) {
                    if (style2.border.left.width != null) {
                        css.borderLeftWidth = HtmlUtils.px(style2.border.left.width);
                        css.borderLeftStyle = "solid";
                    } else {
                        css.removeProperty("border-left-width");
                        css.removeProperty("border-left-style");
                    }
                    if (style2.border.left.color != null && style2.border.left.color.isNone == false) {
                        if (style2.border.opacity == null) {
                            css.borderLeftColor = HtmlUtils.color(style2.border.left.color);
                        } else {
                            css.borderLeftColor = HtmlUtils.rgba(style2.border.left.color, style2.border.opacity);
                        }
                    } else {
                        css.removeProperty("border-left-color");
                    }
                }
                // bottom
                if (style2.border.bottom != null && style2.border.bottom.isEmpty == false) {
                    if (style2.border.bottom.width != null) {
                        css.borderBottomWidth = HtmlUtils.px(style2.border.bottom.width);
                        css.borderBottomStyle = "solid";
                    } else {
                        css.removeProperty("border-bottom-width");
                        css.removeProperty("border-bottom-style");
                    }
                    if (style2.border.bottom.color != null && style2.border.bottom.color.isNone == false) {
                        if (style2.border.opacity == null) {
                            css.borderBottomColor = HtmlUtils.color(style2.border.bottom.color);
                        } else {
                            css.borderBottomColor = HtmlUtils.rgba(style2.border.bottom.color, style2.border.opacity);
                        }
                    } else {
                        css.removeProperty("border-bottom-color");
                    }
                }
                // right
                if (style2.border.right != null && style2.border.right.isEmpty == false) {
                    if (style2.border.right.width != null) {
                        css.borderRightWidth = HtmlUtils.px(style2.border.right.width);
                        css.borderRightStyle = "solid";
                    } else {
                        css.removeProperty("border-right-width");
                        css.removeProperty("border-right-style");
                    }
                    if (style2.border.right.color != null && style2.border.right.color.isNone == false) {
                        if (style2.border.opacity == null) {
                            css.borderRightColor = HtmlUtils.color(style2.border.right.color);
                        } else {
                            css.borderRightColor = HtmlUtils.rgba(style2.border.right.color, style2.border.opacity);
                        }
                    } else {
                        css.removeProperty("border-right-color");
                    }
                }
            }
        } else {
            css.removeProperty("border-width");
            css.removeProperty("border-style");
        }
        
        /*
        if (newBorderStyle == false) {
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
                   css.borderTopColor = HtmlUtils.color(style.borderTopColor);
                } else {
                    css.removeProperty("border-top-color");
                }

                if (style.borderLeftColor != null) {
                   css.borderLeftColor = HtmlUtils.color(style.borderLeftColor);
                } else {
                    css.removeProperty("border-left-color");
                }

                if (style.borderBottomColor != null) {
                   css.borderBottomColor = HtmlUtils.color(style.borderBottomColor);
                } else {
                    css.removeProperty("border-bottom-color");
                }

                if (style.borderRightColor != null) {
                   css.borderRightColor = HtmlUtils.color(style.borderRightColor);
                } else {
                    css.removeProperty("border-right-color");
                }
            }
        }
        */

        // background
        var background:Array<String> = [];
        //var newBackgroundStyle = false;
        
        if (style2.backgroundColors != null) {
            var backgroundColors:Array<StyleColorBlock> = style2.backgroundColors;
            css.removeProperty("background-color");
            if (backgroundColors.length == 1) { // solid
                if (style2.backgroundOpacity != null) {
                    css.backgroundColor = HtmlUtils.rgba(backgroundColors[0].color, style2.backgroundOpacity);
                } else {
                    css.backgroundColor = HtmlUtils.color(backgroundColors[0].color);
                }
            } else if (backgroundColors.length != 0) { // gradient
                var gradientStyle = style2.backgroundStyle;
                if (gradientStyle == null) {
                    gradientStyle = "vertical";
                }
                
                var linearGradientFromTo = "to bottom";
                if (gradientStyle == "horizontal") {
                    linearGradientFromTo = "to right";
                }
                
                var gradientParts:Array<String> = [];
                for (backgroundPair in backgroundColors) {
                    var blockString = '${backgroundPair.block}%';
                    if (backgroundPair.block == null) {
                        blockString = '';
                    }
                    if (style2.backgroundOpacity != null) {
                        gradientParts.push('${HtmlUtils.rgba(backgroundPair.color, style2.backgroundOpacity)} ${blockString}');
                    } else {
                        gradientParts.push('${HtmlUtils.color(backgroundPair.color)} ${blockString}');
                    }
                }
                
                background.push('linear-gradient(${linearGradientFromTo}, ${gradientParts.join(",")})');
            }
            //newBackgroundStyle = true;
        } else {
            css.removeProperty("background");
            css.removeProperty("background-color");
        }
        
        /*
        if (style2.backgroundColors != null) {
            var s = style2.backgroundColors;
            switch (style2.backgroundColors) {
                case Some(v):
                    trace("-----------------------> WE GOT COLS!! - " + v.length);
                    css.removeProperty("background-color");
                    if (v.length == 1) { // solid
                        if (style.backgroundOpacity != null) {
                            css.backgroundColor = HtmlUtils.rgba(v[0].color, style.backgroundOpacity);
                        } else {
                            css.backgroundColor = HtmlUtils.color(v[0].color);
                        }
                    } else { // gradient
                        var gradientStyle = style.backgroundGradientStyle;
                        if (gradientStyle == null) {
                            gradientStyle = "vertical";
                        }
                        
                        var linearGradientFromTo = "to bottom";
                        if (gradientStyle == "horizontal") {
                            linearGradientFromTo = "to right";
                        }
                        
                        var gradientParts:Array<String> = [];
                        for (backgroundPair in v) {
                            if (style.backgroundOpacity != null) {
                                gradientParts.push('${HtmlUtils.rgba(backgroundPair.color, style.backgroundOpacity)} ${backgroundPair.block}%');
                            } else {
                                gradientParts.push('${HtmlUtils.color(backgroundPair.color)} ${backgroundPair.block}%');
                            }
                        }
                        
                        background.push('linear-gradient(${linearGradientFromTo}, ${gradientParts.join(",")})');
                    }
                case _:    
            }
            newBackgroundStyle = true;
        } else {
            css.removeProperty("background");
            css.removeProperty("background-color");
        }
        */
        
        /*
        if (newBackgroundStyle == false) {
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
        }
        */

        /*
        if (style.borderRadius != null && style.borderRadius > 0) {
            css.borderRadius = HtmlUtils.px(style.borderRadius);
        } else {
            css.removeProperty("border-radius");
        }
        */
        if (style2.border.radius != null) {
            var borderRadius:Float = style2.border.radius;
            css.borderRadius = HtmlUtils.px(borderRadius);
        } else {
            css.removeProperty("border-radius");
        }

        

        
        
        if (style2.backgroundImage != null) {
            if (style2.backgroundImage.resource != null) {
                Toolkit.assets.getImage(style2.backgroundImage.resource, function(imageInfo:ImageInfo) {
                    if (imageInfo == null) {
                        return;
                    }
                    
                    var imageRect:Rectangle = new Rectangle(0, 0, imageInfo.width, imageInfo.height);
                    if (style2.backgroundImage.clip != null && style2.backgroundImage.clip.isNull == false) {
                        imageRect = style2.backgroundImage.clip;
                    }
                    
                    var slice:Rectangle = null;
                    if (style2.backgroundImage.slice != null && style2.backgroundImage.slice.isNull == false) {
                        slice = style2.backgroundImage.slice;
                    }
                    
                    var backgroundImageRepeat = null;
                    var backgroundImageSize = null;
                    if (slice == null) {
                        if (imageRect.width == imageInfo.width && imageRect.height == imageInfo.height) {
                            background.push('url(${imageInfo.data.src})');
                            if (style2.backgroundImage.repeat == null) {
                                backgroundImageRepeat = "no-repeat";
                            } else if (style2.backgroundImage.repeat == "repeat") {
                                backgroundImageRepeat = "repeat";
                            } else if (style2.backgroundImage.repeat == "stretch") {
                                backgroundImageRepeat = "no-repeat";
                                backgroundImageSize = '${HtmlUtils.px(width)} ${HtmlUtils.px(height)}';
                            }
                        } else {
                            var canvas:CanvasElement = Browser.document.createCanvasElement();
                            canvas.width = cast width;
                            canvas.height = cast height;
                            var ctx:CanvasRenderingContext2D = canvas.getContext2d();
                            paintBitmap(ctx, cast imageInfo.data, imageRect, new Rectangle(0, 0, width, height));
                            var data = canvas.toDataURL();
                            background.push('url(${data})');
                        }
                    } else {
                        var rects:Slice9Rects = Slice9.buildRects(width, height, imageRect.width, imageRect.height, slice);
                        var srcRects:Array<Rectangle> = rects.src;
                        var dstRects:Array<Rectangle> = rects.dst;

                        var canvas:CanvasElement = Browser.document.createCanvasElement();
                        canvas.width = cast width;
                        canvas.height = cast height;
                        var ctx:CanvasRenderingContext2D = canvas.getContext2d();
                        ctx.imageSmoothingEnabled = false;

                        for (i in 0...srcRects.length) {
                            var srcRect = new Rectangle(srcRects[i].left + imageRect.left,
                                                        srcRects[i].top + imageRect.top,
                                                        srcRects[i].width,
                                                        srcRects[i].height);
                            var dstRect = dstRects[i];
                            paintBitmap(ctx, cast imageInfo.data, srcRect, dstRect);
                        }

                        var data = canvas.toDataURL();
                        background.push('url(${data})');
                    }
                    
                    background.reverse();
                    css.background = background.join(",");
                    if (backgroundImageRepeat != null) {
                        css.backgroundRepeat = backgroundImageRepeat;
                    }
                    if (backgroundImageSize != null) {
                        css.backgroundSize = backgroundImageSize;
                    }
                });
            } else {
                css.background = background[0];
            }
        } else {
            css.background = background[0];
        }
        
        
        
        
        
        /*
        
        if (newImage == false) {
            // background image
            if (style.backgroundImage != null) {
                //if (component.element.nodeName == "BUTTON") {
                //    css.border = "none";
                //}

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
                    var backgroundImageRepeat = null;
                    var backgroundImageSize = null;
                    if (slice == null) {
                        if (imageRect.width == imageInfo.width && imageRect.height == imageInfo.height) {
                            background.push('url(${imageInfo.data.src})');
                            if (style.backgroundImageRepeat == null) {
                                backgroundImageRepeat = "no-repeat";
                            } else if (style.backgroundImageRepeat == "repeat") {
                                backgroundImageRepeat = "repeat";
                            } else if (style.backgroundImageRepeat == "stretch") {
                                backgroundImageRepeat = "no-repeat";
                                backgroundImageSize = '${HtmlUtils.px(width)} ${HtmlUtils.px(height)}';
                            }
                        } else {
                            var canvas:CanvasElement = Browser.document.createCanvasElement();
                            canvas.width = cast width;
                            canvas.height = cast height;
                            var ctx:CanvasRenderingContext2D = canvas.getContext2d();
                            paintBitmap(ctx, cast imageInfo.data, imageRect, new Rectangle(0, 0, width, height));
                            var data = canvas.toDataURL();
                            background.push('url(${data})');
                        }
                    } else {
                        var rects:Slice9Rects = Slice9.buildRects(width, height, imageRect.width, imageRect.height, slice);
                        var srcRects:Array<Rectangle> = rects.src;
                        var dstRects:Array<Rectangle> = rects.dst;

                        var canvas:CanvasElement = Browser.document.createCanvasElement();
                        canvas.width = cast width;
                        canvas.height = cast height;
                        var ctx:CanvasRenderingContext2D = canvas.getContext2d();
                        ctx.imageSmoothingEnabled = false;

                        for (i in 0...srcRects.length) {
                            var srcRect = new Rectangle(srcRects[i].left + imageRect.left,
                                                        srcRects[i].top + imageRect.top,
                                                        srcRects[i].width,
                                                        srcRects[i].height);
                            var dstRect = dstRects[i];
                            paintBitmap(ctx, cast imageInfo.data, srcRect, dstRect);
                        }

                        var data = canvas.toDataURL();
                        background.push('url(${data})');
                    }
                    
                    background.reverse();
                    css.background = background.join(",");
                    if (backgroundImageRepeat != null) {
                        css.backgroundRepeat = backgroundImageRepeat;
                    }
                    if (backgroundImageSize != null) {
                        css.backgroundSize = backgroundImageSize;
                    }
                });
            } else {
                css.background = background[0];
            }
        }
        */
    }

    private static function paintBitmap(ctx:CanvasRenderingContext2D, img:Image, srcRect:Rectangle, dstRect:Rectangle) {
        ctx.drawImage(img, srcRect.left, srcRect.top, srcRect.width, srcRect.height, dstRect.left, dstRect.top, dstRect.width, dstRect.height);
    }
}