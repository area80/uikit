package net.area80.uikit
{

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	[Event(name = "touchbegan", type = "net.area80.uikit.UITouchEvent")]
	[Event(name = "touchend", type = "net.area80.uikit.UITouchEvent")]
	[Event(name = "touchhover", type = "net.area80.uikit.UITouchEvent")]
	[Event(name = "touchmove", type = "net.area80.uikit.UITouchEvent")]
	[Event(name = "touchmoveinside", type = "net.area80.uikit.UITouchEvent")]
	[Event(name = "touchmoveoutside", type = "net.area80.uikit.UITouchEvent")]
	[Event(name = "touchout", type = "net.area80.uikit.UITouchEvent")]
	[Event(name = "touchbackin", type = "net.area80.uikit.UITouchEvent")]
	[Event(name = "touchendoutside", type = "net.area80.uikit.UITouchEvent")]
	[Event(name = "touchendinside", type = "net.area80.uikit.UITouchEvent")]
	[Event(name = "touchtab", type = "net.area80.uikit.UITouchEvent")]
	[Event(name = "touchtabcancel", type = "net.area80.uikit.UITouchEvent")]
	[Event(name = "touchcancel", type = "net.area80.uikit.UITouchEvent")]
	[Event(name = "touchready", type = "net.area80.uikit.UITouchEvent")]

	public class UITouchResponder extends EventDispatcher
	{
		/**
		 * Indecates pixels distance before touch tab cancel
		 */
		public var pixelDistanceBeforeCancelTouchTabCancel:int = 8;
		
		/**
		 * Boolean indicate state of touchs
		 */
		public var touchesBegin:Boolean = false;
		/**
		 * Boolean indicate state of touchs
		 */
		public var touchesOut:Boolean = false;
		public var tabCancel:Boolean = false;
		public var touchStart:Point = new Point(0,0);
		
		private var _listenersByType:Dictionary = new Dictionary();
		
		private var count:int = 0;
		
		
		
		/**
		 * 
		 * @param pixelDistanceBeforeCancelTouchTabCancel Indecates pixels distance before touch tab cancel (default 8)
		 * 
		 */
		public function UITouchResponder(pixelDistanceBeforeCancelTouchTabCancel:int = 8)
		{
			this.pixelDistanceBeforeCancelTouchTabCancel = pixelDistanceBeforeCancelTouchTabCancel;	
		}
		
		public function get hasListener ():Boolean {
			return (count>0);
		}
		
		override public function dispatchEvent(evt:Event):Boolean {
			if (hasEventListener(evt.type) || evt.bubbles) {
				return super.dispatchEvent(evt);
			}
			return true;
		}
		
		public function removeAllListeners ():void {
			if(hasListener) {
				for (var type:* in _listenersByType) {
					var listeners:Dictionary = _listenersByType[type];
					for(var fncKey:* in listeners) {
						removeEventListener(type,fncKey);
					}
					delete _listenersByType[type];
				}
			}
		}
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			if(!_listenersByType[type]) {
				count ++;
				_listenersByType[type] = new Dictionary();
			}
			_listenersByType[type][listener] = type;
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			if(_listenersByType[type] && _listenersByType[type][listener]){
				count --;
				delete _listenersByType[type][listener];
			}
			super.removeEventListener(type, listener, useCapture);
		}
		


	}
}
