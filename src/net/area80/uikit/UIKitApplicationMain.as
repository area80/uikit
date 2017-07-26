package net.area80.uikit
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	import net.area80.utils.TimeController;

	public class UIKitApplicationMain extends Sprite
	{
		public static var isAndroid:Boolean = false;
		public static var isDebug:Boolean = false;
		public static var baseURL:String = "";
		
		protected var applicationDelegate:Class;

		public function UIKitApplicationMain(applicationDelegate:Class, preloader:UIAssetPreloader=null)
		{
			super();

			this.applicationDelegate = applicationDelegate;
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 60;
			TimeController.delayFucntion(1, startApplication);
			
			if(preloader) {
				stage.addChild(preloader);
				preloader.preloadInit();
			}
		}
		

		/**
		 * Most of the time it returns 1, but you may need to specify it for ratina display application with low-resolution display supports
		 * @return
		 *
		 */
		protected function get applicationScale():Number
		{
			var appScale:Number = 1;
			if (stage.stageWidth<640) {
				appScale = 0.5;
			}
			return appScale;
		}

		/**
		 * Override this to specify application width, default is iphone size fixwidth with ratina support
		 * @return
		 *
		 */
		protected function get applicationWidth():Number
		{
			return 640*applicationScale;
		}

		/**
		 * Override this to specify application height, default is iphone size auto height with ratina support
		 * @return
		 *
		 */
		protected function get applicationHeight():Number
		{
			return stage.stageHeight;
		}

		protected function startApplication(e:Event = null):void
		{
			AppDelegate.initCG(applicationDelegate, stage, applicationWidth, applicationHeight, applicationScale, false);

		}

	}
}
