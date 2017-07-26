package net.area80.uikit.component.facebook.uifacebookfriendselector.api
{
	import flash.net.URLVariables;
	
	import net.area80.api.APIErrorCode;
	import net.area80.api.BaseAPI;
	import net.area80.uikit.component.facebook.uifacebookfriendselector.data.FacebookFriendData;

	public class APIGetFriendsPage extends BaseAPI
	{
		public var friendsDatas:Vector.<FacebookFriendData> = new Vector.<FacebookFriendData>();

		public function APIGetFriendsPage(access_token:String)
		{
			var urlVar:URLVariables = new URLVariables();
			urlVar.access_token = access_token;
			super("https://graph.facebook.com/me/friends", urlVar, "GET");
		}
		
		protected override function gotData(data:*):void
		{
			
			_raw = String(data);
			try {
				if (_raw=="") {
					throw getErrorByCode(APIErrorCode.SERVER_ERROR);
				}
				var xmlData:XML = XML(data);
				successHandler(xmlData);
			} catch (e:Error) {
				errorHandler(e);
			}
		}
		
		override protected function successHandler(data:XML):void
		{
			try {
				var json:* = JSON.parse(String(data));
				for (var i:* in json.data) {
					friendsDatas.push(new FacebookFriendData(json.data[i].name, json.data[i].id));
				}
				super.successHandler(data);
			} catch (e:Error){
				super.errorHandler(e);
			}
		}
	}
}
