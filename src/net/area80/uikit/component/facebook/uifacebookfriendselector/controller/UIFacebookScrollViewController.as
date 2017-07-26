package net.area80.uikit.component.facebook.uifacebookfriendselector.controller
{
	import net.area80.uikit.CGRect;
	import net.area80.uikit.UIScreen;
	import net.area80.uikit.UIViewController;
	import net.area80.uikit.component.facebook.uifacebookfriendselector.view.UIFacebookScrollView;
	
	import org.osflash.signals.Signal;
	
	import starling.display.DisplayObject;

	public class UIFacebookScrollViewController extends UIViewController
	{
		public var signalDelete:Signal = new Signal(DisplayObject);

		public function UIFacebookScrollViewController()
		{
			super();
		}

		override protected function loadView():void
		{
			view = new UIFacebookScrollView().initWithFrame(new CGRect(UIScreen.applicationFrame.width, UIScreen.applicationFrame.height-176));
			UIFacebookScrollView(view).signalDelete.add(deleteItem);
		}

		private function deleteItem(_item:DisplayObject):void
		{
			signalDelete.dispatch(_item);
		}

		override public function destroy():void
		{
			super.destroy();
		}

		public function changeMode(_mode:Number):void
		{
			uiFacebookScrollView.changeMode(_mode);
		}

		private function get uiFacebookScrollView():UIFacebookScrollView
		{
			return UIFacebookScrollView(view);
		}
	}
}
