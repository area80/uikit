package net.area80.uikit
{

	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.StageOrientationEvent;
	import flash.geom.Rectangle;
	
	import net.area80.async.AsyncTaskManager;
	
	import starling.core.Starling;
	import starling.display.Sprite;

	public class AppDelegate extends Sprite
	{
		protected static var _instance:AppDelegate;
		protected static var _window:UIWindow;

		public static var flashStage:Stage;

		private static var _windowController:UIWindowController;

		private static var star:Starling;
		private static var asyncTaskManager:AsyncTaskManager;

		public static function get window():UIWindow
		{
			return _window;
		}

		public function AppDelegate()
		{
			if (_instance)
				throw new ArgumentError("Delegate can't be instance");
			_instance = this;

			asyncTaskManager = new AsyncTaskManager(0);

			initSystem();
			initWindow();
			initAsyncTask(asyncTaskManager);
		}

		protected function initAsyncTask(async:AsyncTaskManager):void
		{

			if (async.totalTask>0) {
				async.signalComplete.add(function():void {
					if (UIAssetPreloader.getInstance()) {
						UIAssetPreloader.getInstance().preloadCompleted();
					}
					async.dispose();
					asyncTaskManager = null;
					initApplication();
				});
				async.signalProgress.add(function(a:Number, b:Number):void {
					if (UIAssetPreloader.getInstance()) {
						UIAssetPreloader.getInstance().updateProgress(a, b);
					}
				});
				async.run()
			} else {
				initApplication();
			}
		}


		private function initWindow():void
		{
			_windowController = new UIWindowController();
			_window = _windowController.view as UIWindow;
			_window.scaleX = _window.scaleY = UIScreen.scale;
			addChild(window);
		}

		private function initSystem():void
		{
			if (flashStage.supportedOrientations&&flashStage.supportedOrientations.length>1) {
				flashStage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGING, onOrientationChanging);
				flashStage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGE, onOrientationChange);
			}
		}

		private function orientationWillChanging(orientation:String, viewController:UIViewController):void
		{
			if (viewController.shouldAutorotateToInterfaceOrientation_(orientation)) {
				viewController.willRotateToInterfaceOrientation_(orientation);
			}
			for (var i:uint = 0; i<viewController.childViewControllers.length; i++) {
				orientationWillChanging(orientation, viewController.childViewControllers[i]);
			}
		}

		private function orientationDidChanging(orientation:String, viewController:UIViewController):void
		{
			if (viewController.shouldAutorotateToInterfaceOrientation_(orientation)) {
				viewController.didRotateToInterfaceOrientation_(orientation);
			}
			for (var i:uint = 0; i<viewController.childViewControllers.length; i++) {
				orientationDidChanging(orientation, viewController.childViewControllers[i]);
			}
		}

		internal static function attemptRotationToDeviceOrientation(viewController:UIViewController):void
		{

			_instance.orientationWillChanging(flashStage.orientation, viewController);
			_instance.orientationDidChanging(flashStage.orientation, viewController);
		}


		private function onOrientationChanging(event:StageOrientationEvent):void
		{
			orientationWillChanging(event.afterOrientation, _windowController);
		}

		private function onOrientationChange(event:StageOrientationEvent):void
		{
			if (UIScreen.autoRotatationIsSupported) {
				orientationDidChanging(event.afterOrientation, window.rootViewController);
			}
		}

		/**
		 *
		 * @param mainAppDelegateClass
		 * @param stage
		 * @param portrait In the most case, it's width size of the screen, some case you may want to fix display size of it for unsupported resolution devices.
		 * @param landscape In the most case, it's height size of the screen, some case you may want to fix display size of it for unsupported resolution devices.
		 * @param scale It's up to your texture size, if you design it in high resolution but devices supports lower resolution you judge the scale it would be. Most case it's 1 and 0.5 for lower resolution. But some application your design us in lower resolution. If it's that case, in high resolution devices scale should be 2 to enlarge it up. Note that scale will be combinded to size in some devices, for the best result, your size should be proper to multiply with the scale without decimal.
		 * @param autoRotatationIsSupported You specify this Boolean the same way as proterty autoOrients in app.xml does
		 */
		public static function initCG(mainAppDelegateClass:Class, stage:Stage, portrait:uint, landscape:uint, scale:Number = 1, autoRotatationIsSupported:Boolean = false):void
		{
			if (flashStage)
				throw new ArgumentError("CG is already init, re-init is not allowed");

			flashStage = stage;

			flashStage.scaleMode = StageScaleMode.NO_SCALE;
			flashStage.align = StageAlign.TOP_LEFT;

			UIScreen.initDeviceFrame(portrait/scale, landscape/scale, scale, autoRotatationIsSupported);

			var rect:Rectangle = new Rectangle(0, 0, UIScreen.applicationFrame.width*UIScreen.scale, UIScreen.applicationFrame.height*UIScreen.scale);

			star = new Starling(mainAppDelegateClass, flashStage, rect);

			star.start();
			//star.simulateMultitouch = true;
		}

		public function getStage3D():Stage3D
		{
			return star.stage3D;
		}

		public function initApplication():void
		{
			throw ArgumentError("Override initApplication then init window.rootViewController");
		}
	}
}
