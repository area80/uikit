package net.area80.uikit
{

	import flash.display.Sprite;
	
	import starling.core.RenderSupport;

	final public class UIWindow extends UIView
	{
		
		public var stage2d:flash.display.Sprite;
		
		private var _rootViewController:UIViewController;
		private var controller:UIWindowController;

		public function UIWindow(controller:UIWindowController)
		{
			super();
			this.controller = controller;
			setWindow(this);
			touchable = true;
			stage2d = new flash.display.Sprite();
			AppDelegate.flashStage.addChild(stage2d);
		}

		public function get rootViewController():UIViewController
		{
			return _rootViewController;
		}


		public function set rootViewController(value:UIViewController):void
		{
			if (_rootViewController) {  
				_rootViewController.removeFromParentViewController();
				_rootViewController.destroy();
			}
			_rootViewController = value;
			controller.addChildViewController(value);
			controller.calloutViewController.setRootView(_rootViewController.view);
			addChildAt(value.view, 0);
		}

		override public function render(support:RenderSupport, alpha:Number):void
		{
			UIView2D.count = 0;
			super.render(support, alpha);
		}

	}
}


