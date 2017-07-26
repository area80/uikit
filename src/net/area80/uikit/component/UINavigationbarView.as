package net.area80.uikit.component
{

	import net.area80.uikit.CGRect;
	import net.area80.uikit.UIColor;
	import net.area80.uikit.UIScreen;
	import net.area80.uikit.UIView;
	import net.area80.uikit.UIViewAutoresizing;
	
	import starling.display.DisplayObject;


	public class UINavigationbarView extends UIView
	{
		protected var rightbarButton:DisplayObject;
		protected var leftbarButton:DisplayObject;
		protected var title:DisplayObject;
		protected var verticalAdjustment:Number = 0;
		private var _verticalPadding:Number = 10;

		public function UINavigationbarView()
		{
			super();
		}

		public function get verticalPadding():Number
		{
			return _verticalPadding;
		}

		public function set verticalPadding(value:Number):void
		{
			_verticalPadding = value;
			setNeedsLayout();
		}

		public function initWithColor(color:UIColor):UINavigationbarView
		{
			//fixed height
			var rect:CGRect = new CGRect(UIScreen.applicationFrame.width, 88);
			autoresizingMask = UIViewAutoresizing.FLEXIBLE_WIDTH;
			this.background = color;


			return super.initWithFrame(rect) as UINavigationbarView;
		}


		override protected function layoutSubviews():void
		{
			if (title) {
				title.x = int((frame.width - title.width) * .5);
				title.y = int((frame.height - title.height) * .5) + verticalAdjustment;
			}
			if (rightbarButton) {
				rightbarButton.x = int(frame.width - (rightbarButton.width + _verticalPadding));
				rightbarButton.y = int((frame.height - rightbarButton.height) * .5) + verticalAdjustment;
			}
			if (leftbarButton) {
				leftbarButton.x = _verticalPadding;
				leftbarButton.y = int((frame.height - leftbarButton.height) * .5) + verticalAdjustment;
			}
			super.layoutSubviews();
		}

		public function setTitleVerticalPositionAdjustment(value:Number):void
		{
			verticalAdjustment = value;
			setNeedsLayout();
		}


		override public function destroy():void
		{
			removeRightbarButton();
			super.destroy();
		}

		public function removeTitle():void
		{
			if (title) {
				removeChild(title);
				title = null;
			}
		}

		public function setTitle(title:DisplayObject):void
		{
			removeTitle();
			this.title = title;
			addChild(title);
			setNeedsLayout();
		}

		public function removeRightbarButton():void
		{
			if (rightbarButton) {
				removeChild(rightbarButton);
				rightbarButton = null;
			}
		}

		public function setRightBarButton(button:DisplayObject):void
		{
			removeRightbarButton();
			rightbarButton = button;
			addChild(rightbarButton);
			setNeedsLayout();
		}

		public function removeLeftbarButton():void
		{
			if (leftbarButton) {
				removeChild(leftbarButton);
				leftbarButton = null;
			}
		}

		public function setLeftBarButton(button:DisplayObject):void
		{
			removeLeftbarButton();
			leftbarButton = button;
			addChild(leftbarButton);
			setNeedsLayout();
		}

		override public function initWithFrame(aRect:CGRect = null):UIView
		{
			return super.initWithFrame(aRect);
		}
	}
}
