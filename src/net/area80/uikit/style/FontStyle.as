package net.area80.uikit.style
{

	public class FontStyle
	{
		public static const FONT_WEIGHT_BOLD:String = "bold";
		public static const FONT_WEIGHT_NORMAL:String = "normal";

		public var fontFamily:String = "Helvetica Neue, Helvetica, Arial, Tahoma";
		public var fontSize:int = 27;
		public var fontWeight:String = "normal";
		public var color:String = "#333333";
		public var bavel:Boolean = false;
		public var bavelColor:String = "#000000";
		public var bavelOpacity:Number = 0.4;
		public var bavelAngle:Number = -90;
		public var italic:Boolean = false;
		
		public function FontStyle () {}

		public function clone():FontStyle
		{
			var style:FontStyle = new FontStyle();
			style.fontFamily = this.fontFamily;
			style.fontSize = this.fontSize;
			style.fontWeight = this.fontWeight;
			style.color = this.color;
			style.bavel = this.bavel;
			style.bavelColor = this.bavelColor;
			style.bavelOpacity = this.bavelOpacity;
			style.italic = this.italic;
			return style;
		}
	}
}
