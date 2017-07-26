package net.area80.uikit.component.facebook.uifacebookfriendselector.controller
{
	import flash.events.Event;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import net.area80.uikit.UIScreen;
	import net.area80.uikit.UIViewController;
	import net.area80.uikit.component.UIStageText;
	import net.area80.uikit.component.facebook.uifacebookfriendselector.view.UIFacebookFriendSelectorHeadView;
	
	import org.osflash.signals.Signal;

	public class UIFacebookFriendSelectorHeadViewController extends UIViewController
	{
		private var IsMultipleSelect:Boolean;
		private const DELAY_SEARCH:Number = 1000;
		public var signalSearch:Signal = new Signal(String);
		public var signalMode:Signal = new Signal(Number);
		public var signalCancel:Signal = new Signal();
		public var signalOK:Signal = new Signal();

		private var textSearch:UIStageText;
		private var timeoutId:uint = 0;

		public function UIFacebookFriendSelectorHeadViewController(isMultipleSelect:Boolean)
		{
			IsMultipleSelect = isMultipleSelect;
			super();
		}

		override protected function loadView():void
		{
			view = new UIFacebookFriendSelectorHeadView(IsMultipleSelect).initWithFrame(UIScreen.applicationFrame);
			if (IsMultipleSelect) UIFacebookFriendSelectorHeadView(view).signalMode.add(changeMode);
			
			UIFacebookFriendSelectorHeadView(view).signalCancel.add(cancelClickHandler);
			UIFacebookFriendSelectorHeadView(view).signalOK.add(okClickHandler);
			
			textSearch = getUIFacebookFriendSelectorView.getSearchText();
			textSearch.responder.addEventListener(Event.CHANGE,changeSearchText);
		}

		private function changeMode(_mode:Number):void{
			signalMode.dispatch(_mode);
		}
		
		protected function cancelClickHandler():void{
			signalCancel.dispatch();
		}
		
		protected function okClickHandler():void{
			signalOK.dispatch();
		}

		override public function viewDidAppear(animated:Boolean):void
		{
			super.viewDidAppear(animated);
		}

		protected function changeSearchText(event:Event):void
		{
			clearTimeout(timeoutId);
			timeoutId = setTimeout(search, DELAY_SEARCH);
		}

		private function search():void{
			signalSearch.dispatch(textSearch.text);
		}

		override public function viewWillDisappear(animated:Boolean):void
		{
			textSearch.responder.removeEventListener(Event.CHANGE,changeSearchText);
			signalMode.removeAll();
			signalMode = null;
			signalCancel.removeAll();
			signalCancel = null;
			signalOK.removeAll();
			signalOK = null;
			clearTimeout(timeoutId);
			super.viewWillDisappear(animated);
		}


		private function get getUIFacebookFriendSelectorView():UIFacebookFriendSelectorHeadView
		{
			return view as UIFacebookFriendSelectorHeadView;
		}
	}
}
