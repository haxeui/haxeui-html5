package haxe.ui.core;

import haxe.ui.assets.ImageInfo;
import haxe.ui.core.Component;
import haxe.ui.html5.HtmlUtils;
import js.Browser;
import js.html.CSSStyleDeclaration;
import js.html.ImageElement;

class ImageDisplayBase {
	public var parentComponent:Component;
	public var aspectRatio:Float = 1; // width x height
	
	public var element:ImageElement;
	
	public function new() {
		element = Browser.document.createImageElement();
		element.style.position = "absolute";
	}

	private var _left:Float = 0;
	public var left(get, set):Float;
	private function get_left():Float {
		return _left;
	}
	private function set_left(value:Float):Float {
		if (value == _left) {
			//return value;
		}
		
		_left = value;
		updatePos();
		return value;
	}

	private var _top:Float = 0;
	public var top(get, set):Float;
	private function get_top():Float {
		return _top;
	}
	private function set_top(value:Float):Float {
		if (value == _top) {
			//return value;
		}
		
		_top = value;
		updatePos();
		return value;
	}
	
	private var _imageWidth:Float = 0;
	public var imageWidth(get, set):Float;	
	public function set_imageWidth(value:Float):Float {
		if (_imageWidth == value || value <= 0) {
			return value;
		}
		_imageWidth = value;
		updateSize();
		return value;
	}
	
	public function get_imageWidth():Float {
		return _imageWidth;
	}
	
	private var _imageHeight:Float = 0;
	public var imageHeight(get, set):Float;	
	public function set_imageHeight(value:Float):Float {
		if (_imageHeight == value || value <= 0) {
			return value;
		}
		_imageHeight = value;
		updateSize();
		return value;
	}
	
	public function get_imageHeight() {
		return _imageHeight;
	}
	
	private var _imageInfo:ImageInfo;
	public var imageInfo(get, set):ImageInfo;
	private function get_imageInfo():ImageInfo {
		return _imageInfo;
	}
	private function set_imageInfo(value:ImageInfo):ImageInfo {
		if (element.src != value.data.src) {
			_imageInfo = value;
			_imageWidth = _imageInfo.width;
			_imageHeight = _imageInfo.height;
			element.src = value.data.src;
		}
		return value;
	}

	public function dispose() {
		if (element != null) {
            HtmlUtils.removeElement(element);
		}
	}
	
	//***********************************************************************************************************
	// Util functions
	//***********************************************************************************************************
	private function updatePos() {
		var style:CSSStyleDeclaration = element.style;
		style.left = HtmlUtils.px(_left);
		style.top = HtmlUtils.px(_top);
	}

	private function updateSize() {
		var style:CSSStyleDeclaration = element.style;
		style.width = HtmlUtils.px(imageWidth);
		style.height = HtmlUtils.px(imageHeight);
	}
}
