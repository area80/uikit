package net.area80.uikit
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Quad;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.events.Touch;

	public class UISwipeScreenViewController extends UIViewController
	{
		private const NOT_CHANGE_PAGE_DURATION:Number = 0.3;
		private const CHANGE_PAGE_DURATION:Number = 0.2;
		private const VELOCITY_MIN:Number = 6*UIScreen.scale;

		private var frame:CGRect;

		//page
		private var _nowPage:int = 0;
		private var _screenX:Number = 0;

		//page move
		private var startMouseX:Number;
		private var startObjX:Number;
		private var lastMouseX:Number;
		private var touch:Touch;
		private var velocity:Number;
		private var nowPagesActive:Vector.<UIViewController>;




		public function UISwipeScreenViewController(frame:CGRect)
		{
			this.frame = frame;
		}

		/****************************************************************************
		************************* PAGE CONTROLLER ***********************************
		****************************************************************************/

		override protected function loadView():void
		{
			view = new UISwipeScreenView().initWithFrame(frame);
			view.touchResponder.addEventListener(UITouchEvent.TOUCH_BEGAN, startMove);
		}

		protected function startMove(event:UITouchEvent):void
		{
//			trace('startMove');
			TweenLite.killTweensOf(this);

			//snap
			touch = event.touch.getTouch(view);
			startMouseX = touch.globalX;
			startObjX = screenX;
			velocity = 0;
			lastMouseX = touch.globalX;

			if (childViewControllers.length>0) {
				view.touchResponder.addEventListener(UITouchEvent.TOUCH_END, endMove);
				enableInUse();
				view.addEventListener(starling.events.Event.ENTER_FRAME, snapMouse);
			}
		}

		protected function snapMouse(event:starling.events.Event):void
		{
//			trace('snapMouse', Math.round(-screenX), Math.round((_nowPage+0.5)*frame.width));
			screenX = startObjX+touch.globalX-startMouseX;
			if (screenX>0) {
				screenX = screenX*.5;
			} else if (screenX<-(childViewControllers.length-1)*view.frame.width) {
				screenX = (screenX-(childViewControllers.length-1)*view.frame.width)*.5;
			}
			velocity = touch.globalX-lastMouseX;
			lastMouseX = touch.globalX;
		}

		protected function endMove(event:flash.events.Event):void
		{
//			trace('endMove');

			if (velocity>VELOCITY_MIN) {
//				trace('++++++++++++++++++++++++++left++++++++++++++++++++++++++');
				slideLeft(true);
			} else if (velocity<-VELOCITY_MIN) {
//				trace('++++++++++++++++++++++++++right++++++++++++++++++++++++++');
				slideRight(true);
			} else {
				_nowPage = Math.round(-screenX/view.frame.width);
//				trace('++++++++++++++++++++++++++stable++++++++++++++++++++++++++');
				if (_nowPage<0) {
					_nowPage = 0;
				}
				if (_nowPage>childViewControllers.length-1) {
					_nowPage = childViewControllers.length-1;
				}
				tweenPage(NOT_CHANGE_PAGE_DURATION);
			}
//			trace('nowPage:', _nowPage);
			view.removeEventListener(starling.events.Event.ENTER_FRAME, snapMouse);
			view.touchResponder.removeEventListener(UITouchEvent.TOUCH_END, endMove);
		}

		private function tweenPage(duration:Number):void
		{
			UISwipeScreenView(view).currentPage = _nowPage;
			TweenLite.to(this, duration, {screenX: -_nowPage*view.frame.width, ease:Quad.easeIn, onComplete: disableNotUse});
		}

		private function enableInUse():void
		{
			nowPagesActive = new Vector.<UIViewController>();
			if (_nowPage-1>=0) {
				childViewControllers[_nowPage-1].view.visible = true;
				nowPagesActive.push(childViewControllers[_nowPage-1]);
			}
			if (childViewControllers.length>0) {
				nowPagesActive.push(childViewControllers[_nowPage]);
			}
			if (_nowPage+1<=childViewControllers.length-1) {
				childViewControllers[_nowPage+1].view.visible = true;
				nowPagesActive.push(childViewControllers[_nowPage+1]);
			}
		}

		private function disableNotUse():void
		{
			for (var i:uint = 0; i<=nowPagesActive.length-1; i++) {
				if (nowPagesActive[i]!=childViewControllers[_nowPage]) {
					nowPagesActive[i].view.visible = false;
				}
			}
		}

		// xy container
		public function get screenX():Number
		{
			return _screenX;
		}

		public function set screenX(value:Number):void
		{
			_screenX = value;

			if (_nowPage-1>=0) {
				childViewControllers[_nowPage-1].view.x = (_nowPage-1)*view.frame.width+screenX;
			}
			if (childViewControllers.length>=1) {
				childViewControllers[_nowPage].view.x = (_nowPage)*view.frame.width+screenX;
			}

			if (_nowPage+1<=childViewControllers.length-1) {
				childViewControllers[_nowPage+1].view.x = (_nowPage+1)*view.frame.width+screenX;
			}
		}

		public function getPagnitionIcon(forPage:int):Sprite
		{
			throw new Error("override me");
		}

		public function setPagnitionIconState(focus:Boolean):void
		{
			throw new Error("override me");
		}

		public function get pagnitionView():UIView
		{
			return UISwipeScreenView(view).pagnitionUIView;
		}

		public function get currentViewController():UIViewController
		{
			return childViewControllers[_nowPage];
		}

		public function get currentPage():int
		{
			return _nowPage;
		}

		public function get totalPage():int
		{
			return childViewControllers.length;
		}

		public function slideLeft(animated:Boolean):void
		{
			if (_nowPage>0) {
				_nowPage--;
				tweenPage(CHANGE_PAGE_DURATION);
			} else {
				_nowPage = 0;
				tweenPage(NOT_CHANGE_PAGE_DURATION);
			}
		}

		public function slideRight(animated:Boolean):void
		{
			if (_nowPage<childViewControllers.length-1) {
				_nowPage++;
				tweenPage(CHANGE_PAGE_DURATION);
			} else {
				_nowPage==childViewControllers.length-1;
				tweenPage(NOT_CHANGE_PAGE_DURATION);
			}
		}

		public function slideToFirstPage(animated:Boolean):void
		{
			_nowPage = 0;
			tweenPage(CHANGE_PAGE_DURATION);
		}

		public function slideToLastPage(animated:Boolean):void
		{
			_nowPage = childViewControllers.length-1;
			tweenPage(CHANGE_PAGE_DURATION);
		}

		public function slideToPage(animated:Boolean, page:UIViewController):void
		{
			for (var i:uint = 0; i<=childViewControllers.length-1; i++) {
				if (childViewControllers[i]==page) {
					_nowPage = i;
					tweenPage(CHANGE_PAGE_DURATION);
				}
			}
		}

		override public function addChildViewController(childViewController:UIViewController):void
		{
			super.addChildViewController(childViewController);
			if (childViewControllers.length-1!=_nowPage) {
				childViewController.view.visible = false;
			}
			childViewController.view.x = (childViewControllers.length-1)*view.frame.width;
			UISwipeScreenView(view).addPageIcon();
		}

		public function addChildViewControllerAt(index:int, childViewController:UIViewController):void
		{
			if (childViewController.parentViewController) {
				childViewController.parentViewController.removeFromParentViewController();
			}
			doAddChildController(childViewController, index);
			disableNotUse();
			enableInUse();
		}

		override public function removeChildViewController(childViewController:UIViewController):void
		{
			super.removeChildViewController(childViewController);
			UISwipeScreenView(view).removePageIcon();
			screenX = screenX;
			enableInUse();
		}

		public function removeChildViewControllerAt(index:int):void
		{
			super.removeChildViewController(childViewControllers[index]);
			if (childViewControllers.length-1<index) {
				_nowPage = childViewControllers.length-1;
			}
			UISwipeScreenView(view).removePageIcon();
			screenX = screenX;
			enableInUse();
		}

		public function removeAllPage():void
		{
			for (var i:uint = 0; i<=childViewControllers.length-1; i++) {
				super.removeChildViewController(childViewControllers[i]);
				UISwipeScreenView(view).removePageIcon();
			}
			_nowPage = 0;
			screenX = 0;
		}


		public function set bg(_bg:DisplayObject):void
		{
			UISwipeScreenView(view).bg = _bg;
		}

		public function get bg():DisplayObject
		{
			return UISwipeScreenView(view).bg;
		}
	}
}
