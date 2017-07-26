package net.area80.uikit
{

	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.osflash.signals.Signal;
	
	import starling.core.RenderSupport;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class UIScrollView extends UIView
	{
		public static var START:String = 'start';
		public static var STOP:String = 'stop';
		public static var MOVE:String = 'move';

		public static var maxSpeed:Number = 100;
		public static var DELAY_SCROLL_FADE:Number = .4;
		public static var DELAY_MOVE_BACK:Number = .4;
		public static var deacceletion:Number = .5;

		private static var PADDING:Number = 4;
		private static var MAX_SCROLL_TO_ACTIVE:Number = 6;

		public var isLockScrollAxis:Boolean = false;
		//--

		private var isInit:Boolean = false;
		protected var _container:starling.display.Sprite
		private var _scrollSprite:starling.display.Sprite;
		private var _scrollStaticHeight:Number;

		private var magnitude:Number;

		private var maxScrollRatio:Number;
		private var _scrollOn:Boolean = false;
		private var _canMove:Boolean = false;

		//---- CONTAIN MOVE ---
		protected var isAllowMoveX:Boolean = true;
		protected var isAllowMoveY:Boolean = true;
		private var startMouseX:Number;
		private var startMouseY:Number;
		private var lastMouseY:Number;
		private var lastSpeed:Number = 0;
		private var speed:Number = 0;
		private var finalDestination:Number; // use only inertia function


		public var areaWidth:Number;
		public var areaHeight:Number;
		public var signalPage:Signal;


		/////// UPDATE //////

		//////  STARING /////
		private var mouseX:Number;
		private var mouseY:Number;
		private var mIsDown:Boolean = false;
		protected var isMoving:Boolean = false;
		private var renderRect:Rectangle = new Rectangle();

		public function UIScrollView()
		{
			super();
			_container = new starling.display.Sprite();
			signalPage = new Signal(String);
			super.addChildAt(_container, 0);
		}

		override public function initWithFrame(aRect:CGRect = null):UIView
		{
			areaWidth = aRect.width;
			areaHeight = aRect.height;
			magnitude = areaHeight;
			
			addEventListener(Event.ADDED_TO_STAGE, initialize);
			isInit = true;
			return super.initWithFrame(aRect);
		}

		private function initialize(e:Event):void
		{
			addEventListener(Event.REMOVED_FROM_STAGE, disposePage);

			getObjectTouchDown().addEventListener(TouchEvent.TOUCH, thisTouchEvent);

			if (!background) {
				var bg:UIColor = new UIColor();
				bg.initWithColor(0x000000, new CGRect(areaWidth, areaHeight));
				bg.alpha=0;
				background = bg;
			}
		}

		public function thisTouchEvent(e:TouchEvent):void
		{
			var touch:Touch = e.getTouch(getObjectTouchDown());
			if (touch==null)
				return;
			thisTouch(touch);

			setMousePoint(touch);
			if (touch.phase==TouchPhase.BEGAN&&!mIsDown) {
				var mp:Point = touch.getLocation(this);
				if ((mp.x>0&&mp.y>0&&mp.x<areaWidth&&mp.y<areaHeight)&&!mIsDown) {
					mIsDown = true;

					startMouseX = mouseX;
					startMouseY = mouseY;
					lastMouseY = startMouseY;
					removeEventListener(Event.ENTER_FRAME, inertia);
					TweenLite.killTweensOf(this);

					if (isMoving||!isLockScrollAxis) {
						md(touch);
					}
				}
			} else if (touch.phase==TouchPhase.MOVED&&mIsDown) {
				if (isLockScrollAxis&&!isMoving&&isAllowMoveY) {
					if (Math.abs(mouseY-startMouseY)>MAX_SCROLL_TO_ACTIVE) {
						md(touch);
						isAllowMoveX = false;
						deactiveMoveX();
					} else if (Math.abs(mouseX-startMouseX)>MAX_SCROLL_TO_ACTIVE) {
						isAllowMoveY = false;
						activeMoveX();
					}
				}
			} else if (touch.phase==TouchPhase.ENDED&&mIsDown) {
				if (mIsDown) {
					mu(e);
					mIsDown = false;
					isAllowMoveY = true;
					isAllowMoveX = true;
				}
			}

		}

		protected function md(touch:Touch):void
		{
			lastSpeed = speed = 0;
			signalPage.dispatch(START);
			moveContain();
			addEventListener(Event.ENTER_FRAME, moveContain);
		}

		protected function mu(event:TouchEvent):void
		{
			removeEventListener(Event.ENTER_FRAME, moveContain);
			if (position<areaHeight-magnitude) {
				tweenBackToFrame(areaHeight-magnitude);
			} else if (position>0) {
				tweenBackToFrame(0);
			} else {
				if (speed==0) {
					speed = lastSpeed;
				}
				speed *= 2;
				addEventListener(Event.ENTER_FRAME, inertia);
			}
		}

		/**
		 * This function will be called when move in x axis more than y
		 */
		protected function activeMoveX():void
		{

		}

		/**
		 * This function will be called when move in y axis more than x
		 */
		protected function deactiveMoveX():void
		{

		}


		protected function setMousePoint(touch:Touch):void
		{
			var p:Point = this.globalToLocal(new Point(touch.globalX, touch.globalY));
			mouseX = p.x;
			mouseY = p.y;
		}

		/**
		 * override this if you want to get touch
		 */
		protected function thisTouch(touch:Touch):void
		{
		}

		protected function getObjectTouchDown():DisplayObject
		{
			return this;
		}

		/**
		 *MOVING
		 */

		protected function moveContain(event:Event = null):void
		{
			if (!scrollOn) {
				if (startMouseY!=mouseY) {
					scrollOn = true;
				}
			}
			lastSpeed = speed;
			speed = mouseY-lastMouseY;
			if (position>0||position<areaHeight-magnitude) {
				position += speed/2;
			} else {
				position += speed;
			}
			position = Math.round(position);
			lastMouseY = mouseY;
			moving();
		}

		protected function moving():void
		{
			scrollSprite.y = (-container.y/maxScrollRatio)+PADDING;

			if (container.y<=areaHeight-magnitude) {
				scrollSprite.y += areaHeight-(container.y+magnitude);
				if (scrollSprite.y>areaHeight-Scruber.RADIUS*2-PADDING) {
					scrollSprite.y = areaHeight-Scruber.RADIUS*2-PADDING;
				}
				scrollSprite.height = areaHeight-scrollSprite.y-PADDING;
			} else if (container.y>0) {
				scrollSprite.height = _scrollStaticHeight-container.y;
				scrollSprite.y = PADDING>>0;
			} else {
				scrollSprite.height = _scrollStaticHeight;
			}
			signalPage.dispatch(MOVE);
			isMoving = true;

		}

		protected function inertia(event:Event):void
		{
			speed *= .9;
			position += speed;

			if (Math.abs(speed)<=deacceletion) {
				removeEventListener(Event.ENTER_FRAME, inertia);
				if (scrollOn)
					scrollOn = false;
				isMoving = false;
			} else {
				moving();
			}

			if (position<areaHeight-magnitude) {
				speed *= .5;
				if (speed<-maxSpeed)
					speed = -maxSpeed;
				finalDestination = ((speed/maxSpeed)*(areaHeight/2)-(magnitude-areaHeight));
				if (position<=finalDestination) {
					removeEventListener(Event.ENTER_FRAME, inertia);
					tweenBackToFrame(areaHeight-magnitude);
				}
			} else if (position>0) {
				speed *= .5;
				if (speed>maxSpeed)
					speed = maxSpeed;
				finalDestination = ((speed/maxSpeed)*areaHeight/2);
				if (position>=finalDestination) {
					removeEventListener(Event.ENTER_FRAME, inertia);
					tweenBackToFrame(0);
				}
			}

		}

		protected function tweenBackToFrame($value:Number):void
		{
			TweenLite.to(this, DELAY_MOVE_BACK, {position: $value, onUpdate: moving, ease: Strong.easeOut, onComplete: function():void
			{
				if (scrollOn)
					scrollOn = false;
				isMoving = false;
			}});
		}


		protected function moved():void
		{
			signalPage.dispatch(STOP);
		}

		public function set scrollOn($value:Boolean):void
		{
			if ($value) {
				TweenLite.to(scrollSprite, DELAY_SCROLL_FADE, {alpha: 1});
			} else {

				TweenLite.to(scrollSprite, DELAY_SCROLL_FADE, {alpha: 0, onComplete: moved});
			}
			_scrollOn = $value;
		}

		public function set position($value:Number):void
		{
			_container.y = $value;
		}


		public function set scrollSprite($object:starling.display.Sprite):void
		{
			if (_scrollSprite) {
				if (_scrollSprite.parent)
					_scrollSprite.parent.removeChild(_scrollSprite);
			}
			_scrollSprite = $object; 
			_scrollSprite.x = areaWidth-_scrollSprite.width-PADDING;
			_scrollSprite.y = PADDING;
			_scrollSprite.alpha = 0;
		}
		
		override protected function layoutSubviews():void
		{
			
			areaWidth = frame.width;
			areaHeight = frame.height;
			magnitude = areaHeight;
			super.layoutSubviews();
			
			updateContainer();
		}
		

		public function get scrollOn():Boolean
		{
			return _scrollOn;
		}

		public function get position():Number
		{
			return _container.y;
		}

		public function get container():DisplayObjectContainer
		{
			return _container;
		}

		public function get scrollSprite():starling.display.Sprite
		{
			if (!_scrollSprite) {
				scrollSprite = new Scruber();
				scrollSprite.height = areaHeight*areaHeight/magnitude;
				super.addChildAt(_scrollSprite, numChildren);
			}
			return _scrollSprite;
		}

		public function get canMove():Boolean
		{
			return _canMove;
		}

		/**
		 * DISPOSE
		 */

		public function stop():void
		{
			mIsDown = false;
			getObjectTouchDown().removeEventListener(TouchEvent.TOUCH, thisTouchEvent);

			removeEventListener(Event.ENTER_FRAME, inertia);
			removeEventListener(Event.ENTER_FRAME, moveContain);
			removeEventListener(Event.REMOVED_FROM_STAGE, disposePage);
		}

		protected function disposePage(event:Event):void
		{
			mIsDown = false;
			stop();
			removeEventListener(Event.ENTER_FRAME, inertia);
			removeEventListener(Event.ENTER_FRAME, moveContain);
		}

		public function wakeup():void
		{
			if (_container) {
				getObjectTouchDown().addEventListener(TouchEvent.TOUCH, thisTouchEvent);
			}
		}

		/************* CHILD ****************/

		public function addContent(child:DisplayObject):void
		{
			_container.addChild(child);
			setNeedsLayout();
		}

		public function addContentAt(child:DisplayObject, index:int):void
		{
			_container.addChildAt(child, index);
			setNeedsLayout();
		}

		public function removeContent(child:DisplayObject, dispose:Boolean = false):void
		{
			_container.removeChild(child, dispose);
			setNeedsLayout();
		}

		public function removeContentAt(index:int, dispose:Boolean = false):void
		{
			_container.removeChildAt(index, dispose);
			setNeedsLayout();
		}

		public function getContentIndex(child:DisplayObject):Number
		{
			return _container.getChildIndex(child);
		}

		public function setContentIndex(child:DisplayObject, index:int):void
		{
			_container.setChildIndex(child, index);
		}

		public function getContentAt(index:int):DisplayObject
		{
			return _container.getChildAt(index);
		}

		public function get numContents():int
		{
			return _container.numChildren;
		}

		/*****************************/
		/**********UPDATE************/
		/*****************************/
		

		public function updateContainer():void
		{
			if (isInit) {
				var contentHeight:Number = getMagnitude();
				if (contentHeight>areaHeight) {
					magnitude = contentHeight;
					scrollSprite.visible = true;
					_canMove = true;
				} else {
					magnitude = areaHeight;
					scrollSprite.visible = false;
					_canMove = false;
				}
				_scrollStaticHeight = (areaHeight-PADDING-PADDING)*areaHeight/magnitude;
				scrollSprite.height = _scrollStaticHeight;
				maxScrollRatio = (contentHeight-areaHeight)/(areaHeight-scrollSprite.height-PADDING*2);
				setNeedsLayout();
				
			}
		}

		protected function getMagnitude():Number
		{
			var rect:Rectangle = container.getBounds(container);
			return rect.y+rect.height+20;
		}

		override public function render(support:RenderSupport, alpha:Number):void
		{
			super.render(support, alpha);
		}
	}
}
import net.area80.uikit.UIDefaultAssetManager;

import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;

class Scruber extends Sprite
{
	public static const RADIUS:Number = 5;
	private static const COLOR:Number = 0xaaaaaa;

	private var _height:Number = 0;

	private var topScr:Image;
	private var middleScr:Quad;
	private var bottomScr:Image;

	public function Scruber():void
	{
		topScr = new Image(UIDefaultAssetManager.topScrubber);
		middleScr = new Quad(RADIUS*2, RADIUS*2, 0x000000);
		middleScr.alpha = .5;
		bottomScr = new Image(UIDefaultAssetManager.bottomScrubber);
		middleScr.y = RADIUS;
		topScr.y = 0;

		addChild(topScr);
		addChild(middleScr);
		addChild(bottomScr);

	}

	public override function set height(value:Number):void
	{
		if (value<=RADIUS*2) {
			middleScr.height = 1;
			bottomScr.y = RADIUS;
			middleScr.visible = false;
		} else {
			middleScr.visible = true;
			middleScr.height = value-RADIUS*2;
			bottomScr.y = value-RADIUS;
		}
		_height = value;
	}

	public override function get height():Number
	{
		return _height;
	}
}
