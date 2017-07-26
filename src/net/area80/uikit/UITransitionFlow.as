package net.area80.uikit
{
	public class UITransitionFlow
	{
		/**
		 * Before Flow, transitions new page in then moves current page out
		 */
		public static const BEFORE:String = "before";
		/**
		 * After Flow, wait for current page moves out then start transition
		 */
		public static const AFTER:String = "after";
		/**
		 * Cross Flow, transitions current page out and new page in at the same time.
		 */
		public static const CROSS:String = "cross";
	}
}