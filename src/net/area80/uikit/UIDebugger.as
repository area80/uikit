package net.area80.uikit
{

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getQualifiedClassName;

	final public class UIDebugger 
	{
		private static var tf:TextField;
		private static var debugBar:Sprite;
		private static var _isInit:Boolean = UIDebugger._init();
		private static var mouseDownY:Number = 0;
		private static var initY:Number = 0;
		private static var showing:Boolean = true;
		
		
		private static var textFormat:TextFormat;

		private static function _init():Boolean
		{
			Console.SignalTrace.add(log);
			return true;
		}

		public static function clear():void
		{
			if (tf) {
				tf.text = "";
			}
		}
		public static function showDebugger ():void {
			
			showing = true;
			if(debugBar) {
				debugBar.visible = true;
			}
		}
		public static function hideDebugger ():void {
			
			showing = false;
			if(debugBar) {
				debugBar.visible = false;
			}
		}

		protected static function createTextField():void
		{
			tf = new TextField();
			tf.embedFonts = false;
			textFormat = new TextFormat("Helvetica Neue", 14);
			
			tf.selectable = false;
			
			tf.multiline = true;
			tf.wordWrap = true;
			
			//tf.autoSize = TextFieldAutoSize.LEFT;
			
			var w:int = UIScreen.applicationFrame.width*UIScreen.scale;
			var h:int= UIScreen.applicationFrame.height*UIScreen.scale*.3;
			
			tf.width = w;
			tf.height = h;
			
			debugBar = new Sprite();
			debugBar.graphics.beginFill(0xFFFFFF,.6);
			debugBar.graphics.drawRect(0,0,w,h);
			debugBar.addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			
			
			
			debugBar.addChild(tf);
			
			debugBar.visible = showing;
			
			AppDelegate.flashStage.addChild(debugBar).name = "tf";
		}
		
		protected static function downHandler(event:MouseEvent):void
		{
			mouseDownY = AppDelegate.flashStage.mouseY;
			initY = debugBar.y;
			AppDelegate.flashStage.addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
			AppDelegate.flashStage.addEventListener(MouseEvent.MOUSE_UP, cancelDrag);
		}
		
		protected static function moveHandler(event:MouseEvent):void
		{
			debugBar.y= Math.max(0,Math.min(UIScreen.applicationFrame.height*UIScreen.scale-debugBar.height,initY+(AppDelegate.flashStage.mouseY - mouseDownY)));
			update();
		}
		protected static function update ():void {
			var ratio:Number = (debugBar.y)/((UIScreen.applicationFrame.height*UIScreen.scale)-debugBar.height);
			tf.scrollV = Math.round(tf.maxScrollV*ratio);
		}
		
		protected static function cancelDrag(event:MouseEvent):void
		{
			AppDelegate.flashStage.removeEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
			AppDelegate.flashStage.removeEventListener(MouseEvent.MOUSE_UP, cancelDrag);
		}
		
		public static function log(from:Object, msg:String):void
		{
			if (!tf) {
				createTextField();
			}
			
			var text:String = "[" + getQualifiedClassName(from).split("::")[1] + "] " + msg;
			tf.appendText(text+"\n");
			tf.setTextFormat(textFormat);
			
			
			
			if(!debugBar.visible) {
				trace(text);
			}
		}
	}
}
