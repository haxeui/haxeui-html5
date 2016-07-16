package haxe.ui.html5.native.size;

import haxe.ui.layouts.DelegateLayout.DelegateLayoutSize;
import js.html.Element;
import js.html.ImageElement;

@:keep
class ButtonSize extends DelegateLayoutSize {
	public function new() {
		
	}

	private override function get_width():Float {
		var size = HtmlUtils.measureText(component.text);
        
        var iconCX:Float = getIconWidth();
        var cx:Float = size.width;
        var iconPosition:String = component.style.iconPosition;
        if (iconPosition == "top" || iconPosition == "bottom") {
            if (iconCX > cx) {
                cx = iconCX;
            }
        } else {
            cx += iconCX + component.style.horizontalSpacing;
        }
        
		return cx + getInt("incrementWidthBy");
	}
	
	private override function get_height():Float {
		var size = HtmlUtils.measureText(component.text);
        
        var iconCY:Float = getIconHeight();
        var cy:Float = size.height;
        var iconPosition:String = component.style.iconPosition;
        if (iconPosition == "top" || iconPosition == "bottom") {
            cy += iconCY + component.style.verticalSpacing;
        } else {
            if (iconCY > cy) {
                cy = iconCY;
            }
        }
        
		return cy + getInt("incrementHeightBy");
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
}