package net.area80.uikit.component.facebook
{

	import flash.events.Event;

	import net.area80.facebook.FacebookUser;

	public class UIFacebookLoginSuccessEvent extends Event
	{
		public static const LOGIN_SUCCESS:String = "loginsuccess";
		public static const LOGOUT_SUCCESS:String = "logoutsuccess";

		public var user:FacebookUser;

		public function UIFacebookLoginSuccessEvent(type:String, data:FacebookUser)
		{
			this.user = data;
			super(type);
		}
	}
}
