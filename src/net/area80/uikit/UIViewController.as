package net.area80.uikit
{

	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;
	
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	

	/**
	 * <p>The UIViewController class provides the fundamental view-management model for all iOS apps. You rarely instantiate UIViewController objects directly. Instead, you instantiate subclasses of the UIViewController class based on the specific task each subclass performs. A view controller manages a set of views that make up a portion of your app’s user interface. As part of the controller layer of your app, a view controller coordinates its efforts with model objects and other controller objects—including other view controllers—so your app presents a single coherent user interface.</p>
	 *
	 * <p>Where necessary, a view controller:</p>
	 *
	 * <ul>
	 * 		<li>resizes and lays out its views</li>
	 * 		<li>adjusts the contents of the views</li>
	 * 		<li>acts on behalf of the views when the user interacts with them</li>
	 * </ul>
	 *
	 * @see http://developer.apple.com/library/ios/#documentation/UIKit/Reference/UIViewController_Class/Reference/Reference.html#//apple_ref/occ/instp/UIViewController/splitViewController
	 *
	 */
	public class UIViewController extends EventDispatcher
	{
		public var navigationItem:UINavigationItem;
		public var parentViewController:UIViewController;


		public var childViewControllers:Vector.<UIViewController> = new Vector.<UIViewController>;

		private var _splitViewController:UISplitViewController;
		private var _navigationController:UINavigationController;
		private var _calloutController:UICalloutViewController;
		private var _isViewLoaded:Boolean = false;
		private var _view:UIView;
		private var _isDestroy:Boolean = false;

		protected var viewLoadTime:Number;

		public function UIViewController()
		{

		}

		public function get calloutViewController():UICalloutViewController
		{
			return (_calloutController) ? _calloutController: ((parentViewController) ? parentViewController.calloutViewController : null);
		}

		public function set calloutViewController(value:UICalloutViewController):void
		{
			_calloutController = value;
		}

		public function get splitViewController():UISplitViewController
		{
			return (_splitViewController) ? _splitViewController: ((parentViewController) ? parentViewController.splitViewController : null);
		}

		public function set splitViewController(value:UISplitViewController):void
		{
			_splitViewController = value;
		}

		public function get navigationController():UINavigationController
		{
			return (_navigationController) ? _navigationController: ((parentViewController) ? parentViewController.navigationController : null);
		}

		public function set navigationController(value:UINavigationController):void
		{
			_navigationController = value;
		}

		/**
		 * <p>Returns a Boolean value indicating whether the view is currently loaded into memory.</p>
		 *
		 * <p><b>Discussion</b></p>
		 *
		 * <p>Calling this method reports whether the view is loaded. Unlike the view property, it does not attempt to load the view if it is not already in memory.</p>
		 *
		 * @return Boolean
		 *
		 */
		public function get isViewLoaded():Boolean
		{
			return _isViewLoaded;
		}

		/**
		 * <p>Adds the given view controller as a child.</p>
		 *
		 * <p><b>Discussion</b></p>
		 *
		 * <p>If the new child view controller is already the child of a container view controller, it is removed from that container before being added.</p>
		 *
		 * <p>This method is only intended to be called by an implementation of a custom container view controller. If you override this method, you must call super in your implementation.</p>
		 *
		 * @param childController The view controller to be added as a child.
		 *
		 */
		public function addChildViewController(childController:UIViewController):void
		{
			if (childController.parentViewController) {
				childController.parentViewController.removeFromParentViewController();
			}

			doAddChildController(childController);
		}


		/**
		 * Remove self from parent
		 * 
		 */
		public function removeFromParentViewController():void
		{
			if (parentViewController) {
				parentViewController.removeChildViewController(this);
			}
		}

		public function removeChildViewController(childController:UIViewController):void
		{
			if (childController.parentViewController==this) {
				doRemoveChildController(childController);
			} else {
				//throw new ArgumentError("childController must be child of this controller");
			}
		}

		/**
		 * Attempts to rotate all windows to the orientation of the device.
		 *
		 * <p><b>Discussion</b></p>
		 *
		 * Some view controllers may want to use app-specific conditions to determine the return value of their implementation of the shouldAutorotateToInterfaceOrientation: method. If your view controller does this, when those conditions change, your app should call this class method. The system immediately attempts to rotate to the new orientation. A rotation occurs so long as each relevant view controller returns YES in its implementation of the shouldAutorotateToInterfaceOrientation: method.
		 *
		 */
		protected function attemptRotationToDeviceOrientation():void
		{
			AppDelegate.attemptRotationToDeviceOrientation(this);
		}


		/**
		 * The view that the controller manages.
		 *
		 * <p><b>Discussion</b></p>
		 *
		 * The view stored in this property represents the root view for the view controller’s view hierarchy. The default value of this property is nil.
		 *
		 * If you access this property and its value is currently null, the view controller automatically calls the loadView method and returns the resulting view.
		 *
		 * Each view controller object is the sole owner of its view. You must not associate the same view object with multiple view controller objects. The only exception to this rule is that a container view controller implementation may add this view as a subview in its own view hierarchy. Before adding the subview, the container must first call its addChildViewController: method to create a parent-child relationship between the two view controller objects.
		 *
		 * Because accessing this property can cause the view to be loaded automatically, you can use the isViewLoaded method to determine if the view is currently in memory. Unlike this property, the isViewLoaded property does not force the loading of the view if it is not currently in memory.
		 *
		 * The UIViewController class can automatically set this property to nil during low-memory conditions and also when the view controller itself is finally released.
		 *
		 * @return UIView
		 *
		 */
		public function get view():UIView
		{
			if (!_view&&!_isDestroy) {
				viewWillLoad();
				viewLoadTime = getTimer();
				loadView();
				viewLoadTime = getTimer()-viewLoadTime;
				viewDidLoad();
			}
			return _view;
		}

		public function set view(viewToSet:UIView):void
		{
			if (_view) {
				unloadView();
			}
			
			_view = viewToSet;
			_isViewLoaded = true;
			
		}

		/**
		 *  UIKit framework calls this automatically, if you created your own navigation controller you should call this before the controller is set to null
		 */
		public function destroy():void
		{
			if (parentViewController) {
				throw new ArgumentError("UIViewController must be removed from its super UIViewController before destroy.");
			}
			var childViewController:UIViewController;
			for (var i:int = 0; i<childViewControllers.length; i++) {
				childViewController = childViewControllers[int(i)];
				removeChildViewController(childViewController);
				childViewController.destroy();
				i = 0;
			}

			_isDestroy = true;
			//destroy itself later
			if (_view) {
				unloadView();
			}
		}
		
		protected function doAddChildController(childController:UIViewController, index:int = -1):void
		{

			childController.willMoveToParentViewController(this);

			if (index==-1) {
				childViewControllers.push(childController);
			} else {
				childViewControllers.splice(index, 0, childController);
			}

			childController.parentViewController = this;

			if (index==-1) {
				view.addChild(childController.view);
			} else {
				view.addChildAt(childController.view, index);
			} 

			if(childController.view.autoresizingMask!=UIViewAutoresizing.NONE) {
				view.setNeedsLayout();
				view.layoutIfNeeded();
			}
			
			childController.didMoveToParentViewController(this);
			
			
		}
		
		// =================================================================================================
		//
		//  Animations
		//
		// =================================================================================================
		
		public function get transitionFlow ():String {
			return UITransitionFlow.CROSS;
		}
		
		public function transitionForcedComplete ():void {
			TweenLite.killTweensOf(view, true);
		}
		
		protected function get transitionDelay ():Number {
			return 0.3; 
		} 
		
		public function transitionIn(completedHandler:Function, viewDidJustAdded:Boolean):void
		{
			TweenLite.killTweensOf(view);
			
			if(viewDidJustAdded) {
				view.x = navigationController.view.frame.width;
				TweenLite.to(view, 0.8, {x: 0, ease:Strong.easeOut, delay: transitionDelay, onComplete: function():void
				{
					TweenLite.killTweensOf(view);
					completedHandler();
				}});
			} else {
				view.x = -navigationController.view.frame.width;
				TweenLite.to(view, 0.8, {x: 0, ease: Strong.easeOut, delay: transitionDelay, onComplete: function():void
				{
					TweenLite.killTweensOf(view);
					completedHandler();
				}});
			}
		}
		
		public function transitionOut(completedHandler:Function, viewWillBeRemoved:Boolean):void
		{
			TweenLite.killTweensOf(view);
			if(viewWillBeRemoved) {
				TweenLite.to(view, 0.8, {x: navigationController.view.frame.width, ease: Strong.easeOut, delay: transitionDelay, onComplete: function():void
				{
					TweenLite.killTweensOf(view);
					completedHandler();
				}});
			} else {
				TweenLite.to(view, 0.8, {x: -navigationController.view.frame.width, ease: Strong.easeOut, delay: transitionDelay, onComplete: function():void
				{
					TweenLite.killTweensOf(view);
					completedHandler();
				}});
			}
		}


		// =================================================================================================
		//
		// Override these functions to get notify when controller's state is changing
		//
		// =================================================================================================

		/**
		 * <p>Creates the view that the controller manages.</p>
		 *
		 * <p><b>Discussion</b></p>
		 *
		 * <p>You should never call this method directly. The view controller calls this method when its view property is requested but is currently nil. This method loads or creates a view and assigns it to the view property.</p>
		 *
		 * <p>You can override this method in order to create your views manually, or it will create an empty UIView object for you. The views you create should be unique instances and should not be shared with any other view controller object. Your custom implementation of this method should not call super.</p>
		 *
		 * <p>If you want to perform any additional initialization of your views, do so in the viewDidLoad method. You should also override the viewDidUnload method to release any references to the view or its contents.</p>
		 */
		protected function loadView():void
		{
			//implement this
			throw new ArgumentError("You must implement loadView method and should never call super.");
		}


		protected function shouldAutorotateToInterfaceOrientation(interfaceOrientation:String):Boolean
		{
			//implement this
			return false;
		}

		protected function willRotateToInterfaceOrientation(interfaceOrientation:String):void
		{
			//implement this
		}

		protected function didRotateToInterfaceOrientation(interfaceOrientation:String):void
		{
			//implement this
		}
		
		
		
		/**
		 * <p>Called just before the view controller is added or removed from a container view controller.</p>
		 *
		 * @param parent The parent view controller, or null if there is no parent.
		 *
		 * <p><b>Discussion</b></p>
		 * <p>Your view controller can override this method when it needs to know that it has been added to a container.</p>
		 * <p>When your custom container calls the addChildViewController: method, it automatically calls the <code>willMoveToParentViewController</code>: method of the view controller to be added as a child before adding it. However, if you disable automatic forwarding of events, you need to perform this task yourself.</p>
		 *
		 */
		protected function willMoveToParentViewController(parent:UIViewController):void
		{
			//implement this
		}

		/**
		 * <p>Called after the view controller is added or removed from a container view controller.</p>
		 *
		 * @param parent The parent view controller, or null if there is no parent.
		 *
		 * <p><b>Discussion</b></p>
		 * <p>Your view controller can override this method when it wants to react to being added to a container.</p>
		 * <p>The <code>removeFromParentViewController</code> method automatically calls the <code>didMoveToParentViewController</code>: method of the child view controller after it removes the child. However, if you disable automatic forwarding of events, you need to perform this task yourself.</p>
		 *
		 */
		protected function didMoveToParentViewController(parent:UIViewController):void
		{
			//implement this
		}

		/**
		 * Notifies the view controller that its view is about to be added to a view hierarchy.
		 * @param animated If YES, the view is being added to the window using an animation.
		 */
		public function viewWillAppear(animated:Boolean):void
		{
			//implement this
		}

		/**
		 * Notifies the view controller that its view was added to a view hierarchy.
		 * @param animated If YES, the view was added to the window using an animation.
		 *
		 */
		public function viewDidAppear(animated:Boolean):void
		{
			//implement this
		}

		/**
		 * Indicates when view is going to start transition which will result in the view is removed from display list when transition ends.
		 * @param animated If YES, the disappearance of the view is being animated.
		 *
		 */
		public function viewWillDisappear(animated:Boolean):void
		{
			//implement this
		}

		/**
		 * Notifies the view controller that its view was removed from a view hierarchy.
		 * @param animated If YES, the disappearance of the view was animated.
		 *
		 */
		public function viewDidDisappear(animated:Boolean):void
		{
			//implement this
		}

		/**
		 * Notifies before view will unload due to view is in changing process.
		 *
		 */
		protected function viewWillUnload():void
		{
			//implement this
		}

		/**
		 * Notifies when view is unloaded due to view is changed.
		 *
		 */
		protected function viewDidUnload():void
		{
			//implement this
		}

		/**
		 * Notofies before <code>loadView</code>
		 *
		 */
		protected function viewWillLoad():void
		{
			//implement this
		}

		/**
		 * Notofies after view is loaded via <code>loadView</code>
		 *
		 */
		protected function viewDidLoad():void
		{
			//implement this
		}
		
		

		// =================================================================================================
		//
		//  Internal used by UIKit only.
		//
		// =================================================================================================

		private function unloadView():void
		{
			if (_view) {
				viewWillUnload();
				if (view.parent) {
					view.parent.removeChild(view);
				}
				_view.destroy();
				_view = null;
				viewDidUnload();
			}
		}

		private function doRemoveChildController(childController:UIViewController):void
		{
			childController.willMoveToParentViewController(null);

			for (var i:uint = 0; i<childViewControllers.length; i++) {
				if (childViewControllers[i]==childController) {
					childViewControllers.splice(i, 1);
					i = 0;
				}
			}

			childController.parentViewController = null;

			view.removeChild(childController.view);

			childController.didMoveToParentViewController(null);
		}

		/**
		 * @internal
		 */
		internal function willRotateToInterfaceOrientation_(interfaceOrientation:String):void
		{
			willRotateToInterfaceOrientation(interfaceOrientation);
		}

		/**
		 * @internal
		 */
		internal function didRotateToInterfaceOrientation_(interfaceOrientation:String):void
		{
			didRotateToInterfaceOrientation(interfaceOrientation);
		}

		/**
		 * @internal
		 */
		internal function shouldAutorotateToInterfaceOrientation_(interfaceOrientation:String):Boolean
		{
			return shouldAutorotateToInterfaceOrientation(interfaceOrientation);
		}

	}
}


