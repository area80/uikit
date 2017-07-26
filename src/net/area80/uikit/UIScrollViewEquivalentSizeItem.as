package net.area80.uikit
{
	import flash.geom.Point;
	
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.events.Touch;
	import starling.events.TouchPhase;

	public class UIScrollViewEquivalentSizeItem extends UIScrollView
	{
		private const MOVE_DISTANCE:Number = 8;

		protected var childs:Vector.<DisplayObject> = new Vector.<DisplayObject>();
		protected var itemHeight:Number;
		private var lastStartIndex:Number = -1;
		private var lastEndIndex:Number = -1;
		private var _contentHeight:Number = 0;

		protected var mIsDown:Boolean = false;
		protected var isMoved:Boolean = false;
		private var startMouseDownPoint:Point;
		private var nowDownItem:IScrollViewEquivalentSizeItem;

		protected var bg:Quad;

		public function UIScrollViewEquivalentSizeItem(_itemHeight:Number)
		{
			super();
			itemHeight = _itemHeight;
		}

		override public function initWithFrame(aRect:CGRect = null):UIView
		{
			bg = new Quad(aRect.width, aRect.height, 0);
			bg.alpha = 0;
			addChild(bg);
			_container.touchable = false;
			return super.initWithFrame(aRect);
		}

		override public function addContent(child:DisplayObject):void
		{
			IScrollViewEquivalentSizeItem(child).blur();
			child.y = childs.length*itemHeight;
			childs.push(child);
			_contentHeight = (childs.length)*itemHeight;
			super.addContent(child);
		}

		override public function addContentAt(child:DisplayObject, index:int):void
		{
			IScrollViewEquivalentSizeItem(child).blur();
			childs.splice(index, -1, child);
			alignItem(index);
			_contentHeight = (childs.length)*itemHeight;
			super.addContentAt(child, index);
		}

		override public function removeContent(child:DisplayObject, dispose:Boolean = false):void
		{
			var childIndex:Number = childs.indexOf(child);
			trace("remove index::", childIndex);
			if (childIndex!=-1) {
				removeContentAt(childIndex, dispose);
			}
		}

		override public function removeContentAt(index:int, dispose:Boolean = false):void
		{
			var child:DisplayObject = childs.splice(index, 1)[0];
			IScrollViewEquivalentSizeItem(child).blur();
			alignItem(index);
			_contentHeight = (childs.length)*itemHeight;
			super.removeContentAt(index, dispose);
		}

		override public function setContentIndex(child:DisplayObject, index:int):void
		{
			var oldIndex:int = getChildIndex(child);
			if (oldIndex==-1)
				throw new ArgumentError("Not a child of this container");
			childs.splice(oldIndex, 1);
			childs.splice(index, 0, child);
			childs[oldIndex].y = oldIndex*itemHeight;
			childs[index].y = index*itemHeight;
			super.setContentIndex(child, index);
		}

		override protected function thisTouch(touch:Touch):void
		{
			if (touch.phase==TouchPhase.BEGAN&&!mIsDown&&!isMoving) {
				isMoved = false;
				mIsDown = true;
				startMouseDownPoint = new Point(touch.globalX, touch.globalY);
				var item:DisplayObject = getItem(touch);
				nowDownItem = IScrollViewEquivalentSizeItem(item);
				mouseDownItem(item);
			} else if (touch.phase==TouchPhase.MOVED&&mIsDown) {
				if (Math.abs(touch.globalY-startMouseDownPoint.y)>MOVE_DISTANCE&&!isMoved) {
					isMoved = true;
					mouseUp();
					nowDownItem = null;
				}
			} else if (touch.phase==TouchPhase.ENDED) {
				isMoved = false;
				mIsDown = false;
				mouseUp();
				if (!isMoved&&nowDownItem) {
					click();
				}
			}
		}

		override protected function moving():void
		{
			focusItemInArea();
			super.moving();
		}

		override public function updateContainer():void
		{
			focusItemInArea();
			super.updateContainer();
		}

		override protected function getMagnitude():Number
		{
			return _contentHeight;
		}

		/**
		 * use this function to change quad to touch obj
		 */
		override protected function getObjectTouchDown():DisplayObject
		{
			return bg;
		}

		private function alignItem(_startIndex:Number):void
		{
			for (var i:uint = _startIndex; i<=childs.length-1; i++) {
				childs[i].y = i*itemHeight;
			}
		}

		protected function mouseDownItem(_item:DisplayObject):void
		{
			if (_item)
				IScrollViewEquivalentSizeItem(_item).mouseDown();
		}

		protected function mouseUp():void
		{
			if (nowDownItem)
				nowDownItem.mouseUp();
		}

		protected function click():void
		{
			if (nowDownItem)
				nowDownItem.click();
		}

		protected function getItem(touch:Touch):DisplayObject
		{
			var _y:Number = globalToLocal(new Point(0, touch.globalY)).y-_container.y;
			var index:Number = (_y/itemHeight)>>0;
			if (index<0||index>childs.length-1)
				return null;
			return childs[index];
		}

		public function removeAllContent():void
		{
			for (var i:uint = 0; i<=childs.length-1; i++) {
				IScrollViewEquivalentSizeItem(childs[i]).blur();
				super.removeContent(childs[i]);
			}
			childs = new Vector.<DisplayObject>()
			lastStartIndex = -1;
			lastEndIndex = -1;
			container.y = 0;
			_contentHeight = 0;
			updateContainer();
		}

		private function focusItemInArea():void
		{

			if (childs.length>0) {
				var i:uint;
				var startIndex:Number = (-_container.y/itemHeight)>>0;
				var endIndex:Number = (((-_container.y+frame.height)/itemHeight)>>0)+1;

				if (startIndex<0) {
					startIndex = 0;
				} else if (startIndex>childs.length-1) {
					startIndex = childs.length-1;
				}
				if (endIndex<0) {
					endIndex = 0;
				} else if (endIndex>childs.length-1) {
					endIndex = childs.length-1;
				}

				if (lastStartIndex==-1&&lastEndIndex==-1) {
					for (i = startIndex; i<=endIndex; i++) {
						IScrollViewEquivalentSizeItem(childs[i]).focus();
					}
				} else {
					if (startIndex>lastStartIndex) {
						for (i = lastStartIndex; i<startIndex; i++) {
							IScrollViewEquivalentSizeItem(childs[i]).blur();
						}
					} else if (startIndex<lastStartIndex) {
						for (i = startIndex; i<lastStartIndex; i++) {
							IScrollViewEquivalentSizeItem(childs[i]).focus();
						}
					}

					if (endIndex>lastEndIndex) {
						for (i = lastEndIndex; i<=endIndex; i++) {
							IScrollViewEquivalentSizeItem(childs[i]).focus();
						}
					} else if (endIndex<lastEndIndex) {
						for (i = endIndex; i<lastEndIndex; i++) {
							IScrollViewEquivalentSizeItem(childs[i]).blur();
						}
					}
				}
				lastStartIndex = startIndex;
				lastEndIndex = endIndex;
			}
		}
	}
}
