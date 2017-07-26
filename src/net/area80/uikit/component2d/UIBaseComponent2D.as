package net.area80.uikit.component2d
{
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class UIBaseComponent2D extends Sprite
	{
		public var disposeOnRemoved:Boolean = true;
		private var _invalid:Boolean = false;
		private var priority:int = 0;
		
		/**
		 * 
		 * @param disposeOnRemoved
		 * @param priority This component will be update first, if high priority
		 * 
		 */
		public function UIBaseComponent2D(disposeOnRemoved:Boolean = true, priority:int = 0)
		{
			super();
			this.priority = priority;
			this.disposeOnRemoved = disposeOnRemoved;
			addEventListener(Event.ADDED_TO_STAGE, initStage, false, priority);
		}
		
		/**
		 * Tell framework to use updateIfInvalid() before judges its property after update is made. 
		 * @return
		 * 
		 */
		public function get needImmediateUpdate ():Boolean {
			return false;
		}
		
		public function invalid():void
		{
			_invalid = true;
			if (stage) {
				stage.invalidate();
			}
		}
		
		protected function initStage(event:Event):void
		{
			stage.addEventListener(Event.RENDER, update, false, priority);
			removeEventListener(Event.ADDED_TO_STAGE, initStage);
			addEventListener(Event.REMOVED_FROM_STAGE, removeFromStage);
			updateIfInvalid(); 
		}
		
		public function updateIfInvalid():void
		{
			if (_invalid) {
				_invalid = false;
				update();
			}
		}
		
		protected function update(event:Event = null):void
		{
			_invalid = false;
		}
		
		protected function removeFromStage(event:Event):void
		{
			stage.removeEventListener(Event.RENDER, update);
			removeEventListener(Event.REMOVED_FROM_STAGE, removeFromStage);
			addEventListener(Event.ADDED_TO_STAGE, initStage);
			if (disposeOnRemoved) {
				dispose();
			}
		}
		
		public function dispose():void
		{
			
		}
	}
}
