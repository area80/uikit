package net.area80.uikit
{


	import net.area80.starling.TextureUtils;
	
	import starling.core.RenderSupport;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.textures.Texture;

	final public class UIColor extends Sprite
	{
		protected var color:*;
		protected var image:Quad;
		protected var texture:Texture;
		protected var invalid:Boolean = false;

		public function UIColor()
		{
			super();
		}

		public function initWithColor(color:uint, aRect:CGRect = null):UIColor
		{
			if (!aRect)
				aRect = new CGRect(1, 1);
			this.color = color;
			image = new Quad(aRect.width, aRect.height, color);
			addChild(image);
			invalid = true;
			return this;
		}

		public function initWithTexture(texture:Texture, aRect:CGRect = null):UIColor
		{
			if (!aRect)
				aRect = new CGRect(1, 1);
			this.color = texture;
			/*if (texture is SubTexture) {
				if (SubTexture(texture).parent.width != texture.width || SubTexture(texture).parent.height != texture.height) {
					throw new Error("If you need sub texture, texture width & height must be identicle to parent texture (Is the same texture as parent).");
				}
			}*/
			if (texture.width==0||texture.height==0) {
				throw new Error("Texture must has size, use SubTexture or ConcreteTexture for width, height information");
			}
			image = new Image(texture);
			addChild(image);
			invalid = true;
			return this;
		}

		override public function set height(value:Number):void
		{
			invalid = true;
			if (image)
				image.height = value;
		}

		override public function set width(value:Number):void
		{
			invalid = true;
			if (image)
				image.width = value;
		}


		protected function layoutSubviews():void
		{
			if (image&&color is Texture) {
				TextureUtils.updateRepeatTexture(Image(image), color as Texture);
			}
		}


		override public function render(support:RenderSupport, parentAlpha:Number):void
		{
			if (invalid) {
				layoutSubviews();
				invalid = false;
			}
			super.render(support, parentAlpha);
		}

	}
}
