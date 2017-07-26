package net.area80.uikit
{

	/**
	 *
	 * example - Keep size, stay centered FLEXIBLE_LEFT_MARGIN | FLEXIBLE_RIGHT_MARGIN
	 * Keep size, stay centered FLEXIBLE_TOP_MARGIN | FLEXIBLE_BOTTOM_MARGIN
	 * @author wissarut
	 *
	 */
	public class UIViewAutoresizing
	{
		/**
		 *
		 */
		public static const NONE:uint = 1;
		/**
		 * Keep size and same distance from the right
		 */
		public static const FLEXIBLE_LEFT_MARGIN:uint = 1 << 1;
		/**
		 * Resize keeping fixed left/right margins
		 */
		public static const FLEXIBLE_WIDTH:uint = 1 << 2;
		/**
		 * Keep size and same distance from the left:
		 */
		public static const FLEXIBLE_RIGHT_MARGIN:uint = 1 << 3;
		/**
		 * Keep size and same distance from the bottom
		 */
		public static const FLEXIBLE_TOP_MARGIN:uint = 1 << 4;
		/**
		 * Resize keeping fixed top/bottom margins
		 */
		public static const FLEXIBLE_HEIGHT:uint = 1 << 5;
		/**
		 * Keep size and same distance from the top
		 */
		public static const FLEXIBLE_BOTTOM_MARGIN:uint = 1 << 6;
	}
}


