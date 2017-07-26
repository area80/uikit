package net.area80.uikit.component.facebook.uifacebookfriendselector.view
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.text.TextFormat;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import net.area80.starling.texturecatch.TextureCacheController;
	import net.area80.uikit.IScrollViewEquivalentSizeItem;
	import net.area80.uikit.UIKitApplicationMain;
	import net.area80.uikit.component.facebook.uifacebookfriendselector.data.FacebookFriendData;
	import net.area80.uikit.component2d.UILabel2D;
	import net.area80.uikit.component2d.UILabelResizingMode;
	import net.area80.uikit.style.AndroidStyle;
	
	import org.osflash.signals.Signal;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.textures.SubTexture;
	import starling.textures.Texture;
	import starling.utils.getNextPowerOfTwo;

	public class FacebookFriendItem extends Sprite implements IScrollViewEquivalentSizeItem
	{
		public static const HEIGHT:Number = 80;
		private const IMAGE_SIZE:Number = 50;
		private const SPACE:Number = 15;
		private const TIMEOUT_TO_LOAD:Number = 600;

		public var friendDatas:FacebookFriendData;
		public var signalChangeStatus:Signal = new Signal(FacebookFriendItem, Boolean);


		private var _width:Number;
		private var _pictureY:Number = 0;
		private var _nowMode:Number = 0;
		private var textureNameCacheController:TextureCacheController;
		private var texturePictureCacheController:TextureCacheController;

		private var loader:Loader;
		private var isFocus:Boolean = false;

		private var nameImage:Image;
		private var friendImage:Image;

		private var delayStartLoad:uint = 0;
		private var _selected:Boolean = false;
		private var IsMultipleSelect:Boolean;
		
		private var bmpd:BitmapData; // for android handlelostcontext


		//// STEP
		// 1. no focus
		// 2. focus first / no load image / timeout to load image
		// 3. focus time out ready to load image
		// 4. focus loaded image

		private const STEP_IDLE:String = "stepidle";
		private const STEP_WAITING_LOAD:String = "stepwaitingload";
		private const STEP_START_LOAD_IMAGE:String = "stepstartloadimage";
		private const STEP_LOADED_IMAGE:String = "steploadedimage";
		private var step:String = STEP_IDLE;
		private var _downBg:Quad;


		public function FacebookFriendItem(_friendDatas:FacebookFriendData, _width:Number,isMultipleSelect:Boolean , textureNameCacheController:TextureCacheController, texturePictureCacheController:TextureCacheController)
		{
			super();
			this.friendDatas = _friendDatas;
			this._width = _width;
			this.IsMultipleSelect = isMultipleSelect;
			this.textureNameCacheController = textureNameCacheController;
			this.texturePictureCacheController = texturePictureCacheController;
		}


		public function destroy():void
		{
			clearTimeout(delayStartLoad);
			destroyLoader();
			if (bmpd){
				bmpd.dispose();
				bmpd = null;
			}
		}

		public function get nowMode():Number
		{
			return _nowMode;
		}

		public function set nowMode(value:Number):void
		{
			if (value==0&&downBg) {
				downBg.visible = true;
			} else {
				downBg.visible = false;
			}
			_nowMode = value;
		}

		override public function get height():Number
		{
			return HEIGHT;
		}

		override public function set height(value:Number):void
		{
		}

		public function blur():void
		{
//			visible = false;
			if (isFocus) {
				isFocus = false;
				if (nameImage!=null)
					removeChild(nameImage);
				nameImage = null;

				if (friendImage!=null)
					removeChild(friendImage);
				friendImage = null;

				if (step==STEP_WAITING_LOAD) {
					clearTimeout(delayStartLoad);
					step = STEP_IDLE;
				} else if (step==STEP_START_LOAD_IMAGE) {
					destroyLoader();
					step = STEP_IDLE;
				} else if (step==STEP_LOADED_IMAGE) {
					texturePictureCacheController.setWeak(friendDatas.id+"_PICTURE", this);
				}
				textureNameCacheController.setWeak(friendDatas.id+"_NAME", this);
			}
		}

		public function focus():void
		{
			if (!isFocus) {
				visible = true;
				isFocus = true;

				// add name
				var nameTexture:Texture = textureNameCacheController.withdraw(friendDatas.id+"_NAME", this);

				if (!nameTexture) {
					nameTexture = getNameTextTexture();
					textureNameCacheController.deposit(nameTexture, friendDatas.id+"_NAME", this);
//					trace("not have nameTexture ...");
				} else {
//					trace("have nameTexture ...");
				}

				nameImage = new Image(nameTexture);
				addChild(nameImage);
				nameImage.x = 80;
				nameImage.y = 20;
				nameImage.touchable = false;

				if (step==STEP_IDLE) {
					delayStartLoad = setTimeout(loadImage, TIMEOUT_TO_LOAD);
					step = STEP_WAITING_LOAD;
				} else if (step==STEP_LOADED_IMAGE) {
					addProfileImageIfLoadedAndFocus();
				}
			}
		}



		/**
		 * PRIVATE
		 *
		 */

		public function get downBg():Quad
		{
			if (!_downBg) {
				_downBg = new Quad(_width, HEIGHT, 0x6f85b3);
				addChildAt(_downBg, 0);
			}
			return _downBg;
		}

		private function loadImage():void
		{
			if (!loader) {
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadedImage);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadError);
			}
			loader.load(new URLRequest("http://graph.facebook.com/"+friendDatas.id+"/picture?type=square"));
			step = STEP_START_LOAD_IMAGE;
		}

		protected function loadedImage(event:Event):void
		{
			step = STEP_LOADED_IMAGE;

			var bmpd:BitmapData = Bitmap(loader.contentLoaderInfo.content).bitmapData;
			var _h:Number;
			if (bmpd.height<IMAGE_SIZE) {
				_pictureY = (IMAGE_SIZE-bmpd.height)*.5;
				_h = bmpd.height;
			} else {
				_h = IMAGE_SIZE;
			}
			var pictureTexture:SubTexture = new SubTexture(Texture.fromBitmapData(bmpd, false), new Rectangle(0, 0, IMAGE_SIZE, _h));
			pictureTexture.repeat = true;
			texturePictureCacheController.deposit(pictureTexture, friendDatas.id+"_PICTURE", this);

			// profile pic size is 50x50 not power of two, "Texture.fromBitmapData" will create new bitmapData and we cann't manage it
			// Good : we can safe dispose our bitmapData here and don't need to keep for handle lost context ("Texture.fromBitmapData" already keep the new one)
			// Bad : We got stack of bitmapData that "Texture.fromBitmapData" created and we can't dispose them !
			
			Bitmap(loader.contentLoaderInfo.content).bitmapData.dispose();
			destroyLoader();

			addProfileImageIfLoadedAndFocus();
		}

		protected function loadError(event:IOErrorEvent):void
		{
			delayStartLoad = setTimeout(loadImage, TIMEOUT_TO_LOAD);
			step = STEP_WAITING_LOAD;
		}

		private function addProfileImageIfLoadedAndFocus():void
		{
			if (step==STEP_LOADED_IMAGE&&isFocus) {
				var pictureTexture:Texture = texturePictureCacheController.withdraw(friendDatas.id+"_PICTURE", this);
				if (pictureTexture) {
					friendImage = new Image(pictureTexture);
					friendImage.touchable = false;
					friendImage.x = SPACE;
					friendImage.y = SPACE+_pictureY;
					addChild(friendImage);
				} else {
					delayStartLoad = setTimeout(loadImage, TIMEOUT_TO_LOAD);
					step = STEP_WAITING_LOAD;
				}
			}
		}

		private function getNameTextTexture():Texture
		{
			var style:TextFormat = new TextFormat();
			if (UIKitApplicationMain.isAndroid) {
				style.font = AndroidStyle.sarabunFont.fontName; //"lucida grande";
				style.color = 0x555555;
				style.size = 24;
			} else {
				style.font = "lucida grande"; //"lucida grande";
				style.color = 0x555555;
				style.size = 24;
			}

			var label:UILabel2D = new UILabel2D(friendDatas.name, style);
			label.embedFonts = (UIKitApplicationMain.isAndroid);
			label.resizeMode = UILabelResizingMode.RESIZE_AUTO;
			label.width = _width-IMAGE_SIZE-SPACE*4;
			label.height = HEIGHT;
			label.truncateTail = true;
			label.baseLine = UILabelResizingMode.BASELINE_MIDDLE;
			label.updateIfInvalid();
			
			if (bmpd){
				bmpd.dispose();
				bmpd = null;
			}
			bmpd = new BitmapData( getNextPowerOfTwo(label.width) , getNextPowerOfTwo(label.height), true , 0 );
			bmpd.draw(label,null,null,null,null,true);
			var texture:Texture = new SubTexture( Texture.fromBitmapData(bmpd,false) , new Rectangle(0,0, Math.ceil(label.width), Math.ceil(label.height)), true );
			if (!Starling.handleLostContext){
				bmpd.dispose();
				bmpd = null;
			}
			
			
			return texture;
		}

		private function destroyLoader():void
		{
			if (!loader)
				return;
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadedImage);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadError);
			try {
				loader.close();
			} catch (e:Error) {
			}
			try {
				loader.unload();
			} catch (e:Error) {
			}
			loader = null;
		}

		/**
		 * TOUCH CONTROLLER
		 */

		public function click():void
		{
			if (_nowMode==0) {
				if (IsMultipleSelect){
					selected = !selected;
				}else{
					selected = true;
				}
				signalChangeStatus.dispatch(this, selected);
			}
		}
		
		public function unSelect():void{
			selected = false;
		}

		public function mouseDown():void
		{
			if (_nowMode==0) {
				downBg.visible = true;
				downBg.alpha = .5;
			}
		}

		public function mouseUp():void
		{
			if (_nowMode==0) {
				downBg.alpha = 1;
				if (!selected) {
					downBg.visible = false;
				} else {
					downBg.visible = true;
				}
			}
		}




		public function get selected():Boolean
		{
			return _selected;
		}

		public function set selected(value:Boolean):void
		{
			downBg.visible = value;
			_selected = value;
		}

	}
}
