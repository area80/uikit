package net.area80.uikit
{

	import flash.events.Event;
	
	import starling.events.TouchEvent;

	public class UITouchEvent extends Event
	{

		public static const TOUCH_BEGAN:String = "touchbegan";
		public static const TOUCH_END:String = "touchend";
		public static const TOUCH_HOVER:String = "touchhover";
		public static const TOUCH_MOVE:String = "touchmove";
		public static const TOUCH_MOVE_INSIDE:String = "touchmoveinside";
		public static const TOUCH_MOVE_OUTSIDE:String = "touchmoveoutside";
		public static const TOUCH_OUT:String = "touchout";
		public static const TOUCH_BACKIN:String = "touchbackin";
		public static const TOUCH_END_OUTSIDE:String = "touchendoutside";
		public static const TOUCH_END_INSIDE:String = "touchendinside";
		public static const TOUCH_TAB:String = "touchtab";
		public static const TOUCH_TAB_CANCEL:String = "touchtabcancel";


		public static const CANCEL:String = "touchcancel";
		public static const READY:String = "touchready";

		public var touch:TouchEvent;
		
		public var localX:Number = 0;
		public var localY:Number = 0;
		
		public var globalX:Number =0;
		public var globalY:Number =0;

		public function UITouchEvent(type:String, touch:TouchEvent = null, localX:Number=0,localY:Number=0, globalX:Number=0,globalY:Number=0)
		{
			this.touch = touch;
			this.localX = localX;
			this.localY = localY;
			this.globalX = globalX;
			this.globalY = globalY;
			super(type);
		}
	}
}
