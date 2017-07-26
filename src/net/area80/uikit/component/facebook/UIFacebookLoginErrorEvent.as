package net.area80.uikit.component.facebook
{

	import flash.events.Event;

	public class UIFacebookLoginErrorEvent extends Event
	{
		public static const ERROR:String = "error";
		public var errorReason:String;

		public function UIFacebookLoginErrorEvent(type:String, reason:String)
		{
			this.errorReason = reason;
			super(type);
		}
	}
}
