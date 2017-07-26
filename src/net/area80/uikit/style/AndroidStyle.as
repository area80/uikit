package net.area80.uikit.style
{
	import flash.text.Font;

	public class AndroidStyle
	{
		[Embed(source = "./net/area80/uikit/assets/font/THSarabun.ttf",
			fontFamily = "THSarabun",
			mimeType = "application/x-font",
			embedAsCFF = "false")]
		private static var SarabunClass:Class;

		[Embed(source = "./net/area80/uikit/assets/font/THSarabun Bold.ttf",
			fontFamily = "THSarabun Bold",
			mimeType = "application/x-font",
			fontWeight = "bold",
			embedAsCFF = "false")]
		private static var SarabunBoldClass:Class;

		public static var sarabunFont:Font;
		public static var sarabunFontBold:Font;

		public function AndroidStyle()
		{
			super();
			if (!sarabunFont)
				sarabunFont = new SarabunClass();
			if (!sarabunFontBold)
				sarabunFontBold = new SarabunBoldClass();
		}
	}
}
