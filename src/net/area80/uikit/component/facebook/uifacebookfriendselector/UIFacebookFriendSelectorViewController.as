package net.area80.uikit.component.facebook.uifacebookfriendselector
{
	import com.greensock.TweenLite;
	
	import flash.events.Event;
	
	import net.area80.api.event.APIErrorEvent;
	import net.area80.starling.texturecatch.TextureCacheController;
	import net.area80.uikit.UIScreen;
	import net.area80.uikit.UIScrollViewEquivalentSizeItem;
	import net.area80.uikit.UIView;
	import net.area80.uikit.UIViewController;
	import net.area80.uikit.component.facebook.uifacebookfriendselector.api.APIGetFriendsPage;
	import net.area80.uikit.component.facebook.uifacebookfriendselector.controller.UIFacebookFriendSelectorHeadViewController;
	import net.area80.uikit.component.facebook.uifacebookfriendselector.controller.UIFacebookScrollViewController;
	import net.area80.uikit.component.facebook.uifacebookfriendselector.data.FacebookFriendData;
	import net.area80.uikit.component.facebook.uifacebookfriendselector.view.FacebookFriendItem;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;

	public class UIFacebookFriendSelectorViewController extends UIViewController
	{
		private var _token:String;
		private var IsMultipleSelect:Boolean;
		private var apiGetFriendsPage:APIGetFriendsPage;
		private var friendItems:Vector.<FacebookFriendItem> = new Vector.<FacebookFriendItem>();

		private var scrollViewController:UIFacebookScrollViewController;
		private var headViewController:UIFacebookFriendSelectorHeadViewController;

		private var textureNameCacheController:TextureCacheController;
		private var texturePictureCacheController:TextureCacheController;

		private var selectedItem:Vector.<FacebookFriendItem> = new Vector.<FacebookFriendItem>(); // use for multiple select
		private var nowMode:Number = 0;
		private var nowSearchText:String = "";
		
		private var CurrentSingleSelectItem:FacebookFriendItem; // use for single select
		private var ResultFBSelectedHandler:Function;

		private var itemTweening:Vector.<DisplayObject> = new Vector.<DisplayObject>();

		public function UIFacebookFriendSelectorViewController(_token:String,resultFBSelectedHandler:Function,isMultipleSelect:Boolean=true)
		{
			super();
			this._token = _token;
			IsMultipleSelect = isMultipleSelect;
			ResultFBSelectedHandler = resultFBSelectedHandler;
		}

		override protected function loadView():void
		{
			view = new UIView().initWithFrame(UIScreen.applicationFrame);

			scrollViewController = new UIFacebookScrollViewController();
			scrollViewController.view.y = 176
			scrollViewController.signalDelete.add(deleteItem);
			addChildViewController(scrollViewController);

			textureNameCacheController = new TextureCacheController(300);
			texturePictureCacheController = new TextureCacheController();

			headViewController = new UIFacebookFriendSelectorHeadViewController(IsMultipleSelect);
			headViewController.signalSearch.add(search);
			if (IsMultipleSelect) headViewController.signalMode.add(changeMode);
			
			headViewController.signalCancel.add(cancelClickHandler);
			headViewController.signalOK.add(okClickHandler);
			addChildViewController(headViewController);
		}

		override public function viewDidAppear(animated:Boolean):void
		{
			apiGetFriendsPage = new APIGetFriendsPage(_token);
			apiGetFriendsPage.addEventListener(Event.COMPLETE, loadedFriend);
			apiGetFriendsPage.addEventListener(APIErrorEvent.ERROR, onCancelLoad);
			apiGetFriendsPage.load();
			super.viewDidAppear(animated);
		}

		protected function loadedFriend(event:Event):void
		{
			var friendDatas:Vector.<FacebookFriendData> = apiGetFriendsPage.friendsDatas;
			apiGetFriendsPage = null;
			for (var i:uint = 0; i<=friendDatas.length-1; i++) {
				var friendItem:FacebookFriendItem = new FacebookFriendItem(friendDatas[i], view.frame.width, IsMultipleSelect, textureNameCacheController, texturePictureCacheController);
				friendItem.touchable = false;
				friendItems.push(friendItem);
				friendItem.signalChangeStatus.add(friendItemStatusChange);
			}
			show();
		}
		
		protected function onCancelLoad(event:APIErrorEvent):void{
			if (apiGetFriendsPage){
				apiGetFriendsPage.removeEventListener(Event.COMPLETE, loadedFriend);
				apiGetFriendsPage.removeEventListener(APIErrorEvent.ERROR, onCancelLoad);
				apiGetFriendsPage.destroy();
				apiGetFriendsPage = null;
			}
		}

		override public function viewWillDisappear(animated:Boolean):void
		{
			onCancelLoad(null);
			super.viewWillDisappear(animated);
		}

		private function search(_text:String = ""):void
		{
			nowSearchText = _text;
			show();
		}

		private function show():void
		{
			UIScrollViewEquivalentSizeItem(scrollViewController.view).removeAllContent();
			var i:uint;
			var nowModeFriends:Vector.<FacebookFriendItem> = new Vector.<FacebookFriendItem>();
			var friendItemsFiltered:Vector.<FacebookFriendItem> = new Vector.<FacebookFriendItem>();

			if (nowMode==0) {
				nowModeFriends = friendItems;
			} else if (nowMode==1) {
				nowModeFriends = selectedItem;
			}
			for (i = 0; i<=nowModeFriends.length-1; i++) {
				if (nowSearchText==""||nowModeFriends[i].friendDatas.name.toUpperCase().indexOf(nowSearchText.toUpperCase())!=-1) {
					friendItemsFiltered.push(nowModeFriends[i]);
				}
			}
			
			for (i = 0; i<=friendItemsFiltered.length-1; i++) {
				UIScrollViewEquivalentSizeItem(scrollViewController.view).addContent(friendItemsFiltered[i]);
			}
		}

		private function changeMode(_mode:Number):void
		{
			nowMode = _mode;
			var i:uint;
			if (_mode==0) {
				scrollViewController.view.touchable = true;
				for (i = 0; i<=itemTweening.length-1; i++) {
					TweenLite.killTweensOf(itemTweening[i]);
				}
			}
			for (i = 0; i<=selectedItem.length-1; i++) {
				selectedItem[i].nowMode = _mode;
			}
			scrollViewController.changeMode(_mode);
			show();
		}
		
		protected function cancelClickHandler():void{
			navigationController.popViewControllerAnimated(true);
		}
		
		protected function okClickHandler():void{
			if (ResultFBSelectedHandler!=null) {
				if (IsMultipleSelect){
					if (selectedItem.length<=0) return;
					var friendsData:Vector.<FacebookFriendData> = new Vector.<FacebookFriendData>;
					for (var i:int = 0; i<selectedItem.length; i++) {
						friendsData.push(new FacebookFriendData(selectedItem[i].friendDatas.name,selectedItem[i].friendDatas.id));
					}
					// return vector of FacebookFriendData
					ResultFBSelectedHandler(friendsData);
				}else{
					if (CurrentSingleSelectItem==null) return;
					var friendData:FacebookFriendData = new FacebookFriendData(CurrentSingleSelectItem.friendDatas.name,CurrentSingleSelectItem.friendDatas.id);
					// return single FacebookFriendData
					ResultFBSelectedHandler(friendData);
				}
			}
			navigationController.popViewControllerAnimated(true);
		}

		private function friendItemStatusChange(_item:FacebookFriendItem, _isSelected:Boolean):void{
			var i:uint;
			if (IsMultipleSelect){
				if (_isSelected) {
					for (i = 0; i<=selectedItem.length-1; i++) {
						if (_item==selectedItem[i]) {
							return;
						}
					}
					selectedItem.push(_item);
				} else {
					for (i = 0; i<=selectedItem.length-1; i++) {
						if (_item==selectedItem[i]) {
							selectedItem.splice(i, 1);
						}
					}
				}
			}else{
				if (CurrentSingleSelectItem != _item){
					if (CurrentSingleSelectItem) CurrentSingleSelectItem.unSelect(); // unselect previous item
					CurrentSingleSelectItem = _item;
				}
			}
		}

		private function deleteItem(_item:DisplayObject):void
		{
			FacebookFriendItem(_item).nowMode = 0;
//			UIScrollViewEquivalentSizeItem(scrollViewController.view).removeContent(_item);
			FacebookFriendItem(_item).selected = false;
			_item.visible = false;

			var isUnderDeleteItem:Boolean = false;
			var isFirstTween:Boolean = true;
			for (var i:uint = 0; i<=selectedItem.length-1; i++) {
				if (isUnderDeleteItem) {
					itemTweening.push(selectedItem[i]);
					if (isFirstTween) {
						scrollViewController.view.touchable = false;
						TweenLite.to(selectedItem[i], .2, {y: FacebookFriendItem.HEIGHT*i, onComplete: function():void {
							//show();
							_item.visible = true;
							itemTweening = new Vector.<DisplayObject>();
							scrollViewController.view.touchable = true;
							show();
						}});
					} else {
						TweenLite.to(selectedItem[i], .2, {y: FacebookFriendItem.HEIGHT*i});
					}
					isFirstTween = false;
				}
				if (selectedItem[i]==_item) {
					isUnderDeleteItem = true;
					selectedItem.splice(i, 1);
					i--;
				}
			}
		}
	}
}
