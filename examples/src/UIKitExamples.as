package
{

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;

	import net.area80.timer.TimeController;
	import net.area80.uikit.AppDelegate;

	public class UIKitExamples extends Sprite
	{
		public function UIKitExamples()
		{
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			TimeController.delayFucntion(.2, _initstage);
			super();
		}

		private function _initstage(e:Event = null):void
		{
			var appScale:Number = 1;
			if (stage.stageWidth < 640) {
				appScale = 0.5;
			}
			AppDelegate.initCG(UIKitExamplesAppdelegate, stage, 640 * appScale, stage.stageHeight, appScale, false);

		}
	}
}
