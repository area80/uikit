package net.area80.uikit
{
	

	public class UINavigationController extends UIViewController
	{

		protected var viewControllers:Vector.<UIViewController> = new Vector.<UIViewController>;

		private var animating:Vector.<UIViewController>;

		public function UINavigationController()
		{
			navigationController = this;
		}

		public function initWithRootViewController(viewController:UIViewController, animated:Boolean = false):UINavigationController
		{
			pushViewControllerAnimated(viewController, animated);
			return this;
		}
		
		public function swapRootViewControllerAnimated(rootViewController:UIViewController, animated:Boolean=true):void {
			if (isBetweenTransition)
				return;
			
			
			if(viewControllers.length==0){
				initWithRootViewController(rootViewController, animated);
				return;
			}
			
			var from:UIViewController = currentViewController;
			var to:UIViewController = rootViewController;
			
			if (from==to) {
				return;
			}
			viewControllers.unshift(to);
			
			if (to) {
				manageTransition(viewControllers.length-1, 0, animated, false);
			} else {
				throw new ArgumentError("There is no viewController.");
			}
		}

		override protected function loadView():void
		{
			view = new UIView().initWithFrame(UIScreen.applicationFrame.copy());
			view.autoresizingMask = UIViewAutoresizing.FLEXIBLE_HEIGHT | UIViewAutoresizing.FLEXIBLE_WIDTH;
		}

		protected function get rootViewController():UIViewController
		{
			return (viewControllers.length>0)?viewControllers[0]:null;
		}

		protected function get previousViewController():UIViewController
		{
			return (viewControllers.length>1)?viewControllers[viewControllers.length-2]:null;
		}

		public function get currentViewController():UIViewController
		{
			return (viewControllers.length>0)?viewControllers[viewControllers.length-1]:null;
		}
		
		public function changeViewController(childController:UIViewController):void {
			if(currentViewController) {
				currentViewController.viewWillDisappear(false);
				removeChildViewController(currentViewController);
				currentViewController.viewDidDisappear(false);
				
				viewControllers.pop();
				
				childController.viewWillAppear(false);
				addChildViewController(childController);
				viewControllers.push(childController);
				childController.viewDidAppear(false);
			}
		}

		protected function clearViewControllers(currentid:int):void
		{
			
			var i:uint = 0;

			var removes:Vector.<UIViewController> = new Vector.<UIViewController>;
			
			while (viewControllers.length-1>currentid) {
				removes.push(viewControllers.pop());
			}
			
			for (i = 0; i<removes.length; i++) {
				removes[i].removeFromParentViewController();
				removes[i].viewDidDisappear(true);
				removes[i].destroy();
			}

		}
		
		override public function destroy():void{
			if (viewControllers){
				for (var i:uint = 0; i<viewControllers.length; i++) {
					viewControllers[i].removeFromParentViewController();
					viewControllers[i].viewDidDisappear(false);
					viewControllers[i].destroy();
				}
				viewControllers = null;
			}
			super.destroy();
		}
		
		private function freezeStage ():void {
			AppDelegate.window.touchable = false;
			AppDelegate.flashStage.mouseChildren = false;
			
		}
		private function unFreezeStage ():void {
			AppDelegate.window.touchable = true;
			AppDelegate.flashStage.mouseChildren = true;
			
		}
		private function playTransitionOut(toid:int, isPush:Boolean, from:UIViewController, to:UIViewController, viewWillBeRemoved:Boolean, onCompleted:Function=null):void {
			if(!from) {
				if(onCompleted is Function) onCompleted();
				return;
			}
			from.viewWillDisappear(true);
			from.transitionOut(function():void
			{
				
				for(var i:int=0;i<animating.length;i++) {
					if(animating[i]==from) {
						animating.splice(i,1);
						break;
					}
				}
				
				if(!animating || animating.length==0) transitionEnd(toid, isPush, from, to);
				if(onCompleted is Function) onCompleted();
			},viewWillBeRemoved);
		}
		private function playTransitionIn(toid:int, isPush:Boolean, from:UIViewController, to:UIViewController, viewDidJustAdd:Boolean, onCompleted:Function=null):void {
			if(!to) {
				if(onCompleted is Function) onCompleted();
				return;
			}
			to.viewWillAppear(true);
			addChildViewController(to);
			to.transitionIn(function():void
			{
				
				for(var i:int=0;i<animating.length;i++) {
					if(animating[i]==to) {
						animating.splice(i,1);
						break;
					}
				}
				
				if(!animating || animating.length==0) transitionEnd(toid, isPush, from, to);
				if(onCompleted is Function) onCompleted();
			},viewDidJustAdd);
		}
		
		private function manageTransition(fromid:int, toid:int, animated:Boolean, isPush:Boolean):void
		{
			viewControllers.indexOf(fromid);
			var from:UIViewController = (fromid>-1) ? viewControllers[fromid] : null;
			var to:UIViewController = (toid>-1) ? viewControllers[toid] : null; 
			
			if (isBetweenTransition) {
				forceTransitionComplete(); 
			}
			
			if (animated) {
				
				freezeStage();
				
				animating = new Vector.<UIViewController>();
				if (from) animating.push(from); 
				if (to) animating.push(to);
				
				
				var viewWillBeRemoved:Boolean = (isPush) ? false : true;
				var viewDidJustAdd:Boolean = (isPush) ? true : false;
				
				
				if(to.transitionFlow==UITransitionFlow.CROSS) {
					
					playTransitionOut(toid, isPush, from, to, viewWillBeRemoved);
					playTransitionIn(toid, isPush, from, to, viewDidJustAdd);
					
				} else if (to.transitionFlow==UITransitionFlow.BEFORE){
					
					playTransitionIn(toid, isPush, from, to, viewDidJustAdd,function():void {
						playTransitionOut(toid, isPush, from, to, viewWillBeRemoved);
						
					});
					
				}  else if (to.transitionFlow==UITransitionFlow.AFTER){
					
					playTransitionOut(toid, isPush, from, to, viewWillBeRemoved, function():void {
						playTransitionIn(toid, isPush, from, to, viewDidJustAdd);
						
					});
				}
				

			} else {

				animating = null;
				to.viewWillAppear(animated);
				addChildViewController(to);
				if (from) {
					if (from) from.viewWillDisappear(animated);
					if (isPush) {
						removeChildViewController(from);
						from.viewDidDisappear(animated);
					} else {
						clearViewControllers(toid);
					}
				}
				to.viewDidAppear(animated);
			}

		}

		protected function transitionEnd(toid:int, isPush:Boolean, from:UIViewController, to:UIViewController):void
		{
		
			unFreezeStage();
			
			if (isPush) {
				if(from) {
					removeChildViewController(from);
					from.viewDidDisappear(true);
				}
			} else {
				clearViewControllers(toid);
			}
			to.viewDidAppear(true);
			
		}

		public function get isBetweenTransition():Boolean
		{
			return (animating && animating.length)?true:false;
		}

		public function forceTransitionComplete():void
		{
			if(animating) {
				for(var i:int=0;i<animating.length;i++) {
					animating[i].transitionForcedComplete();
				}
			}
		}

		public function pushViewControllerAnimated(viewController:UIViewController, animated:Boolean = true):void
		{
			if (isBetweenTransition)
				return;

			var from:UIViewController = currentViewController;
			var to:UIViewController = viewController;

			viewControllers.push(to);
			manageTransition(viewControllers.length-2, viewControllers.length-1, animated, true);
		}

		public function popViewControllerAnimated(animated:Boolean = true):void
		{
			if (isBetweenTransition)
				return;

			if (viewControllers.length<2) {
				return;
			}

			var to:UIViewController = viewControllers[viewControllers.length-2];

			if (to) {

				manageTransition(viewControllers.length-1, viewControllers.length-2, animated, false);

			} else {
				throw new ArgumentError("There is no viewController left to pop");
			}
		}

		public function popToRootViewControllerAnimated(animated:Boolean = true):void
		{
			if (isBetweenTransition)
				return;

			var from:UIViewController = currentViewController;
			var to:UIViewController = viewControllers[0];

			if (from==to) {
				return;
			}
			if (to) {
				manageTransition(viewControllers.length-1, 0, animated, false);
			} else {
				throw new ArgumentError("There is no viewController.");
			}
		}

		public function popToViewController(viewController:UIViewController, animated:Boolean = true):void
		{
			if (isBetweenTransition)
				return;

			var from:UIViewController = currentViewController;
			var to:UIViewController;
			var id:int;

			for (var i:uint = 0; i<viewControllers.length; i++) {
				if (viewControllers[i]==viewController) {
					to = viewController;
					id = i;
				}
			}
			if (from==to) {
				return;
			}
			if (to) {
				manageTransition(viewControllers.length-1, id, animated, false);
			} else {
				throw new ArgumentError("There is no viewController.");
			}
		}

		override public function get navigationController():UINavigationController
		{
			return this;
		}

		override public function set navigationController(value:UINavigationController):void
		{
		}

	}
}
