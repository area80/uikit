package net.area80.uikit
{

	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import starling.core.RenderSupport;
	import starling.display.DisplayObject;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class UIViewHelper
	{
		public static function processAutoresizeSubview(view:UIView, childView:UIView):void
		{

			if ((childView.autoresizingMask & UIViewAutoresizing.NONE) == 0) {
				var ftm:Boolean = (childView.autoresizingMask & UIViewAutoresizing.FLEXIBLE_TOP_MARGIN) > 0;
				var fbm:Boolean = (childView.autoresizingMask & UIViewAutoresizing.FLEXIBLE_BOTTOM_MARGIN) > 0;
				var fh:Boolean = (childView.autoresizingMask & UIViewAutoresizing.FLEXIBLE_HEIGHT) > 0;
				var flm:Boolean = (childView.autoresizingMask & UIViewAutoresizing.FLEXIBLE_LEFT_MARGIN) > 0;
				var frm:Boolean = (childView.autoresizingMask & UIViewAutoresizing.FLEXIBLE_RIGHT_MARGIN) > 0;
				var fw:Boolean = (childView.autoresizingMask & UIViewAutoresizing.FLEXIBLE_WIDTH) > 0;

				var b:Number = childView.autoresisingMarginBottom;
				var r:Number = childView.autoresisingMarginRight;
				var l:Number = childView.autoresisingMarginLeft;
				var t:Number = childView.autoresisingMarginTop;

				var newFrameHeight:Number = childView.frame.height;
				var newFrameWidth:Number = childView.frame.width;

				if (fh || ftm || fbm)
					childView.y = t;
				if (fw || flm || frm)
					childView.x = l;

				//vertical
				if (fh) {
					if (ftm && fbm) {
						newFrameHeight = view.frame.height - (b + t);
					} else if (ftm) {
						newFrameHeight = view.frame.height - b;
						childView.y = 0;
					} else if (fbm) {
						newFrameHeight = view.frame.height - t;
					} else {
						newFrameHeight = view.frame.height - (t + b);
					}
				} else if (ftm && fbm) {
					childView.y = t + Math.round(((view.frame.height - (t + b)) - childView.height) >> 1);
				} else if (ftm) {
					childView.y = view.frame.height - (childView.height + b);
				} else if (fbm) {
					childView.y = t;
				}

				//horizontal
				if (fw) {
					if (flm && frm) {
						newFrameWidth = view.frame.width - (r + l);
					} else if (flm) {
						newFrameWidth = view.frame.width - r;
						childView.x = 0;
					} else if (frm) {
						newFrameWidth = view.frame.width - l;
					} else {
						newFrameWidth = view.frame.width - (l + r);
					}

				} else if (flm && frm) {
					childView.x = l + Math.round(((view.frame.width - (l + r)) - childView.width) >> 1);
				} else if (flm) {
					childView.x = view.frame.width - (childView.width + r);
				} else if (frm) {
					childView.x = l;
				}

				childView.frame = new CGRect(newFrameWidth, newFrameHeight);

			}
		}
		
		public static function syncTransformToDisplayObject(support:RenderSupport, alpha:Number, flashObject:flash.display.DisplayObject):void
		{
			flashObject.transform.matrix = support.modelViewMatrix; 
			flashObject.alpha = alpha;
		} 

		public static function processTouch(view:starling.display.DisplayObject, touchResponder:UITouchResponder, withEvent:TouchEvent):void
		{
			var touchPoint:Point
			var touch:Touch;
			
			touch = withEvent.getTouch(view);
			if(!touch) return;
			
			touchPoint = touch.getLocation(view); 
			 
			if (withEvent.interactsWith(view)) {
				
				if (touch.phase== TouchPhase.BEGAN) {
					
//					if (touchPoint.x > 0 && touchPoint.y > 0 && touchPoint.x < view.width && touchPoint.y < view.height) {	
					if (view.hitTest(touchPoint)) {	
						touchResponder.touchStart.x = touchPoint.x;
						touchResponder.touchStart.y = touchPoint.y;
						touchResponder.touchesBegin = true;
						touchResponder.tabCancel = false;
						touchResponder.touchesOut = false;
						touchResponder.dispatchEvent(new UITouchEvent(UITouchEvent.TOUCH_BEGAN, withEvent,touchPoint.x,touchPoint.y, touch.globalX, touch.globalY));
					}

				} else if (touchResponder.touchesBegin && touch.phase== TouchPhase.MOVED) {

					if(!touchResponder.tabCancel && Math.abs(Point.distance(touchPoint,touchResponder.touchStart))>UIScreen.scale*touchResponder.pixelDistanceBeforeCancelTouchTabCancel) {
							touchResponder.tabCancel = true;
							touchResponder.dispatchEvent(new UITouchEvent(UITouchEvent.TOUCH_TAB_CANCEL, withEvent,touchPoint.x,touchPoint.y, touch.globalX, touch.globalY));
					}
					
					//if ( touchPoint.x > 0 && touchPoint.y > 0 && touchPoint.x < view.width && touchPoint.y < view.height) {	
					if (view.hitTest(touchPoint) ) {	
						touchResponder.touchesOut = false;
						touchResponder.dispatchEvent(new UITouchEvent(UITouchEvent.TOUCH_MOVE_INSIDE, withEvent,touchPoint.x,touchPoint.y, touch.globalX, touch.globalY));

					} else {
						if (!touchResponder.touchesOut) {
							touchResponder.touchesOut = true;
							touchResponder.dispatchEvent(new UITouchEvent(UITouchEvent.TOUCH_OUT, withEvent,touchPoint.x,touchPoint.y, touch.globalX, touch.globalY));
						}
						touchResponder.dispatchEvent(new UITouchEvent(UITouchEvent.TOUCH_MOVE_OUTSIDE, withEvent,touchPoint.x,touchPoint.y, touch.globalX, touch.globalY));
					}
					touchResponder.dispatchEvent(new UITouchEvent(UITouchEvent.TOUCH_MOVE, withEvent,touchPoint.x,touchPoint.y, touch.globalX, touch.globalY));

				} else if (touchResponder.touchesBegin && touch.phase == TouchPhase.HOVER) {
					if (touchResponder.touchesOut) {
						touchResponder.touchesOut = false;
						touchResponder.dispatchEvent(new UITouchEvent(UITouchEvent.TOUCH_BACKIN, withEvent,touchPoint.x,touchPoint.y, touch.globalX, touch.globalY));
					}
					touchResponder.dispatchEvent(new UITouchEvent(UITouchEvent.TOUCH_HOVER, withEvent,touchPoint.x,touchPoint.y, touch.globalX, touch.globalY));
				}
			} else {
				if (touchResponder.touchesBegin && touch.phase == TouchPhase.ENDED) {
					
					touchResponder.touchesBegin = false;
					
//					if (touchPoint.x > 0 && touchPoint.y > 0 && touchPoint.x < view.width && touchPoint.y < view.height) {	
					if (view.hitTest(touchPoint)) {	
						touchResponder.dispatchEvent(new UITouchEvent(UITouchEvent.TOUCH_END_INSIDE, withEvent,touchPoint.x,touchPoint.y, touch.globalX, touch.globalY));
						if(!touchResponder.tabCancel) {
							touchResponder.dispatchEvent(new UITouchEvent(UITouchEvent.TOUCH_TAB, withEvent,touchPoint.x,touchPoint.y, touch.globalX, touch.globalY));
						}
					} else {
						touchResponder.dispatchEvent(new UITouchEvent(UITouchEvent.TOUCH_END_OUTSIDE, withEvent,touchPoint.x,touchPoint.y, touch.globalX, touch.globalY));
					}
					touchResponder.dispatchEvent(new UITouchEvent(UITouchEvent.TOUCH_END, withEvent,touchPoint.x,touchPoint.y, touch.globalX, touch.globalY));
				}

			}
		}
	}
}
