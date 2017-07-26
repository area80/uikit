package net.area80.uikit
{

	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;
	
	import flash.utils.Dictionary;


	public class UICalloutViewController extends UIViewController
	{
		protected var dimLayerByController:Dictionary = new Dictionary(true);
		protected var hideRootByController:Dictionary = new Dictionary(true);
		protected var rootView:UIView;

		public function UICalloutViewController(rootView:UIView=null)
		{
			this.rootView = rootView;
			super();
		}
		public function setRootView(rootView:UIView):void{
			this.rootView = rootView;
		}

		/**
		 * 
		 * @param viewController
		 * @param hideRootView Hide parental view which callout is placed after animation
		 * @param dimmingOpacity
		 * @param dimmColor
		 * 
		 */
		public function slideUp(viewController:UIViewController, hideRootView:Boolean = false, dimmingOpacity:Number = .5, dimmColor:int = 0x000000):void
		{
			//duplicate
			if (dimLayerByController[viewController]) {
				return;
			}
			view.window.touchable = false;

			var tmpview:UIView = new UIView().initWithFrame(UIScreen.applicationFrame.copy());
			tmpview.autoresizingMask = UIViewAutoresizing.FLEXIBLE_HEIGHT | UIViewAutoresizing.FLEXIBLE_WIDTH ;
			tmpview.background = new UIColor().initWithColor(dimmColor, UIScreen.applicationFrame.copy());
			tmpview.background.alpha = 0;
			view.addChild(tmpview);

			if (hideRootView)
				hideRootByController[viewController] = "hide";

			dimLayerByController[viewController] = tmpview;

			viewController.viewWillAppear(true);
			addChildViewController(viewController);
			

			viewController.view.y = view.frame.height;

			TweenLite.to(tmpview.background, 0.5, {delay: 0.2, alpha: dimmingOpacity, ease: Strong.easeOut});
			
			TweenLite.to(viewController.view, 0.5, {y: view.frame.height-viewController.view.frame.height, ease: Strong.easeOut, delay: 0.2, onComplete: function():void
			{
				if (hideRootView && rootView) {
					rootView.visible = false;
				}
				view.window.touchable = true;
				viewController.viewDidAppear(true); 
 
			}});
		}

		protected function checkRootviewVisible(currentViewController:UIViewController):Boolean
		{
			var child:UIViewController;
			for (var i:int = childViewControllers.length-1; i>=0; i--) {
				child = childViewControllers[i];
				if (currentViewController!=child&&dimLayerByController[child]) {
					//if underlaying layer need hiding, return false
					return (hideRootByController[child])?false:true;
				}
			}
			return true;
		}

		public function slideOff(viewController:UIViewController,onComplete:Function=null):void
		{
			//not found
			if (!dimLayerByController[viewController]) {
				return;
			}
			view.window.touchable = false;

			var tmpview:UIView = dimLayerByController[viewController] as UIView;

			//check underlaying layer
			if(rootView) rootView.visible = checkRootviewVisible(viewController);

			TweenLite.killTweensOf(tmpview);
			TweenLite.killTweensOf(viewController.view);
			viewController.viewWillDisappear(true);
			TweenLite.to(tmpview.background, 0.4, {delay: 0.2, alpha: 0, ease: Strong.easeInOut});
			TweenLite.to(viewController.view, 0.4, {y: view.frame.height, ease: Strong.easeInOut, delay: 0.2, onComplete: function():void
			{
				TweenLite.killTweensOf(viewController.view);
				delete dimLayerByController[viewController];
				if (hideRootByController[viewController])
					delete hideRootByController[viewController];
				view.removeChild(tmpview);
				view.window.touchable = true;
				removeChildViewController(viewController);
				viewController.viewDidDisappear(true);
				viewController.destroy();
				if( onComplete!=null ){
					onComplete();
				}
			}});
		}
		
		public function slideOffAll():void{
			if (dimLayerByController==null) return;
			var child:UIViewController;
			for (var i:int = childViewControllers.length-1; i>=0; i--) {
				child = childViewControllers[i];
				if (child&&dimLayerByController[child]) {
					slideOff(child);
				}
			}
		}

		override public function get calloutViewController():UICalloutViewController
		{
			return this;
		}

		override public function set calloutViewController(value:UICalloutViewController):void
		{

		}

		override protected function loadView():void
		{
			view = new UIView().initWithFrame(UIScreen.applicationFrame.copy()); 
			view.autoresizingMask = UIViewAutoresizing.FLEXIBLE_HEIGHT|UIViewAutoresizing.FLEXIBLE_WIDTH;

		}

	}
}
