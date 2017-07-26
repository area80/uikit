package net.area80.uikit
{

	final internal class UIWindowController extends UIViewController
	{
		public function UIWindowController()
		{
			super();
		}

		override protected function loadView():void
		{
			view = new UIWindow(this).initWithFrame(UIScreen.applicationFrame.copy());
			calloutViewController = new UICalloutViewController();
			addChildViewController(calloutViewController); 

		}
		

	}
}
