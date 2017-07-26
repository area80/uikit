package net.area80.uikit.util
{

	
	import net.area80.uikit.UITouchEvent;
	import net.area80.uikit.UITouchResponder;
	import net.area80.uikit.UIViewHelper;
	
	import starling.display.DisplayObject;
	import starling.events.TouchEvent;
	
	public class TouchComposer
	{
		public static var multitouch:Boolean = false;
		
		protected var _touchObject:DisplayObject;
		protected var _touchResponder:UITouchResponder = new UITouchResponder();

		protected var mouseDownCallBack:Function;
		protected var mouseUpCallBack:Function;
		protected var mouseMoveCallBack:Function ;
		protected var clickCallBack:Function;
		
		protected var _touchStartFunction:Function;
		protected var _touchCancelFunction:Function;
		
		/**
		 * Create touch composer to use as function style for button objects
		 * @param touchObject
		 * @param mouseDownFunction
		 * @param mouseUpFunction
		 * @param clickFunction
		 * 
		 */
		public function TouchComposer(touchObject:DisplayObject,
									  mouseDownFunction:Function = null,
									  mouseUpFunction:Function = null,
									  clickFunction:Function = null,
									  autoStart:Boolean = true)
		{
			
			_touchObject = touchObject;
			touchObject.touchable = true;
			
			mouseDownCallBack = mouseDownFunction;
			mouseUpCallBack = mouseUpFunction;
			clickCallBack = clickFunction;
			
			touchResponder.addEventListener(UITouchEvent.TOUCH_BEGAN, touchBeganHandler);
			touchResponder.addEventListener(UITouchEvent.TOUCH_END, touchEndHandler);
			touchResponder.addEventListener(UITouchEvent.TOUCH_TAB, touchTabHandler);
			touchResponder.addEventListener(UITouchEvent.TOUCH_TAB_CANCEL, touchTabCancelHandler);
			touchResponder.addEventListener(UITouchEvent.TOUCH_MOVE,touchMoveHandler);
			
			if(autoStart) start();
		}
		
		/**
		 * Create alpha effect behavior 
		 * @return 
		 * 
		 */
		public function initAsAlphaButton ():TouchComposer {
			return initAsButtonWithBehavior (alphaButtonBehaviorStart,alphaButtonBehaviorStop );
		}
		
		private function alphaButtonBehaviorStart(obj:DisplayObject) :void {
			obj.alpha = .5;
		}
		private function alphaButtonBehaviorStop(obj:DisplayObject) :void {
			obj.alpha = 1;
		}
		
		/**
		 * Create your own effect with mouse down, mouse up function 
		 * @param startTouchEffect 1 argument receiver with type DisplayObject
		 * @param cancelTouchEffect 1 argument receiver with type DisplayObject
		 * @return 
		 * 
		 */
		public function initAsButtonWithBehavior (startTouchEffect:Function, cancelTouchEffect:Function):TouchComposer {
			_touchStartFunction = startTouchEffect;
			_touchCancelFunction = cancelTouchEffect;
			return this;
		}
		
		protected function touchTabHandler(event:UITouchEvent):void
		{
			callBackProcess(clickCallBack, event);
		}
		protected function touchEndHandler(event:UITouchEvent):void
		{
			if(!touchResponder.tabCancel && _touchCancelFunction is Function) _touchCancelFunction(_touchObject);
			callBackProcess(mouseUpCallBack, event);
		}
		protected function touchTabCancelHandler(event:UITouchEvent):void
		{
			if(_touchCancelFunction is Function) _touchCancelFunction(_touchObject);
			
		}
		protected function touchBeganHandler(event:UITouchEvent):void
		{
			if( !multitouch){
				if(_touchStartFunction is Function) _touchStartFunction(_touchObject);
				callBackProcess(mouseDownCallBack, event);
			}
		}
		protected function touchMoveHandler(event:UITouchEvent):void
		{
			callBackProcess(mouseMoveCallBack, event);
		}
		
		public function dispose ():void {
			stop();
			_touchObject = null;
			_touchResponder.removeAllListeners();
			_touchResponder = null;
			
			mouseDownCallBack = null;
			mouseUpCallBack = null;
			mouseMoveCallBack = null;
			clickCallBack = null;
			
			_touchStartFunction = null;
			_touchCancelFunction = null;
		}
		
		
		protected function callBackProcess (callback:Function, event:UITouchEvent):void {
			if(callback is Function) {
				if(callback.length==1) {
					callback(event);
				} else {
					callback();
				}
			}
		}
		
		public function touchHandler(e:TouchEvent):void
		{
			UIViewHelper.processTouch(touchObject, touchResponder, e); 
		}
		
		public function click (callback:Function):void {
			clickCallBack = callback;
		}
		public function mouseMove(callback:Function):void
		{
			mouseMoveCallBack = callback;
		}
		public function mouseUp(callback:Function):void
		{
			mouseUpCallBack = callback;
		}
		public function mouseDown(callback:Function):void
		{
			mouseDownCallBack = callback;
		}
		public function removeMouseUp():void
		{
			mouseUpCallBack = null;
		}
		public function removeMouseDown():void
		{
			mouseDownCallBack = null;
		}
		public function removeMouseMove():void
		{
			mouseMoveCallBack = null;
		}
		public function get touchResponder():UITouchResponder
		{
			return _touchResponder;
		}
		
		public function get touchObject():DisplayObject
		{
			return _touchObject;
		}
		
		public function start():void
		{
			if (touchObject) touchObject.addEventListener(TouchEvent.TOUCH, touchHandler);
		}
		
		public function stop():void
		{
			if (touchObject) touchObject.removeEventListener(TouchEvent.TOUCH, touchHandler);
		}
		
	}
}
