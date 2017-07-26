package net.area80.uikit
{

	import net.area80.uikit.style.FontStyle;

	public class UIDefaultStyle
	{
		private static var _init:Boolean = UIDefaultStyle._isInit();

		public static var font40pxLargeBoldWhite:FontStyle;
		public static var font40pxLargeBoldBlack:FontStyle;

		public static var font40pxLargeBoldWhiteWithBavel:FontStyle;
		public static var font40pxLargeBoldBlackWithBavel:FontStyle;


		public static var font24pxLargeBoldWhite:FontStyle;
		public static var font24pxLargeBoldBlack:FontStyle;

		public static var font24pxLargeBoldWhiteWithBavel:FontStyle;
		public static var font24pxLargeBoldBlackWithBavel:FontStyle;


		public static function _isInit():Boolean
		{
			font40pxLargeBoldWhite = new FontStyle();
			font40pxLargeBoldWhite.fontWeight = FontStyle.FONT_WEIGHT_BOLD;
			font40pxLargeBoldWhite.fontSize = 40;
			font40pxLargeBoldWhite.color = "#FFFFFF";

			font40pxLargeBoldBlack = font40pxLargeBoldWhite.clone();
			font40pxLargeBoldBlack.color = "#000000";

			font40pxLargeBoldWhiteWithBavel = font40pxLargeBoldWhite.clone();
			font40pxLargeBoldWhiteWithBavel.bavel = true;
			font40pxLargeBoldWhiteWithBavel.bavelColor = "#000000";
			font40pxLargeBoldWhiteWithBavel.bavelOpacity = .4;
			font40pxLargeBoldWhiteWithBavel.bavelAngle = -90;


			font40pxLargeBoldBlackWithBavel = font40pxLargeBoldBlack.clone();
			font40pxLargeBoldBlackWithBavel.bavel = true;
			font40pxLargeBoldBlackWithBavel.bavelColor = "#FFFFFF";
			font40pxLargeBoldBlackWithBavel.bavelOpacity = .4;
			font40pxLargeBoldBlackWithBavel.bavelAngle = 90;

			font24pxLargeBoldWhite = font40pxLargeBoldWhite.clone();
			font24pxLargeBoldWhite.fontSize = 24;

			font24pxLargeBoldBlack = font40pxLargeBoldBlack.clone();
			font24pxLargeBoldBlack.fontSize = 24;

			font24pxLargeBoldWhiteWithBavel = font40pxLargeBoldWhiteWithBavel.clone();
			font24pxLargeBoldWhiteWithBavel.fontSize = 24;

			font40pxLargeBoldBlackWithBavel = font40pxLargeBoldBlackWithBavel.clone();
			font40pxLargeBoldBlackWithBavel.fontSize = 24;

			return true;
		}
	}
}
