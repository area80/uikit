package net.area80.uikit.component
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import net.area80.uikit.component2d.UILabel2D;
	import net.area80.uikit.component2d.UILabelResizingMode;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Event;
	import starling.textures.SubTexture;
	import starling.textures.Texture;
	import starling.utils.getNextPowerOfTwo;

	public class UILabel extends UIBaseComponent
	{
		private var _registerationPoint:String = "left";
		private var img:Image;
		private var label:UILabel2D;

		public function UILabel(text:String = "", textFormat:TextFormat = null)
		{
			
			label = new UILabel2D(text,textFormat);			
			invalid();
			
			touchable = false;
			Starling.current.addEventListener(starling.events.Event.CONTEXT3D_CREATE, onContextCreated);
		}
		
		private function onContextCreated(e:starling.events.Event):void{
			updateTexture();
		}
		
		protected function updateTexture ():void {
			label.updateIfInvalid();

			var bmpd:BitmapData = new BitmapData( getNextPowerOfTwo(label.width) , getNextPowerOfTwo(label.height), true , 0 );
			bmpd.draw(label,null,null,null,null,true);
			var texture:Texture = new SubTexture( Texture.fromBitmapData(bmpd,false) , new Rectangle(0,0, Math.ceil(label.width), Math.ceil(label.height)), true );
			texture.root.onRestore = null; // dont' want starling restore because we will create new one
			bmpd.dispose();
			bmpd = null;
			if(!img) {
				img = new Image(texture);
				addChild(img);
			} else {
				img.texture.dispose();
				img.texture = texture;
				img.readjustSize();
			}
		}
		
		override public function dispose():void
		{
			Starling.current.removeEventListener(starling.events.Event.CONTEXT3D_CREATE, onContextCreated);
			
			if(img) {
				img.texture.dispose();
				img.dispose();
				img = null;
			}
			super.dispose();
		}
		
		
		protected function readjustPosition():void
		{
			
			//x
			switch (registerationPoint) {
				case TextFieldAutoSize.LEFT:
				case TextFieldAutoSize.NONE:
					img.x = 0;
					break;
				case TextFieldAutoSize.RIGHT:
					img.x = -img.width;
					break;
				case TextFieldAutoSize.CENTER:
					img.x = -img.width*.5;
					break;
			}
			
		}
		
		override protected function update():void
		{
			updateTexture();
			readjustPosition();
			super.update();
			
		}
		
		/*
		* Get / Set
		*/
		
		public function get resizeMode():String
		{
			
			return label.resizeMode;
			
		}
		
		public function set resizeMode(value:String):void
		{
			
			label.resizeMode = value;
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
			
			return label.baseLine;
			
		}
		
		public function set baseLine(value:String):void
		{
			
			label.baseLine = value;
			invalid();
			
		}
		
		public function get textField():TextField{
			return label.textField;
		}
		
		public function get autoShrinkMinimumFontSize():int
		{
			
			return label.autoShrinkMinimumFontSize;
			
		}
		
		public function set autoShrinkMinimumFontSize(value:int):void
		{
			label.autoShrinkMinimumFontSize = value;
			invalid();
			
		}
		
		public function get line():uint
		{
			
			return label.line;
			
		}
		
		public function set line(value:uint):void
		{
			
			label.line = value;
			invalid();
			
		}
		
		public function set fontFamily(value:String):void
		{
			
			label.fontFamily = value;
			invalid();
			
		}
		
		public function get fontFamily():String
		{
			
			return label.fontFamily;
			
		}
		public function set embedFonts(value:Boolean):void
		{
			
			label.textField.embedFonts = value;
			invalid();
			
		}
		
		public function get embedFonts():Boolean
		{
			
			return label.textField.embedFonts;
			
		}
		public function updateTextFormat(format:TextFormat):void
		{
			
			label.updateTextFormat(format);
			invalid();
			
		}
		
		public function set selectable(value:Boolean):void
		{
			
			label.textField.selectable = value;
			
		}
		
		public function get selectable():Boolean
		{
			
			return label.textField.selectable;
			
		}
		
		public function set fontSize(value:int):void
		{
			
			label.fontSize = value;
			invalid();
			
		}
		
		public function get leading():int
		{
			
			return label.leading;
			
		}
		
		public function set leading(value:int):void
		{
			
			label.leading = value;
			invalid();
			
		}
		
		public function get fontSize():int
		{
			
			return label.fontSize;
			
		}
		
		public function get truncateTail():Boolean
		{
			
			return label.truncateTail;
			
		}
		
		public function set truncateTail(value:Boolean):void
		{
			
			label.truncateTail = value;
			
		}
		
		public function set align(value:String):void
		{
			
			label.align = value;
			
		}
		
		public function get align():String
		{
			
			return label.align;
			
		}
		
		public override function set width(value:Number):void
		{
			
			label.width = value;
			invalid();
			
		}
		
		public override function set height(value:Number):void
		{
			
			label.height = value;
			invalid();
		}
		
		public override function get height():Number
		{
			if (label.resizeMode!=UILabelResizingMode.RESIZE_NONE) {
				label.updateIfInvalid();
				return label.height;
			} else {
				return label.height;
			}
		}
		
		public override function get width():Number
		{
			if (label.resizeMode==UILabelResizingMode.RESIZE_AUTO) {
				label.updateIfInvalid();
				return label.width;
			} else {
				return label.width;
			}
		}
		
		public function set text(message:String):void{
			if (label.text == message) return;
			label.text = message;
			invalid(); 
		}
		
		public function get text():String{
			return label.text;
		}	
	}
}
