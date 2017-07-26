package net.area80.uikit
{
	import flash.display.Sprite;
	import flash.events.Event;

	import com.greensock.TweenLite;

	public class UIAssetPreloader extends Sprite
	{
		private static var _instance:UIAssetPreloader;

		internal static function getInstance():UIAssetPreloader
		{
			return _instance;
		}

		public function UIAssetPreloader()
		{
			super();

			if (_instance) {
				throw new ArgumentError("You can't have more than one UIAssetPreloader.");
			} else {
				_instance = this;
			}
			visible = false;
			addEventListener(Event.ADDED_TO_STAGE, didAddToStage);
		}

		protected function didAddToStage(event:Event):void
		{
			visible = true;
			removeEventListener(Event.ADDED_TO_STAGE, didAddToStage);
			addEventListener(Event.ENTER_FRAME, onStageResize); //Need to be enterframe
			addEventListener(Event.REMOVED_FROM_STAGE, didRemoveFromStage);
			onStageResize(null);
		}

		protected function onStageResize(event:Event):void
		{
			var sx:Number = stage.fullScreenWidth/640;
			var sy:Number = stage.fullScreenHeight/960;
			this.scaleX = this.scaleY = Math.max(sx, sy);
			if (sx!=sy) {
				//trace("sx:sy,", sx, sy, stage.fullScreenWidth, stage.fullScreenHeight);
				if (sx>sy) {
					//trace(" fix x move y-asix");
					scaleX = scaleY = sx;
					this.y = -((960*sx)-stage.fullScreenHeight)*.5;
				} else {
					//trace(" fix y move x-asix");
					scaleX = scaleY = sy;
					this.x = -((640*sy)-stage.fullScreenWidth)*.5;
				}
			}

		}

		public function preloadInit():void
		{

		}

		internal function preloadCompleted():void
		{
			TweenLite.to(this, .5, {alpha: 0, onComplete: tweenComplete});
			_instance = null;
		}

		private function tweenComplete():void
		{
			if (this.parent) {
				this.parent.removeChild(this);
			}
		}

		public function updateProgress(progress:Number, total:Number):void
		{

		}

		protected function didRemoveFromStage(event:Event):void
		{
			visible = false;
			addEventListener(Event.ADDED_TO_STAGE, didAddToStage);
			removeEventListener(Event.REMOVED_FROM_STAGE, didRemoveFromStage);
			removeEventListener(Event.ENTER_FRAME, onStageResize);
		}
	}
}
