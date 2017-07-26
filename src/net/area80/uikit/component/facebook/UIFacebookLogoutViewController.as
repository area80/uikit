package net.area80.uikit.component.facebook
{

	import com.facebook.graph.FacebookMobile;
	
	import flash.events.LocationChangeEvent;
	
	import net.area80.facebook.FacebookMobileUser;

	[Event(name = "error", type = "net.area80.uikit.component.facebook.UIFacebookLoginErrorEvent")]
	[Event(name = "logoutsuccess", type = "net.area80.uikit.component.facebook.UIFacebookLoginSuccessEvent")]

	public class UIFacebookLogoutViewController extends UIFacebookLoginViewController
	{

		private var appOrigin:String;

		private var navigationbar:UIFacebookNavigationbarView;

		/**
		 * You can just simply put callback to display the message when the popup is finish or add listener as the old fashioned way
		 * @param successCallback
		 * @param errorCallback
		 *
		 */
		public function UIFacebookLogoutViewController(appOrigin:String, successCallback:Function = null, errorCallback:Function = null)
		{
			this.appOrigin = appOrigin;
			super(successCallback, errorCallback);

		}

		override protected function loadNavigationBar ():void {
			navigationbar = new UIFacebookNavigationbarView().initAsLogoutbar();
		}

		override protected function processFacebookCall():void
		{
			FacebookMobile.webViewLogout(handleLogoutCallback, appOrigin, html);
		}


		protected function handleLogoutCallback(cb:Object = null, cberror:Object = null):void
		{
			if (cb) {
				if (FacebookMobileUser.getInstance()) {
					FacebookMobileUser.getInstance().setUser(null);
				}
				closedEvent = new UIFacebookLoginSuccessEvent(UIFacebookLoginSuccessEvent.LOGOUT_SUCCESS, null);
				closeView();
			} else {
				var reason:String = (cberror && typeof(cberror) != "string" && cberror["error_reason"]) ? cberror["error_reason"] : "Unknown error, please try again.";
				closedEvent = new UIFacebookLoginErrorEvent(UIFacebookLoginErrorEvent.ERROR, reason);
				closeView();
			}
		}


		override protected function onLocationChange(e:LocationChangeEvent):void
		{
			
		}
		
	}
}
