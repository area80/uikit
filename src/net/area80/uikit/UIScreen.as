package net.area80.uikit
{

	import flash.display.StageOrientation;

	public class UIScreen
	{
		private static var self:UIScreen = new UIScreen();

		private var _deviceRect:CGRect = new CGRect(640, 920);
		private var _scale:Number = 1;
		private var _orientation:String = StageOrientation.DEFAULT;
		private var _autoRotatationIsSupported:Boolean = false;
		
		public function UIScreen () {}

		public static function get autoRotatationIsSupported():Boolean
		{
			return self._autoRotatationIsSupported;
		}

		public static function get scale():Number
		{
			return self._scale;
		}

		internal static function initDeviceFrame(portrait:uint, landscape:uint, scale:Number = 1, autoRotatationIsSupported:Boolean = false):void
		{
			self._autoRotatationIsSupported = autoRotatationIsSupported;
			if (!self._autoRotatationIsSupported) {
				self._orientation = StageOrientation.DEFAULT;
			}
			self._deviceRect = new CGRect(portrait, landscape);
			self._scale = scale;
		}

		public static function get orientation():String
		{
			return self._orientation;
		}



		public static function get applicationFrame():CGRect
		{
			if (orientation == StageOrientation.ROTATED_LEFT || orientation == StageOrientation.ROTATED_RIGHT) {
				return landscapeFrame;
			} else {
				return portraitFrame;
			}
		}

		private static function get portraitFrame():CGRect
		{
			return new CGRect(self._deviceRect.width, self._deviceRect.height);
		}

		private static function get landscapeFrame():CGRect
		{
			return new CGRect(self._deviceRect.height, self._deviceRect.width);
		}

		internal static function setOrientation(orientation:String):void
		{
			UIDebugger.log(self, "Orientation is changed to " + orientation);
			self._orientation = orientation;
		}
	}
}
