package net.area80.uikit.component
{

	import flash.events.Event;
	
	import net.area80.uikit.CGRect;
	import net.area80.uikit.UIDefaultAssetManager;
	import net.area80.uikit.UITouchEvent;
	import net.area80.uikit.UITouchResponder;
	import net.area80.uikit.UIViewHelper;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	import starling.textures.Texture;

	public class UIImageButton extends Sprite
	{

		protected var fillImage:Image;
		protected var touchImage:Image;
		protected var ownTexture:Boolean = false;
		
		public var touchResponder:UITouchResponder = new UITouchResponder();

		public function UIImageButton()
		{
			super();
			touchable = true;
		}

		/**
		 *
		 * @param fillTexture
		 * @param touchTexture
		 * @param ownTexture If set to true the texture will be dispose when removed
		 * @return
		 *
		 */
		public function initWithTexture(fillTexture:Texture, touchTexture:Texture = null, ownTexture:Boolean = false):UIImageButton
		{
			this.ownTexture = ownTexture;
			this.fillImage = new Image(fillTexture);
			this.touchImage = new Image((touchTexture) ? touchTexture : fillTexture);
			return initWithImage(fillImage, touchImage);
		}



		public function initAsBlankButton(touchTexture:Texture = null, overrideSize:CGRect = null):UIImageButton
		{
			var size:CGRect = (overrideSize) ? overrideSize : new CGRect(touchTexture.width, touchTexture.height);
			this.fillImage = new Image(UIDefaultAssetManager.blankTexture);
			this.touchImage = new Image((touchTexture) ? touchTexture : UIDefaultAssetManager.blankTexture);
			fillImage.width = size.width;
			fillImage.height = size.height;
			touchImage.width = size.width;
			touchImage.height = size.height;

			return initWithImage(fillImage, touchImage);
		}

		protected function initWithImage(fillImage:Image, touchImage:Image):UIImageButton
		{
			//var view:Sprite = new Sprite();
			addChild(fillImage);
			addChild(touchImage);

			touchImage.visible = false;

			touchResponder.addEventListener(UITouchEvent.TOUCH_BEGAN, touchBeganHandler);
			touchResponder.addEventListener(UITouchEvent.TOUCH_END, touchEndHandler);
			
			return this as UIImageButton;
		}
		/** @inheritDoc */
		override public function set touchable(value:Boolean):void
		{
			if (value) {
				addEventListener(TouchEvent.TOUCH, touchHandle);
				touchResponder.dispatchEvent(new UITouchEvent(UITouchEvent.READY));
			} else {
				removeEventListener(TouchEvent.TOUCH, touchHandle);
				touchResponder.dispatchEvent(new UITouchEvent(UITouchEvent.CANCEL));
			}
			super.touchable = value;
		}
		
		protected function touchHandle(withEvent:TouchEvent):void
		{
			UIViewHelper.processTouch(this, touchResponder, withEvent);
		}

		override public function dispose():void
		{
			removeEventListener(TouchEvent.TOUCH, touchHandle);
			touchResponder.removeEventListener(UITouchEvent.TOUCH_BEGAN, touchBeganHandler);
			touchResponder.removeEventListener(UITouchEvent.TOUCH_END, touchEndHandler);
			touchResponder.removeAllListeners();
			
			if (ownTexture) {
				fillImage.texture.dispose();
				touchImage.texture.dispose();
			}

			fillImage.dispose();
			touchImage.dispose();

			removeChild(fillImage);
			removeChild(touchImage);

			fillImage = null;
			touchImage = null;

			super.dispose();
		}

		protected function touchEndHandler(event:Event):void
		{
			fillImage.visible = true;
			touchImage.visible = false;
		}

		protected function touchBeganHandler(event:Event):void
		{
			fillImage.visible = false;
			touchImage.visible = true;
		}

	}
}
