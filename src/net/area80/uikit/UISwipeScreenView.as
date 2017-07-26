package net.area80.uikit
{
	import flash.display.BitmapData;
	import flash.display.Sprite;

	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.textures.Texture;

	public class UISwipeScreenView extends UIView
	{

		public var pagnitionUIView:UIView;
		private var containerPageUIView:UIView;
		private const PAGNITION_WIDTH:Number = 10;
		//pagnition
		private var pagnitionBitmapData:BitmapData;
		private var _currentPageIcon:Image;
		private var pagnitionIcons:Vector.<Image> = new Vector.<Image>();
		//
		private var _bg:DisplayObject;
		private var _currentPage:uint;

		public function UISwipeScreenView()
		{
			super();
		}

		public function addPageIcon():void
		{
			var icon:Image = pagnitionIcon;
			pagnitionUIView.addChild(icon);
			pagnitionIcons.push(icon);

			for (var i:uint = 0; i<=pagnitionIcons.length-1; i++) {
				pagnitionIcons[i].x = i*PAGNITION_WIDTH*2;
			}

			if (pagnitionIcons.length>0) {
				pagnitionUIView.frame = new CGRect((pagnitionIcons.length)*2*PAGNITION_WIDTH-PAGNITION_WIDTH, PAGNITION_WIDTH);
			} else {
				pagnitionUIView.frame = new CGRect(10, 10);
			}

			//add first icon
			pagnitionUIView.setChildIndex(currentPageIcon, pagnitionUIView.numChildren);
		}

		public function removePageIcon():void
		{
			if (pagnitionIcons.length>0) {
				pagnitionIcons.pop();
				pagnitionUIView.frame = new CGRect((pagnitionIcons.length)*2*PAGNITION_WIDTH-PAGNITION_WIDTH, PAGNITION_WIDTH);
			} else {
				pagnitionUIView.frame = new CGRect(10, 10);
			}
		}

		public function set currentPage(page:uint):void
		{
			_currentPage = page;
			currentPageIcon.x = pagnitionIcons[page].x;
			pagnitionUIView.setChildIndex(currentPageIcon, pagnitionUIView.numChildren);
		}

		public function set bg(_bg:DisplayObject):void
		{
			if (this._bg) {
				var childIndex:int = getChildIndex(this._bg);
				super.removeChildAt(childIndex, true);
			}
			super.addChildAt(_bg, 0);
			this._bg = _bg;
		}

		public function get bg():DisplayObject
		{
			return _bg;
		}

		/**************************
		 * override
		 ************************/

		override public function initWithFrame(aRect:CGRect = null):UIView
		{
			pagnitionUIView = new UIView().initWithFrame(new CGRect(10, 10));
			super.addChildAt(pagnitionUIView, 0);
			containerPageUIView = new UIView().initWithFrame(aRect.copy());
			super.addChildAt(containerPageUIView, 0);
			pagnitionUIView.autoresizingMask = UIViewAutoresizing.FLEXIBLE_LEFT_MARGIN|UIViewAutoresizing.FLEXIBLE_RIGHT_MARGIN;

			if (!_bg) {
				_bg = new Quad(aRect.width, aRect.height, 0x000000);
				_bg.alpha = 0;
				super.addChildAt(_bg, 0);
			}

			return super.initWithFrame(aRect);
		}

		override public function set frame(aRect:CGRect):void
		{
			containerPageUIView.frame = aRect;
			super.frame = aRect;
		}

		override public function addChild(child:DisplayObject):DisplayObject
		{
			return containerPageUIView.addChildAt(child, containerPageUIView.numChildren);
		}

		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			return containerPageUIView.addChildAt(child, index);
		}

		override public function removeChild(child:DisplayObject, dispose:Boolean = false):DisplayObject
		{
			return containerPageUIView.removeChild(child, dispose);
		}

		override public function removeChildAt(index:int, dispose:Boolean = false):DisplayObject
		{
			return containerPageUIView.removeChildAt(index, dispose);
		}

		override public function destroy():void
		{
			if (pagnitionBitmapData)
				pagnitionBitmapData.dispose();
			super.destroy();
		}

		/*************************
		 * private
		 ************************/

		private function get pagnitionIcon():Image
		{
			if (!pagnitionBitmapData) {
				pagnitionBitmapData = new BitmapData(PAGNITION_WIDTH, PAGNITION_WIDTH, true, 0);
				var flashSprite:Sprite = new Sprite();
				flashSprite.graphics.beginFill(0xaaaaaa);
				flashSprite.graphics.drawCircle(PAGNITION_WIDTH*.5, PAGNITION_WIDTH*.5, PAGNITION_WIDTH*.5);
				flashSprite.graphics.endFill();
				pagnitionBitmapData.draw(flashSprite);
			}
			return new Image(Texture.fromBitmapData(pagnitionBitmapData));
		}

		private function get currentPageIcon():Image
		{
			if (!_currentPageIcon) {
				var currentPageBitmapData:BitmapData = new BitmapData(PAGNITION_WIDTH, PAGNITION_WIDTH, true, 0);
				var flashSprite:Sprite = new Sprite();
				flashSprite.graphics.beginFill(0xffffff);
				flashSprite.graphics.drawCircle(PAGNITION_WIDTH*.5, PAGNITION_WIDTH*.5, PAGNITION_WIDTH*.5);
				flashSprite.graphics.endFill();
				currentPageBitmapData.draw(flashSprite);
				_currentPageIcon = new Image(Texture.fromBitmapData(currentPageBitmapData));
				currentPageBitmapData.dispose();

				pagnitionUIView.addChild(_currentPageIcon);
			}
			return _currentPageIcon;
		}
	}
}

