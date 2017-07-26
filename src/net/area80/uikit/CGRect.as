package net.area80.uikit
{

	final public class CGRect
	{
		private var _width:Number = 0;
		private var _height:Number = 0;

		public function CGRect(width:Number, height:Number)
		{
			_width = width;
			_height = height;
		}

		public function get height():Number
		{
			return _height;
		}

		public function get width():Number
		{
			return _width;
		}
		
		public function copy():CGRect
		{
			return new CGRect(_width, _height);
		}
		
		public function toString ():String {
			return "[CGRect width=\""+_width+"\", height=\""+_height+"\"]";
		}
	}
}
