package net.area80.uikit
{

	import flash.display.Sprite;

	/**
	 * Starling has its own display list, but sometime we need realtime texture update which it can't be done with Starling's texture due to cpu limit.
	 * @author wissarut
	 *
	 */
	public class UIView2D extends Sprite
	{
		internal static var count:uint = 0;
		
		protected var _uiview:UIView;

		public function UIView2D()
		{
			super();
		}
		

		internal function updateIndexing ():void
		{
			if (parent) {
				parent.setChildIndex(this, count++);
			}
		}
	}
}
