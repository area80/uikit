package net.area80.uikit.component
{
	import starling.core.RenderSupport;
	import starling.display.Sprite;
	
	public class UIBaseComponent extends Sprite
	{
		
		protected var _invalid:Boolean = false;
		
		public function UIBaseComponent()
		{
			super();
		}
		
		override public function render(support:RenderSupport, parentAlpha:Number):void
		{
			if (_invalid) {
				update();
			}
			super.render(support, parentAlpha);
		}
		
		public function invalid():void
		{
			_invalid = true;
		}
		
		public function updateIfInvalid():void
		{
			if (_invalid) {
				_invalid = false;
				update();
			}
		}
		
		protected function update():void
		{
			_invalid = false;
		}
	}
}