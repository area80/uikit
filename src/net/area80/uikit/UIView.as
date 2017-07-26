package net.area80.uikit
{

	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.events.TouchEvent;



	/**
	 * You need to use initWithFrame first or it's size will be zero. Its purpose is to use iOS style layout with UIViewController compatible. Otherwise, use Starling Display for better performance instead.
	 * @author wissarut
	 *
	 */
	public class UIView extends Sprite
	{


		protected var _touchResponder:UITouchResponder;

		public function get touchResponder():UITouchResponder
		{
			return _touchResponder;
		}

		private var _clipsToBounds:Boolean = false;

		/**
		 * Provides automatic layout behavior when the parentView’s frame changes.
		 * @see UIViewAutoresizing
		 */
		public var autoresizingMask:uint = UIViewAutoresizing.NONE;

		private var _background:UIColor;
		private var _frame:CGRect = new CGRect(0, 0);
		private var _window:UIWindow;
		private var _needLayout:Boolean;
		private var _autoresizingMargins:Array = [0, 0, 0, 0];
		private var renderRect:Rectangle = new Rectangle(0, 0, 0, 0);
		private var _cacheMatrix:Matrix3D = new Matrix3D();

		private var _ui2dview:UIView2D;
		private var _uiHTMLview:StageWebView;


		public function UIView()
		{
			_touchResponder = new UITouchResponder();
			touchable = true;
		}

		public function set touchResponderEnabled(value:Boolean):void
		{
			if (value) {

				addEventListener(TouchEvent.TOUCH, touchHandle);
				_touchResponder.dispatchEvent(new UITouchEvent(UITouchEvent.READY));
				
			} else {
				
				removeEventListener(TouchEvent.TOUCH, touchHandle);
				_touchResponder.dispatchEvent(new UITouchEvent(UITouchEvent.CANCEL));
			}
		}
		public function get uiHTMLView():StageWebView
		{
			return _uiHTMLview;
		}
		
		public function set uiHTMLView(value:StageWebView):void
		{
			_uiHTMLview = value;
			
		}
		public function get ui2dview():UIView2D
		{
			return _ui2dview;
		}

		public function set ui2dview(value:UIView2D):void
		{
			if (_ui2dview&&_ui2dview==value)
				return;
			if (_ui2dview) {
				_ui2dview.parent.removeChild(value);
			}
			_ui2dview = value;
			if (_ui2dview&&window) {
				window.stage2d.addChild(_ui2dview);
			}

		}

		/**
		 * A Boolean value that determines whether subviews are confined(masked) to the frame.
		 */
		public function get clipsToBounds():Boolean
		{
			return _clipsToBounds;
		}

		/**
		 * @private
		 */
		public function set clipsToBounds(value:Boolean):void
		{
			_clipsToBounds = value;
		}

		public function get window():UIWindow
		{
			return _window;
		}

		public function get frame():CGRect
		{
			return _frame;
		}
		
		override public function set scaleX(value:Number):void
		{
			if(value!=scaleX) setNeedsLayout();
			super.scaleX = value;
		}
		
		override public function set scaleY(value:Number):void
		{
			if(value!=scaleY) setNeedsLayout();
			super.scaleY = value;
		}

		override public function get width():Number
		{
			return _frame.width*scaleX;
		}

		override public function set width(value:Number):void
		{
			frame = new CGRect(value, frame.height);
		}

		override public function get height():Number
		{
			return _frame.height*scaleY;
		}

		override public function set height(value:Number):void
		{
			frame = new CGRect(frame.width, value);
		}

		/**
		 * The frame rectangle, which describes the view’s size in its parent view’s coordinate system.
		 * @param aRect
		 *
		 */
		public function set frame(aRect:CGRect):void
		{
			if (_frame&&(_frame.width==aRect.width&&_frame.height==aRect.height)) {
				return;
			}

			_frame = aRect;

			//check if size is validate
			sizeThatFits();
			setNeedsLayout();

		}


		/**
		 * Array of autoResizing margins [t,r,b,l], if <code>autoresizingMask</code> is set this will override x y property of your view when rendered.
		 * @param Array or Number of autoResizing margins [t,r,b,l], if <code>autoresizingMask</code> is set this will override x y property of your view when rendered.
		 */
		public function set autoresizingMargins(value:*):void
		{
			var t:uint, r:uint, b:uint, l:uint;
			if (value is Array||value is Vector) {
				t = (value[0])?value[0]:0;
				r = (value[1])?value[0]:0;
				b = (value[2])?value[0]:0;
				l = (value[3])?value[0]:0;
			} else if (!isNaN(value)) {
				t = value;
				r = value;
				b = value;
				l = value;
			} else {
				t = 0;
				r = 0;
				b = 0;
				l = 0;
			}
			_autoresizingMargins = [t, r, b, l];
			setNeedsLayout();
		}

		public function get autoresizingMargins():Array
		{
			return _autoresizingMargins;
		}

		public function set autoresisingMarginTop(value:Number):void
		{
			_autoresizingMargins[0] = value;
			setNeedsLayout();
		}

		public function get autoresisingMarginTop():Number
		{
			return (_autoresizingMargins[0])?_autoresizingMargins[0]:0;
		}

		public function set autoresisingMarginRight(value:Number):void
		{
			_autoresizingMargins[1] = value;
			setNeedsLayout();
		}

		public function get autoresisingMarginRight():Number
		{
			return (_autoresizingMargins[1])?_autoresizingMargins[1]:0;
		}

		public function set autoresisingMarginBottom(value:Number):void
		{
			_autoresizingMargins[2] = value;
			setNeedsLayout();
		}

		public function get autoresisingMarginBottom():Number
		{
			return (_autoresizingMargins[2])?_autoresizingMargins[2]:0;
		}

		public function set autoresisingMarginLeft(value:Number):void
		{
			_autoresizingMargins[3] = value;
			setNeedsLayout();
		}

		public function get autoresisingMarginLeft():Number
		{
			return (_autoresizingMargins[3])?_autoresizingMargins[3]:0;
		}


		/**
		 * Initializes and returns a newly allocated view object with the specified frame rectangle.
		 *
		 * <p><b>Discussion</b></p>
		 *
		 * The new view object must be inserted into the view hierarchy of a window before it can be used. If you create a view object programmatically, this method is the designated initializer for the UIView class. Subclasses can override this method to perform any custom initialization but must call super at the beginning of their implementation.
		 *
		 * @param aRect The frame rectangle for the view, measured in points. The origin of the frame is relative to the superview in which you plan to add it. This method uses the frame rectangle to set the center and bounds properties accordingly.
		 * @return An initialized view object or null if the object couldn't be created.
		 *
		 */
		public function initWithFrame(aRect:CGRect = null):UIView
		{
			if (aRect==null)
				aRect = new CGRect(super.width,super.height);
			frame = aRect;
			return this;
		}


		/**
		 * The default value is null, which results in a transparent
		 * @param bg UIColor which can be solid color or texture
		 */
		public function set background(bg:UIColor):void
		{
			if (_background) {
				removeChild(_background);
			}
			_background = bg;

			if (_background) {
				addChildAt(_background, 0);
			}
		}

		/**
		 * The default value is null, which results in a transparent
		 * @return <code>UIColor</code> which can be solid color or texture
		 */
		public function get background():UIColor
		{
			return _background;
		}

		/**
		 * This will autometacally called by <code>UIViewController</code> to destroy current object and its subviews, only if subview is UIView
		 */
		public function destroy():void
		{
			this.dispose();
		}

	
		/**
		 * Invalidates the current layout of the receiver and triggers a layout update during the next update cycle.
		 *
		 * <p><b>Discussion</b></p>
		 *
		 * Call this method on your application’s main thread when you want to adjust the layout of a view’s childrens. This method makes a note of the request and returns immediately. Because this method does not force an immediate update, but instead waits for the next update cycle, you can use it to invalidate the layout of multiple views before any of those views are updated. This behavior allows you to consolidate all of your layout updates to one update cycle, which is usually better for performance.
		 */
		public function setNeedsLayout():void
		{

			_needLayout = true;
			if (parent&&parent is UIView)
				UIView(parent)._needLayout = true;
		}


		/**
		 * Lays out the children immediately.
		 *
		 * <p><b>Discussion</b></p>
		 *
		 * Use this method to force the layout of children before drawing. Starting with the receiver, this method traverses upward through the view hierarchy as long as superviews require layout. Then it lays out the entire tree beneath that ancestor. Therefore, calling this method can potentially force the layout of your entire view hierarchy.
		 */
		public function layoutIfNeeded():void
		{
			if (_needLayout) {
				layoutSubviews();
				_needLayout = false;
			}

		}


		// =================================================================================================
		//
		// Implement these functions to get notify when view's state is changing
		//
		// =================================================================================================


		/**
		 * Indicates when this view is added to parent, but it's not necessary to have window.
		 */
		protected function didMoveToParent():void
		{

		}

		/**
		 * Indicates when this view is removed from its parent, but it's not necessary to be removed from window yet.
		 */
		protected function didRemoveFromParent():void
		{

		}

		/**
		 * Indicates when this view is added to window.
		 */
		protected function didMoveToWindow():void
		{
			if (_ui2dview&&!_ui2dview.parent)
				window.stage2d.addChild(_ui2dview);
		}

		/**
		 * Indicates when this view is removed from window.
		 */
		protected function didRemoveFromWindow():void
		{
			if (_ui2dview&&_ui2dview.parent)
				_ui2dview.parent.removeChild(_ui2dview);
		}

		/**
		 *  Indicates when this view is about to animated.
		 */
		protected function transitionWillStart():void
		{

		}

		/**
		 *  Indicates when this view is finish animating.
		 */
		protected function transitionDidEnd():void
		{

		}


		/**
		 * <p>Lays out subviews.</p>
		 *
		 * <p><b>Discussion</b></p>
		 *
		 * <p>Subclasses can override this method as needed to perform more precise layout of their subviews. You should override this method only if the autoresizing behaviors of the subviews do not offer the behavior you want. You can use your implementation to set the frame rectangles of your subviews directly.</p>
		 *
		 * <p>You should not call this method directly. If you want to force a layout update, call the <code>setNeedsLayout</code> method instead to do so prior to the next drawing update. If you want to update the layout of your views immediately, call the <code>layoutIfNeeded</code> method.</p>
		 *
		 */
		protected function layoutSubviews():void
		{

			for (var i:int = 0; i<numChildren; i++) {
				if (getChildAt(int(i)) is UIView) {
					uikitAutoresizeSubview(getChildAt(int(i)) as UIView);
				}
			}
			if (_background) {
				_background.width = frame.width;
				_background.height = frame.height;
			}

		}

		/**
		 * Implement this method if you want your view to have a different default size than it normally would during resizing operations. For example, you might use this method to prevent your view from shrinking to the point where subviews cannot be displayed correctly.
		 */
		protected function sizeThatFits():void
		{

		}


		// =================================================================================================
		//
		// Overriding
		//
		// =================================================================================================

		/** @inheritDoc */
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			super.addChildAt(child, index);
			if (child is UIView) {
				UIView(child).didMoveToParent();
				UIView(child).setWindow((stage) ? AppDelegate.window : null);
			}
			
			return child;
		}

		/** @inheritDoc */
		override public function removeChildAt(index:int, dispose:Boolean = false):DisplayObject
		{
			var child:DisplayObject = getChildAt(index);
			super.removeChildAt(index, dispose);
			if (child&&child is UIView) {
				UIView(child).didRemoveFromParent();
				UIView(child).setWindow((stage) ? AppDelegate.window : null);
			}
			
			return child;
		}

		/** @inheritDoc */
		override public function dispose():void
		{
			if(_touchResponder) {
				_touchResponder.removeAllListeners();
				_touchResponder = null;
			}

			if (background) {
				background.dispose();
				background = null;
			}
			ui2dview = null;
			
			if(_uiHTMLview) {
				try {
					_uiHTMLview.dispose();
					
				} catch (e:Error) {
				}
				_uiHTMLview = null;
			}
			
			//remove them yourself
			/*if (controller) {
				for (var i:int = 0; i<numChildren; i++) {
					var child:DisplayObject = getChildAt(int(i)).dispose();
					child.dispose();

				}
			}*/

			super.dispose();
		}

		/** @inheritDoc */
		override public function render(support:RenderSupport, alpha:Number):void
		{
			layoutIfNeeded();

			if (ui2dview) {
				UIViewHelper.syncTransformToDisplayObject(support, alpha, ui2dview);
				ui2dview.updateIndexing();
			}
			if(_clipsToBounds || _uiHTMLview) {
				renderRect.x = support.modelViewMatrix.tx;
				renderRect.y = support.modelViewMatrix.ty;
				renderRect.width = support.modelViewMatrix.a*frame.width;
				renderRect.height = support.modelViewMatrix.d*frame.height;
			} 
			if( _uiHTMLview) {
				try {
				if(_uiHTMLview.viewPort &&    
					(_uiHTMLview.viewPort.x != renderRect.x || 
					_uiHTMLview.viewPort.y != renderRect.y || 
					_uiHTMLview.viewPort.width != renderRect.width || 
					_uiHTMLview.viewPort.height != renderRect.height)
				) { 
					_uiHTMLview.viewPort = renderRect.clone(); 
				}
				} catch (e:Error){}
			}
			if (_clipsToBounds) {
				support.finishQuadBatch();
				Starling.context.setScissorRectangle(renderRect);
				super.render(support, alpha); 
				support.finishQuadBatch();
				Starling.context.setScissorRectangle(null);
			} else {
				super.render(support, alpha);
			}


		}


		// =================================================================================================
		//
		// Internal used by UIKit only.
		//
		// =================================================================================================

		private function uikitAutoresizeSubview(childView:UIView):void
		{
			UIViewHelper.processAutoresizeSubview(this, childView); 
		}


		private function touchHandle(withEvent:TouchEvent):void
		{
			UIViewHelper.processTouch(this, touchResponder, withEvent);
		}

		/**
		 * @internal
		 */
		internal function setWindow(value:UIWindow):void
		{
			if(value == _window) return;
			_window = value;
			
			if (value) {
				didMoveToWindow();
			} else {
				didRemoveFromWindow();
			}

			for (var i:int = 0; i<numChildren; i++) {
				if (getChildAt(i) is UIView) {
					var childView:UIView = getChildAt(int(i)) as UIView;
					childView.setWindow(value);
				}
			}
		}

		
		
	}
}
