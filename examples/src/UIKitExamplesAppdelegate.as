package
{

	import controller.TestFontViewController;

	import net.area80.uikit.AppDelegate;

	public class UIKitExamplesAppdelegate extends AppDelegate
	{
		public function UIKitExamplesAppdelegate()
		{
			super();
		}

		override public function initApplication():void
		{

			window.rootViewController = new TestFontViewController();
		}

	}
}
