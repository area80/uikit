package net.area80.uikit.component.facebook
{

	import net.area80.uikit.UIColor;
	import net.area80.uikit.UIDefaultAssetManager;
	import net.area80.uikit.UIView;
	import net.area80.uikit.component.UINavigationbarView;
	import net.area80.uikit.component.UIImageButton;

	import starling.display.Image;

	public class UIFacebookNavigationbarView extends UINavigationbarView
	{

		public var cancelButton:UIImageButton;
		public var okButton:UIImageButton;

		public function UIFacebookNavigationbarView()
		{
			super();
		}

		public function initAsLoginbar():UIFacebookNavigationbarView
		{
			var bg:UIColor = new UIColor().initWithTexture(UIDefaultAssetManager.fbNavigationbarBackground);
			var view:UIView = super.initWithColor(bg);

			var title:Image = new Image(UIDefaultAssetManager.fbNavigationbarTitleLogin);
			cancelButton = new UIImageButton().initWithTexture(UIDefaultAssetManager.fbNavigationbarButtonCancel, UIDefaultAssetManager.fbNavigationbarButtonCancel_down);

			setTitle(title);
			setRightBarButton(cancelButton);

			return view as UIFacebookNavigationbarView;
		}

		public function initAsLogoutbar():UIFacebookNavigationbarView
		{
			var bg:UIColor = new UIColor().initWithTexture(UIDefaultAssetManager.fbNavigationbarBackground);
			var view:UIView = super.initWithColor(bg);

			var title:Image = new Image(UIDefaultAssetManager.fbNavigationbarTitleLogout);
			cancelButton = new UIImageButton().initWithTexture(UIDefaultAssetManager.fbNavigationbarButtonCancel, UIDefaultAssetManager.fbNavigationbarButtonCancel_down);

			setTitle(title);
			setRightBarButton(cancelButton);

			return view as UIFacebookNavigationbarView;
		}


		public function initAsFriendSelector(isMultipleSelect:Boolean=true):UIFacebookNavigationbarView
		{
			var bg:UIColor = new UIColor().initWithTexture(UIDefaultAssetManager.fbNavigationbarBackground);
			var view:UIView = super.initWithColor(bg);
			var title:Image = new Image(UIDefaultAssetManager.fbNavigationbarTitleFriends);
			cancelButton = new UIImageButton().initWithTexture(UIDefaultAssetManager.fbNavigationbarButtonCancel, UIDefaultAssetManager.fbNavigationbarButtonCancel_down);
			okButton = new UIImageButton().initWithTexture(UIDefaultAssetManager.fbNavigationbarButtonOK, UIDefaultAssetManager.fbNavigationbarButtonOK_down);

			if (!isMultipleSelect) setTitle(title);
			setLeftBarButton(cancelButton);
			setRightBarButton(okButton);

			return view as UIFacebookNavigationbarView;
		}
	}
}
