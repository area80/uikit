package net.area80.uikit.component.facebook
{

	import com.facebook.graph.FacebookMobile;
	import com.facebook.graph.core.FacebookURLDefaults;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.LocationChangeEvent;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	
	import net.area80.facebook.FacebookMobileUser;
	import net.area80.uikit.AppDelegate;
	import net.area80.uikit.CGRect;
	import net.area80.uikit.UICalloutViewController;
	import net.area80.uikit.UIColor;
	import net.area80.uikit.UINavigationController;
	import net.area80.uikit.UIScreen;
	import net.area80.uikit.UITouchEvent;
	import net.area80.uikit.UIView;
	import net.area80.uikit.UIViewAutoresizing;
	import net.area80.uikit.UIViewController;

	[Event(name = "error", type = "net.area80.uikit.component.facebook.UIFacebookLoginErrorEvent")]
	[Event(name = "loginsuccess", type = "net.area80.uikit.component.facebook.UIFacebookLoginSuccessEvent")]

	public class UIFacebookLoginViewController extends UIViewController
	{

		protected var html:StageWebView;
		protected var successCallback:Function;
		protected var errorCallback:Function;
		protected var closedEvent:Event;
		protected var addToStageHTMLCallback:Function;
		protected var contentView:UIView;
		private var isInit:Boolean = false;
		
		private var navigationbar:UIFacebookNavigationbarView;

		/**
		 * You can just simply put callback to display the message when the popup is finish or add listener as the old fashioned way
		 * @param successCallback
		 * @param errorCallback
		 *
		 */
		public function UIFacebookLoginViewController(successCallback:Function = null, errorCallback:Function = null)
		{
			this.successCallback = successCallback;
			this.errorCallback = errorCallback;
		}
		
		public function checkCallbackIfNeedHTMLView(addToStageHTMLCallback:Function):void {
			initHTML();
			this.addToStageHTMLCallback = addToStageHTMLCallback;  
		}

		override public function viewDidAppear(animated:Boolean):void
		{
			initHTML();
			var w:int = UIScreen.applicationFrame.width * UIScreen.scale;
			var h:int = (UIScreen.applicationFrame.height - navigationbar.height) * UIScreen.scale;
			html.viewPort = new Rectangle(0, UIScreen.scale * navigationbar.height, w, h);
			
			contentView.uiHTMLView = html;
			
			contentView.setNeedsLayout();
			super.viewDidAppear(animated);
		}


		override protected function loadView():void
		{
			loadNavigationBar();
			
			navigationbar.cancelButton.touchResponder.addEventListener(UITouchEvent.TOUCH_TAB, cancelClickHandler);
			if(UIScreen.scale>1) {
				navigationbar.autoresizingMask = UIViewAutoresizing.NONE;
				navigationbar.frame = new CGRect(UIScreen.applicationFrame.width * UIScreen.scale,88);
				navigationbar.scaleX = navigationbar.scaleY = 1/UIScreen.scale;
			}
			
			view = new UIView().initWithFrame(UIScreen.applicationFrame.copy());
			view.autoresizingMask = UIViewAutoresizing.FLEXIBLE_HEIGHT | UIViewAutoresizing.FLEXIBLE_WIDTH;
			view.background = new UIColor().initWithColor(0xFFFFFF, UIScreen.applicationFrame);
			 
			contentView = new UIView().initWithFrame(UIScreen.applicationFrame.copy());
			contentView.autoresizingMask = UIViewAutoresizing.FLEXIBLE_HEIGHT | UIViewAutoresizing.FLEXIBLE_WIDTH | UIViewAutoresizing.FLEXIBLE_BOTTOM_MARGIN;
			contentView.autoresisingMarginTop = navigationbar.height;
			
			view.addChild(contentView);
			view.addChild(navigationbar);
		}
		protected function loadNavigationBar ():void {
			navigationbar = new UIFacebookNavigationbarView().initAsLoginbar();
		}

		protected function cancelClickHandler(event:Event):void
		{
			closedEvent = new UIFacebookLoginErrorEvent(UIFacebookLoginErrorEvent.ERROR, "User cancel.");
			closeView();
		}

		public function closeView():void
		{
			if (html) {
				try {
					html.removeEventListener(ErrorEvent.ERROR, htmlError);
					html.dispose();

				} catch (e:Error) {
				}
				html = null;
			}

			if(contentView && contentView.uiHTMLView) contentView.uiHTMLView = null;  
			if (navigationController && parentViewController && parentViewController is UINavigationController) {
				navigationController.popViewControllerAnimated(true);
			} else if (calloutViewController && parentViewController is UICalloutViewController) {
				calloutViewController.slideOff(this);
			} else {
				if (parentViewController) {
					removeFromParentViewController();
					viewDidDisappear(false);
				} else {
					checkCloseEvent();
				}
			}
		}

		protected function initHTML():void
		{
			if(isInit) return;
			
			isInit = true;
			
			html = new StageWebView();
			//view.uiHTMLView = html;
			
			//html.stage = AppDelegate.flashStage;

			
			if (FacebookMobileUser.isInitialize()) {
				processFacebookCall(); 
				html.addEventListener(ErrorEvent.ERROR, htmlError);
				html.addEventListener(LocationChangeEvent.LOCATION_CHANGE, onLocationChange);
			} else {
				closedEvent = new UIFacebookLoginErrorEvent(UIFacebookLoginErrorEvent.ERROR, "Facebook Mobile is not fully initialized.");
				closeView();
			}

		}
		protected function onLocationChange(e:LocationChangeEvent):void
		{
			var location:String = e.location;
			html.removeEventListener(LocationChangeEvent.LOCATION_CHANGE, onLocationChange);
			if (location.indexOf(FacebookURLDefaults.LOGIN_SUCCESS_URL) != 0 && location.indexOf(FacebookURLDefaults.LOGIN_SUCCESS_SECUREURL) != 0) {
				if(addToStageHTMLCallback is Function) {
					addToStageHTMLCallback();
					addToStageHTMLCallback = null;
				} 
 			}
			
		}
		protected function processFacebookCall():void
		{
			FacebookMobile.login(handleLoginCallback, AppDelegate.flashStage, FacebookMobileUser.getInstance().permissions, html);
		}

		protected function handleLoginCallback(cb:Object, cberror:Object):void
		{
			FacebookMobileUser.getInstance()._handleLoginCallback(cb, cberror);
			
			if (cb) {
				closedEvent = new UIFacebookLoginSuccessEvent(UIFacebookLoginSuccessEvent.LOGIN_SUCCESS, FacebookMobileUser.getInstance().getUser());
				closeView(); 
			} else {
				var reason:String = (cberror && typeof(cberror) != "string" && cberror["error_reason"]) ? cberror["error_reason"] : "Unknown error, please try again.";
				closedEvent = new UIFacebookLoginErrorEvent(UIFacebookLoginErrorEvent.ERROR, reason);
				closeView(); 
			}
		}

		override public function viewDidDisappear(animated:Boolean):void
		{

			dispatchEvent(closedEvent);
			checkCloseEvent();
			super.viewDidDisappear(animated);
		}
		protected function checkCloseEvent ():void {
			if (closedEvent is UIFacebookLoginSuccessEvent) {
				if (successCallback is Function) {
					successCallback(closedEvent);
				}
			} else if (closedEvent is UIFacebookLoginErrorEvent) {
				if (errorCallback is Function) {
					errorCallback(closedEvent);
				}
			}
			closedEvent = null;
			successCallback = null;
			errorCallback = null;
		}


		protected function htmlError(event:ErrorEvent):void
		{
			closedEvent = new UIFacebookLoginErrorEvent(UIFacebookLoginErrorEvent.ERROR, "HTML Error");
			closeView();
		}

	}
}
