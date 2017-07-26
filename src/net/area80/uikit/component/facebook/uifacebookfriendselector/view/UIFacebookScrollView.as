package net.area80.uikit.component.facebook.uifacebookfriendselector.view
{

	import com.greensock.TweenLite;
	import com.greensock.easing.Back; 
	
	import net.area80.uikit.CGRect;
	import net.area80.uikit.UIColor;
	import net.area80.uikit.UIScrollViewEquivalentSizeItem;
	import net.area80.uikit.UITouchEvent;
	import net.area80.uikit.UIView;
	import net.area80.uikit.UIViewHelper;
	
	import org.osflash.signals.Signal;
	
	import starling.display.DisplayObject;
	import starling.events.TouchEvent;

	public class UIFacebookScrollView extends UIScrollViewEquivalentSizeItem
	{
		public var signalDelete:Signal = new Signal(DisplayObject);
		private const DIFF_TO_DELETE:Number = 80;

		private var isHaveTouch:Boolean = false;
		private var nowItemSlide:DisplayObject;
		private var startMouseX:Number;
		private var startItemX:Number;

		private var canMoveX:Boolean = false;

		public function UIFacebookScrollView()
		{
			super(FacebookFriendItem.HEIGHT);
		}

		override public function initWithFrame(aRect:CGRect = null):UIView
		{
			background = new UIColor().initWithColor(0xFFFFFF, aRect.copy());
			return super.initWithFrame(aRect);
		}

		private function bindCommand(event:TouchEvent):void
		{
			if (isLockScrollAxis) {
				UIViewHelper.processTouch(bg, touchResponder, event);
			}
		}

		public function changeMode(_mode:Number):void
		{
			if (_mode==0) {
				isLockScrollAxis = false;
			} else if (_mode==1) {
				isLockScrollAxis = true;
				if (!isHaveTouch) {
					isHaveTouch = true;
					bg.addEventListener(TouchEvent.TOUCH, bindCommand);
					touchResponder.addEventListener(UITouchEvent.TOUCH_BEGAN, checkSlideMouseDown);
					touchResponder.addEventListener(UITouchEvent.TOUCH_MOVE, checkSlideMouseMove);
					touchResponder.addEventListener(UITouchEvent.TOUCH_END, checkSlideMouseUp);
				}
			}
		}

		protected override function activeMoveX():void
		{
			canMoveX = true;
		}

		protected override function deactiveMoveX():void
		{
			canMoveX = false;
		}

		/**
		 * TOUCH SLIDE
		 */

		protected function checkSlideMouseDown(event:UITouchEvent):void
		{
			var index:Number = (event.localY/itemHeight)>>0;
			if (index<0||index>childs.length-1) {
				nowItemSlide = null;
			} else {
				nowItemSlide = childs[index];
				startMouseX = event.globalX;
				startItemX = nowItemSlide.x;
			}
		}

		protected function checkSlideMouseMove(event:UITouchEvent):void
		{
			if (nowItemSlide&&canMoveX) {
				nowItemSlide.x = (event.globalX-startMouseX)+startItemX;
				nowItemSlide.alpha = (DIFF_TO_DELETE-Math.abs(nowItemSlide.x))/DIFF_TO_DELETE;
			}
		}

		protected function checkSlideMouseUp(event:UITouchEvent):void
		{
			if (nowItemSlide) {
				if (Math.abs(nowItemSlide.x)<DIFF_TO_DELETE) {
					TweenLite.to(nowItemSlide, .4, {x: 0, alpha: 1, ease: Back.easeOut});
				} else {
					nowItemSlide.alpha = 1;
					nowItemSlide.x = 0;
					signalDelete.dispatch(nowItemSlide);
				}
			}
			nowItemSlide = null;
		}
	}
}
