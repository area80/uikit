package net.area80.uikit.component2d
{
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;
	
	/**
	 * Label
	 * @author wissarut
	 *
	 */
	public class UILabel2D extends UIBaseComponent2D 
	{
		protected var _textField:TextField;
		
		private var _text:String;
		private var _width:Number = 0;
		private var _height:Number = 0;
		
		private var _registerationPoint:String = "left";
		private var _align:String = "left";
		private var _line:uint = 1;
		private var _truncateTail:Boolean = false;
		private var _autoShrinkMinimumFontSize:int = 1;
		private var _baseLine:String = UILabelResizingMode.BASELINE_TOP;
		private var _resizeMode:String = UILabelResizingMode.RESIZE_AUTO;
		private var _tfWidth:Number = 0;
		private var _tfHeight:Number = 0;
		private var _format:TextFormat = new TextFormat();
		private var padding:int;
		
		public function UILabel2D(text:String = "", textFormat:TextFormat = null)
		{
			
			super(true, 99);
			
			_textField = new TextField();
			updateTextFormat((textFormat)?textFormat:new TextFormat());
			_autoShrinkMinimumFontSize = int(_format.size);
			
			interactable = false;
			_text = text;
			
			addChild(_textField);
			
			invalid();
			
		}
		
		
		protected function identityTextField(fontSize:int):void
		{
			
			_textField.text = "";
			
			var fm:TextFormat = new TextFormat(_format.font,_format.size,_format.color,_format.bold,_format.italic,_format.underline,_format.url,_format.target,_format.align,_format.leftMargin,_format.rightMargin,_format.indent,_format.leading);
			fm.size = fontSize;
		
			_textField.setTextFormat(fm);
			
			_textField.defaultTextFormat = fm;
			
			switch (_resizeMode) {
				case UILabelResizingMode.RESIZE_AUTO:
					_textField.width = 1;
					_textField.height = 1;
					_textField.multiline = true;
					_textField.wordWrap = false;
					_textField.autoSize = TextFieldAutoSize.LEFT;
					break;
				case UILabelResizingMode.RESIZE_AUTO_FIXWIDTH:
					_textField.width = _width;
					_textField.height = 1;
					_textField.multiline = true;
					_textField.wordWrap = true;
					_textField.autoSize = TextFieldAutoSize.NONE;
					break;
				case UILabelResizingMode.RESIZE_NONE:
					_textField.width = _width;
					_textField.height = _height;
					_textField.multiline = true;
					_textField.wordWrap = true;
					_textField.autoSize = TextFieldAutoSize.NONE;
					break;
			}
			
		}
		
		protected function updateFlow():void
		{
			
			var htmlText:String = "";
			
			switch (_resizeMode) {
				case UILabelResizingMode.RESIZE_AUTO:
					htmlText = shrinkTextAutoSize();
					break;
				case UILabelResizingMode.RESIZE_AUTO_FIXWIDTH:
					htmlText = shrinkTextAutoSize();
					break;
				case UILabelResizingMode.RESIZE_NONE:
					htmlText = shrinkTextFixSize();
					break;
			} 
			
			addLineAndSetSize(htmlText);
			readjustPosition();
			
		}
		
		protected function addLineAndSetSize(htmlText:String):void
		{
			
			var lines:Number = _textField.numLines;
			var h:int = _textField.textHeight;
			var lm:TextLineMetrics = _textField.getLineMetrics(0);
			
			//heep these line for debug
			/*
			if(text.indexOf("AutoResize line=1")>-1) {
			trace("??-----------------");
			trace("text="+text);
			trace("height="+_textField.height);
			trace("line="+textField.numLines);
			trace("textHeight="+_textField.textHeight);
			trace("textWidth="+_textField.textWidth);
			trace("??-----------------");
			}*/
			
			_textField.multiline = true;
			_textField.htmlText = " <br/>"+htmlText+"<br/> ";
			
			padding = lm.height-lm.descent;
			
			_textField.width = (_resizeMode!=UILabelResizingMode.RESIZE_AUTO)?_width:textField.textWidth+4;
			_textField.height = _textField.textHeight+4;
			
			_tfWidth = _textField.width;
			_tfHeight = (lines*lm.height)+(lm.descent*2)+4;
			
			_textField.y = -padding;
			
		}
		
		protected function shrinkTextFixSize():String
		{
			var currentFontSize:int = fontSize;
			var trunPos:int = 0;
			var textLength:int = _text.length;
			var htmlText:String = updateText(text, currentFontSize);
			
			while (currentFontSize>autoShrinkMinimumFontSize&&(textField.numLines>_line||textField.height>_height)) {
				currentFontSize--;
				htmlText = updateText(text, currentFontSize);
			}
			while ((_textField.numLines>_line||textField.height>_height)&&trunPos>-textLength) {
				trunPos--;
				htmlText = updateText(text, currentFontSize, trunPos);
			}
			
			return htmlText;
			
		}
		
		protected function shrinkTextAutoSize():String{
			var currentFontSize:int = fontSize;
			var trunPos:int = 0;
			var textLength:int = _text.length;
			var htmlText:String = updateText(text, currentFontSize);
			
			while (currentFontSize>autoShrinkMinimumFontSize&&textField.numLines>_line) {
				currentFontSize--;
				htmlText = updateText(text, currentFontSize);
			}
			while (_textField.numLines>_line&&trunPos>-textLength) {
				trunPos--;
				htmlText = updateText(text, currentFontSize, trunPos);
			}
			
			return htmlText;
			
		}
		
		protected function updateText(text:String, fontSize:int, pos:int = 0):String
		{
			
			identityTextField(fontSize);
			
			var txt:String = "";
			var subText:String = text.substr(0, text.length+pos);
			var trunString:String = (_truncateTail&&pos<0)?"...":"";
			
			txt = subText+trunString;
			_textField.htmlText = txt;
			
			//here is the trick! Fix Bug TextField
			if (_resizeMode==UILabelResizingMode.RESIZE_AUTO_FIXWIDTH) {
				_textField.autoSize = TextFieldAutoSize.LEFT;
				_textField.width = _textField.width;
			} else if (_resizeMode==UILabelResizingMode.RESIZE_AUTO) {
				_textField.width = _textField.width;
			}
			
			return txt;
			
		}
		
		protected function readjustPosition():void
		{
			
			//y
			if (_resizeMode==UILabelResizingMode.RESIZE_NONE) {
				if (_baseLine==UILabelResizingMode.BASELINE_MIDDLE) {
					_textField.y = ((_height-_tfHeight)*.5)-padding;
				} else if (_baseLine==UILabelResizingMode.BASELINE_BOTTOM) {
					_textField.y = _height-(_tfHeight+padding);
				} else {
					_textField.y = -padding;
				}
			} else {
				_textField.y = -padding;
			}
			
			//x
			switch (registerationPoint) {
				case TextFieldAutoSize.LEFT:
				case TextFieldAutoSize.NONE:
					_textField.x = 0;
					break;
				case TextFieldAutoSize.RIGHT:
					_textField.x = -_tfWidth;
					break;
				case TextFieldAutoSize.CENTER:
					_textField.x = -_tfWidth*.5;
					break;
			}
			
		}
		
		override protected function update(event:Event = null):void
		{
			
			updateFlow();
			super.update(event);
			
		}
		
		/*
		* Get / Set
		*/
		
		public function get resizeMode():String
		{
			
			return _resizeMode;
			
		}
		
		public function set resizeMode(value:String):void
		{
			
			_resizeMode = value;
			invalid();
			
		}
		
		public function get registerationPoint():String
		{
			
			return _registerationPoint;
			
		}
		
		public function set registerationPoint(value:String):void
		{
			
			_registerationPoint = value;
			invalid();
			
		}
		
		public function get baseLine():String
		{
			
			return _baseLine;
			
		}
		
		public function set baseLine(value:String):void
		{
			
			_baseLine = value;
			invalid();
			
		}
		
		public function get textField():TextField{
			return _textField;
		}
		
		
		public function set interactable(value:Boolean):void
		{
			
			_textField.mouseEnabled = mouseChildren = mouseEnabled = value;
			
		}
		
		public function get interactable():Boolean
		{
			
			return mouseChildren;
			
		}
		
		public function get autoShrinkMinimumFontSize():int
		{
			
			return _autoShrinkMinimumFontSize;
			
		}
		
		public function set autoShrinkMinimumFontSize(value:int):void
		{
			
			if (_autoShrinkMinimumFontSize>int(_format.size)) {
				_autoShrinkMinimumFontSize = int(_format.size);
			} else {
				_autoShrinkMinimumFontSize = value;
			}
			invalid();
			
		}
		
		public function get line():uint
		{
			
			return _line;
			
		}
		
		public function set line(value:uint):void
		{
			
			_line = value;
			invalid();
			
		}
		
		public function set fontFamily(value:String):void
		{
			
			_format.font = value;
			invalid();
			
		}
		
		public function get fontFamily():String
		{
			
			return _format.font;
			
		}
		public function set embedFonts(value:Boolean):void
		{
			
			_textField.embedFonts = value;
			invalid();
			
		}
		
		public function get embedFonts():Boolean
		{
			
			return _textField.embedFonts;
			
		}
		public function updateTextFormat(format:TextFormat):void
		{
			
			_format = format;
			
			invalid();
			
		}
		
		public function set selectable(value:Boolean):void
		{
			
			_textField.selectable = value;
			
		}
		
		public function get selectable():Boolean
		{
			
			return _textField.selectable;
			
		}
		
		public function set fontSize(value:int):void
		{
			
			_format.size = value;
			autoShrinkMinimumFontSize = _autoShrinkMinimumFontSize;
			invalid();
			
		}
		
		public function get leading():int
		{
			
			return int(_format.leading);
			
		}
		
		public function set leading(value:int):void
		{
			
			_format.leading = value;
			invalid();
			
		}
		
		public function get fontSize():int
		{
			
			return int(_format.size);
			
		}
		
		public function get truncateTail():Boolean
		{
			
			return _truncateTail;
			
		}
		
		public function set truncateTail(value:Boolean):void
		{
			
			_truncateTail = value;
			
		}
		
		public function set align(value:String):void
		{
			
			_align = value;
			
		}
		
		public function get align():String
		{
			
			return _align;
			
		}
		
		public override function set width(value:Number):void
		{
			
			_width = value;
			invalid();
			
		}
		
		public override function set height(value:Number):void
		{
			
			_height = value;
			invalid();
			
		}
		
		public override function get height():Number
		{
			
			if (_resizeMode!=UILabelResizingMode.RESIZE_NONE) {
				updateIfInvalid();
				return _tfHeight;
			} else {
				return _height;
			}
			
		}
		
		public override function get width():Number
		{
			
			if (_resizeMode==UILabelResizingMode.RESIZE_AUTO) {
				updateIfInvalid();
				return _tfWidth;
			} else {
				return _width;
			}
			
		}
		
		public function set text(message:String):void
		{
			
			_text = message;
			invalid();
			
		}
		
		public function get text():String
		{
			
			return _text;
			
		}
		
	}
}
