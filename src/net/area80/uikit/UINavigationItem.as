package net.area80.uikit
{

	public class UINavigationItem
	{
		private var _title:String;
		private var _titleView:UIView;
		private var _backBarButtonItem:UIView;
		private var _rightBarButtonItem:UIView;
		private var _leftBarButtonItem:UIView;
		private var _hidesBackButton:Boolean;
		private var _leftItemsSupplementBackButton:Boolean = false;
		
		public function UINavigationItem () {}

		public function get leftItemsSupplementBackButton():Boolean
		{
			return _leftItemsSupplementBackButton;
		}

		public function set leftItemsSupplementBackButton(value:Boolean):void
		{
			_leftItemsSupplementBackButton = value;
		}

		public function get hidesBackButton():Boolean
		{
			return _hidesBackButton;
		}

		public function set hidesBackButton(value:Boolean):void
		{
			_hidesBackButton = value;
		}

		public function get leftBarButtonItem():UIView
		{
			return _leftBarButtonItem;
		}

		public function set leftBarButtonItem(value:UIView):void
		{
			_leftBarButtonItem = value;
		}

		public function get rightBarButtonItem():UIView
		{
			return _rightBarButtonItem;
		}

		public function set rightBarButtonItem(value:UIView):void
		{
			_rightBarButtonItem = value;
		}

		public function get backBarButtonItem():UIView
		{
			return _backBarButtonItem;
		}

		public function set backBarButtonItem(value:UIView):void
		{
			_backBarButtonItem = value;
		}

		public function get titleView():UIView
		{
			return _titleView;
		}

		public function set titleView(value:UIView):void
		{
			_titleView = value;
		}

		public function get title():String
		{
			return _title;
		}

		public function set title(value:String):void
		{
			_title = value;
		}

		public function setHidesBackButton(hides:Boolean, animated:Boolean = true):void
		{

		}

		public function setRightBarButtonItem(buttonItem:UIView, animated:Boolean = true):void
		{

		}

		public function setLeftBarButtonItem(buttonItem:UIView, animated:Boolean = true):void
		{

		}



	}
}
