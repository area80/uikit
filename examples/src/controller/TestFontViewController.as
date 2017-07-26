package controller
{

	import net.area80.uikit.UIColor;
	import net.area80.uikit.UIDefaultAssetManager;
	import net.area80.uikit.UIDefaultStyle;
	import net.area80.uikit.UIScreen;
	import net.area80.uikit.UIView;
	import net.area80.uikit.UIViewController;
	import net.area80.uikit.component.UILabel;

	public class TestFontViewController extends UIViewController
	{
		public function TestFontViewController()
		{
			super();
		}

		override protected function loadView():void
		{
			view = new UIView().initWithFrame(UIScreen.applicationFrame.copy());
			view.background = new UIColor().initWithTexture(UIDefaultAssetManager.backgroundTextureLightblue, UIScreen.applicationFrame.copy());

			var tf:UILabel = new UILabel("Label Test Long Text", false, UIDefaultStyle.font40pxLargeBoldWhiteWithBavel);
			view.addChild(tf);
			tf.x = 20;
			var tf2:UILabel = new UILabel("Label", false, UIDefaultStyle.font40pxLargeBoldBlackWithBavel);
			view.addChild(tf2);
			tf2.x = 20;
			tf2.y = 100;
		}

	}
}
