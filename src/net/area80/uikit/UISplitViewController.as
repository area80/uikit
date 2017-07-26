package net.area80.uikit
{

	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;


	public class UISplitViewController extends UIViewController
	{


		private var animating:Boolean = false;

		private var _rightViewController:UIViewController;
		private var _leftViewController:UIViewController;
		private var _mainViewController:UIViewController;


		private var _currentViewController:UIViewController;
		private var _animatePoint:Point = new Point(0, 0);
		private var _movedPoint:Point = new Point(0, 0);

		private var containerViewController:UIViewController;



		public function UISplitViewController()
		{
		}

		public function get numberOfSectionsInTableView():int
		{
			return 1;
		}

		public function numberOfRowsInSection(sectionid:int):int
		{
			return 1;
		}

		public function get presentsWithGesture():Boolean
		{
			return false;
		}

		override public function get splitViewController():UISplitViewController
		{
			// 
			return this;
		}

		override public function set splitViewController(value:UISplitViewController):void
		{
		}


		override protected function loadView():void
		{
			view = new UIView().initWithFrame(UIScreen.applicationFrame.copy());
			view.autoresizingMask = UIViewAutoresizing.FLEXIBLE_HEIGHT;
			view.autoresizingMask = UIViewAutoresizing.FLEXIBLE_WIDTH;
			containerViewController = new UIViewController();
			containerViewController.view = new UIView().initWithFrame(UIScreen.applicationFrame.copy());
			containerViewController.view.autoresizingMask = UIViewAutoresizing.FLEXIBLE_HEIGHT;
			containerViewController.view.autoresizingMask = UIViewAutoresizing.FLEXIBLE_WIDTH;
			super.addChildViewController(containerViewController);
		}

		private function tweenUpdates():void
		{

			var px:Number = _animatePoint.x - _movedPoint.x;
			var py:Number = _animatePoint.y - _movedPoint.y;
			_movedPoint.x += px;
			_movedPoint.y += py;
			//trace(">");
			//trace("tryupdating _animatePoint X:" + _animatePoint.x + " y:" + _animatePoint.y);
			//trace("which is already moved _movedPoint X:" + _movedPoint.x + " y:" + _movedPoint.y);
			//trace("since it moves by  X:" + px + " y:" + py);

			for (var i:int = 0; i < childViewControllers.length; i++) {
				var vc:UIViewController = childViewControllers[i];
				vc.view.x += px;
				vc.view.y += py;
			}
		}

		private function roundUp():void
		{
			_animatePoint.x = int(_animatePoint.x);
			_animatePoint.y = int(_animatePoint.y);
			_movedPoint.x = int(_movedPoint.x);
			_movedPoint.y = int(_movedPoint.y);
			for (var i:int = 0; i < childViewControllers.length; i++) {
				var vc:UIViewController = childViewControllers[i];
				vc.view.x = int(vc.view.x);
				vc.view.y = int(vc.view.y);
			}
		}

		private function realPoint(viewController:UIViewController = null):Point
		{
			if (!viewController) {
				return new Point(0, 0);
			} else {
				return new Point(viewController.view.x - _animatePoint.x, viewController.view.y - _animatePoint.y);
			}
		}

		private function controllerIsInFrame(viewController:UIViewController, toViewController:UIViewController = null):Boolean
		{

			var pointToCompare:Point = realPoint(toViewController);
			var rp:Point = realPoint(viewController);

			//need test
			var realx:Number = rp.x - pointToCompare.x;
			var realy:Number = rp.y - pointToCompare.y;

			if ((realx >= 0 && realx < view.frame.width) || (realx < 0 && realx + viewController.view.frame.width > 0)) {
				if ((realy >= 0 && realy < view.frame.height) || (realy < 0 && realy + viewController.view.frame.height > 0)) {
					return true;
				}
			}
			return false;
		}

		public function showViewControllerAnimated(viewController:UIViewController, animated:Boolean = true, callback:Function=null):void
		{
			manageTransition(viewController, animated, callback);
		}

		private function manageTransition(to:UIViewController, animated:Boolean, callback:Function):void
		{
			//TweenLite.killTweensOf(_animatePoint, true);
			//_movedPoint.x = 0;
			// _movedPoint.y = 0;


			for (var i:int = 0; i < childViewControllers.length; i++) {
				var vc:UIViewController = childViewControllers[i];
				if (controllerIsInFrame(vc)) {
					//do nothing if still inframe
					if (!controllerIsInFrame(vc, to)) {
						//view remove from frame
						//vc.viewWillDisappear_(animated);
					}
				} else if (controllerIsInFrame(vc, to)) {
					//will move to the new frame
					//vc.viewWillAppear_(animated);
				}
			}

			var animatedTo:Point = animateToPoint(to);

			if (animated) {
				animating = true;
				view.touchable = false;


				TweenLite.to(containerViewController.view, 0.8, {delay:0.2, x:animatedTo.x, y:animatedTo.y, ease:Strong.easeOut, onUpdate:function():void
				{
					//tweenUpdates();
				}, onComplete:function():void
				{
					//trace(">>");
					roundUp();
					containerViewController.view.x = int(containerViewController.view.x);
					containerViewController.view.y = int(containerViewController.view.y);
					//trace("end moving _animatePoint X:" + _animatePoint.x + " y:" + _animatePoint.y);
					animating = false;
					view.touchable = true;
					if(callback!=null && typeof(callback) =="function") {
						callback();
					}
				}});

			} else {

				containerViewController.view.x = animatedTo.x;
				containerViewController.view.y = animatedTo.y;
				if(callback!=null && typeof(callback) =="function") {
					callback();
				}
					//tweenUpdates();

			}

		}

		private function animateToPoint(toViewController:UIViewController):Point
		{
			var px:Number = -toViewController.view.x;
			var py:Number = -toViewController.view.y;


			var res:Point = new Point(px, py);

			//trace("__________________________________________________");
			//trace("will move from _animatePoint X:" + _animatePoint.x + " y:" + _animatePoint.y);
			//trace("to x:" + res.x + " y:" + res.y);

			var toframe:Rectangle = new Rectangle(px, py, view.frame.width, view.frame.height);
			var frame:Rectangle = totalFrameSize();

			var dx:Number = (frame.x + frame.width) - (toframe.x + toframe.width);
			var dy:Number = (frame.y + frame.height) - (toframe.y + toframe.height);

			//return res;
			//trace("frame w:" + frame.width + " h:" + frame.height + " x:" + frame.x + " y:" + frame.y);
			if (dx > 0) {
				if (res.x < 0) {
					res.x -= toViewController.view.frame.width - view.frame.width;
						//trace("> simplified to x:" + res.x);
				}

			}
			if (dy > 0) {
				if (res.y < 0) {
					res.y -= toViewController.view.frame.height - view.frame.height;
						//trace("> simplified to y:" + res.y);
				}

			}


			return res;
		}

		private function totalFrameSize():Rectangle
		{
			var rect:Rectangle = new Rectangle();
			for (var i:int = 0; i < childViewControllers.length; i++) {
				var v:UIView = childViewControllers[i].view;
				var bound:Rectangle = new Rectangle(v.x, v.y, v.frame.width, v.frame.height);
				rect = rect.union(bound);
			}
			return rect;
		}

		public function get isBetweenTransition():Boolean
		{
			return animating;
		}


		override public function addChildViewController(childController:UIViewController):void
		{
			containerViewController.addChildViewController(childController);
		}

		
	}
}
