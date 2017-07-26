package net.area80.uikit.component.facebook.uifacebookfriendselector.view
{

	import flash.events.Event;
	import flash.text.ReturnKeyLabel;
	
	import net.area80.uikit.CGRect;
	import net.area80.uikit.UIDefaultAssetManager;
	import net.area80.uikit.UIKitApplicationMain;
	import net.area80.uikit.UIScreen;
	import net.area80.uikit.UITouchEvent;
	import net.area80.uikit.UITouchResponder;
	import net.area80.uikit.UIView;
	import net.area80.uikit.UIViewHelper;
	import net.area80.uikit.component.UIStageText;
	import net.area80.uikit.component.facebook.UIFacebookNavigationbarView;
	import net.area80.uikit.style.AndroidStyle;
	
	import org.osflash.signals.Signal;
	
	import starling.display.Image;
	import starling.events.TouchEvent;

	public class UIFacebookFriendSelectorHeadView extends UIView
	{
		public var signalMode:Signal = new Signal(Number);
		public var signalCancel:Signal = new Signal();
		public var signalOK:Signal = new Signal();
		private var IsMultipleSelect:Boolean;
		private var _textInput:UIStageText;

		private var selectedBtn:Image;
		private var allBtn:Image;
		private var allTouchRes:UITouchResponder;
		private var selectedTouchRes:UITouchResponder;
		private var nowSelectBtn:Image = allBtn;

		public function UIFacebookFriendSelectorHeadView(isMultipleSelect:Boolean)
		{
			IsMultipleSelect = isMultipleSelect;
			super();
		}

		override public function initWithFrame(aRect:CGRect = null):UIView
		{
			var navigationbar:UIFacebookNavigationbarView = new UIFacebookNavigationbarView().initAsFriendSelector(IsMultipleSelect);
			navigationbar.cancelButton.touchResponder.addEventListener(UITouchEvent.TOUCH_TAB, cancelClickHandler);
			navigationbar.okButton.touchResponder.addEventListener(UITouchEvent.TOUCH_TAB, okClickHandler);
			addChild(navigationbar);

			var headSearch_L:Image = new Image(UIDefaultAssetManager.fbSearchBar_L);
			headSearch_L.y = 88;
			addChild(headSearch_L);
			var headSearch_C:Image = new Image(UIDefaultAssetManager.fbSearchBar_C);
			headSearch_C.x = 58;
			headSearch_C.y = 88;
			headSearch_C.width = UIScreen.applicationFrame.width-58-38;
			addChild(headSearch_C);
			var headSearch_R:Image = new Image(UIDefaultAssetManager.fbSearchBar_R);
			headSearch_R.x = UIScreen.applicationFrame.width-38;
			headSearch_R.y = 88;
			addChild(headSearch_R);

			_textInput = new UIStageText();
			_textInput.x = 68;
			_textInput.y = 114;
			_textInput.width = UIScreen.applicationFrame.width-58-38-10;
			_textInput.height = 40;
			_textInput.editable = true;
			//_textInput.scaleX = searchText.scaleY = UIScreen.scale;
			if (UIKitApplicationMain.isAndroid) {
				_textInput.fontFamily = AndroidStyle.sarabunFontBold.fontName;
				_textInput.fontSize = 36;
				//_textInput.fontSize = int(36*UIScreen.scale);
			} else {
				_textInput.fontFamily = "Tahoma";
				_textInput.fontSize = 28;
				//_textInput.fontSize = int(28*UIScreen.scale);
			}

			_textInput.fontColor = 0x555555;
			
			_textInput.returnKeyLabel = ReturnKeyLabel.DONE;
			_textInput.restrict = "0-9a-zA-Z ";
			_textInput.autoCorrect = false;
			_textInput.paddingLeft = 20;
			_textInput.paddingRight = 0;
			_textInput.paddingTop = 0;
			_textInput.maxChars = 30;
			addChild(_textInput);

			addEventListener(TouchEvent.TOUCH, touchBind);

			if (IsMultipleSelect){
				allBtn = new Image(UIDefaultAssetManager.fbNavigationbarButtonAll);
				allBtn.x = 190;
				allBtn.y = 14;
				addChild(allBtn);
				allTouchRes = new UITouchResponder();
				allTouchRes.addEventListener(UITouchEvent.TOUCH_BEGAN, allBtnMouseDown);
				allTouchRes.addEventListener(UITouchEvent.TOUCH_END, allBtnMouseUp);
				allTouchRes.addEventListener(UITouchEvent.TOUCH_TAB, allBtnClick);
	
	
				selectedBtn = new Image(UIDefaultAssetManager.fbNavigationbarButtonSelected);
				selectedBtn.x = 330;
				selectedBtn.y = 14;
				addChild(selectedBtn);
				selectedTouchRes = new UITouchResponder();
				selectedTouchRes.addEventListener(UITouchEvent.TOUCH_BEGAN, selectedBtnMouseDown);
				selectedTouchRes.addEventListener(UITouchEvent.TOUCH_END, selectedBtnMouseUp);
				selectedTouchRes.addEventListener(UITouchEvent.TOUCH_TAB, selectedBtnClick);

			}
			allBtnMode();
			
			return super.initWithFrame(aRect);
		}


		/**
		 * TOUCH COMPOSER
		 */

		protected function allBtnClick(event:Event):void
		{
			allBtnMode();
		}

		protected function allBtnMouseDown(event:Event):void
		{
			allBtn.alpha = 1;
		}

		protected function allBtnMouseUp(event:Event):void
		{
			if (nowSelectBtn==allBtn) {
				allBtn.alpha = 1;
			} else {
				allBtn.alpha = .5;
			}
		}

		//----

		protected function selectedBtnClick(event:Event):void
		{
			selectedMode();
		}

		protected function selectedBtnMouseDown(event:Event):void
		{
			selectedBtn.alpha = 1;
		}

		protected function selectedBtnMouseUp(event:Event):void
		{
			if (nowSelectBtn==selectedBtn) {
				selectedBtn.alpha = 1;
			} else {
				selectedBtn.alpha = .5;
			}
		}


		private function allBtnMode():void
		{
			if (nowSelectBtn!=allBtn) {
				allBtn.alpha = 1;
				selectedBtn.alpha = .5;
				nowSelectBtn = allBtn;
				signalMode.dispatch(0);
			}
		}

		private function selectedMode():void
		{
			if (nowSelectBtn!=selectedBtn) {
				allBtn.alpha = .5;
				selectedBtn.alpha = 1;
				nowSelectBtn = selectedBtn;
				signalMode.dispatch(1);
			}
		}

		protected function touchBind(event:TouchEvent):void
		{
			UIViewHelper.processTouch(allBtn, allTouchRes, event);
			UIViewHelper.processTouch(selectedBtn, selectedTouchRes, event);
		}

		////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////

		public function getSearchText():UIStageText{
			return _textInput;
		}
		
		override public function dispose ():void {
			removeChild(_textInput);
			_textInput.dispose();
			_textInput = null;
			signalMode.removeAll();
			signalMode = null;
			if (IsMultipleSelect){
				allTouchRes.removeEventListener(UITouchEvent.TOUCH_BEGAN, allBtnMouseDown);
				allTouchRes.removeEventListener(UITouchEvent.TOUCH_END, allBtnMouseUp);
				allTouchRes.removeEventListener(UITouchEvent.TOUCH_TAB, allBtnClick);
				selectedTouchRes.removeEventListener(UITouchEvent.TOUCH_BEGAN, selectedBtnMouseDown);
				selectedTouchRes.removeEventListener(UITouchEvent.TOUCH_END, selectedBtnMouseUp);
				selectedTouchRes.removeEventListener(UITouchEvent.TOUCH_TAB, selectedBtnClick);
			}
			signalCancel.removeAll();
			signalCancel = null;
			signalOK.removeAll();
			signalOK = null;
			super.dispose();
		}

		protected function cancelClickHandler(event:Event):void{
			signalCancel.dispatch();
		}
		
		protected function okClickHandler(event:Event):void{
			signalOK.dispatch();
		}
	}
}
