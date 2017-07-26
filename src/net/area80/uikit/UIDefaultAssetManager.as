package net.area80.uikit
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import net.area80.starling.CanvasTextureSet;
	
	import starling.core.Starling;
	import starling.textures.Texture;

	/**
	 * Thai unicode range: 0E00–0E7F
	 * @author wissarut
	 *
	 */
	public class UIDefaultAssetManager
	{





		/*[Embed(source = "./assets/bars.png")]
		private static var CanvasBars:Class;
		private static var canvasTextureBars:CanvasTextureSet;

		[Embed(source = "./assets/buttons.png")]
		private static var CanvasButtons:Class;
		private static var canvasTextureButton:CanvasTextureSet;

		[Embed(source = "./assets/icons.png")]
		private static var CanvasIcons:Class;
		private static var canvasTextureIcons:CanvasTextureSet;*/

		[Embed(source = "./assets/backgroundTexture.png")]
		private static var CanvasBackground:Class;
		private static var canvasTextureBackground:CanvasTextureSet;


		public static var backgroundTextureLightblue:starling.textures.Texture;
		public static var backgroundTextureDarkblue:starling.textures.Texture;
		public static var backgroundTextureLightgray:starling.textures.Texture;
		public static var backgroundTextureDarkgray:starling.textures.Texture;
		public static var backgroundTextureGoogleMap:starling.textures.Texture;

		private static function initBackground():void
		{

			canvasTextureBackground = initCanvasTextureFromClass(CanvasBackground);
			backgroundTextureLightblue = canvasTextureBackground.initSubTextureByRect("backgroundTextureLightblue", new Rectangle(0, 0, 16, 16), true);
			backgroundTextureDarkblue = canvasTextureBackground.initSubTextureByRect("backgroundTextureDarkblue", new Rectangle(16, 0, 16, 16), true);
			backgroundTextureLightgray = canvasTextureBackground.initSubTextureByRect("backgroundTextureLightgray", new Rectangle(16*2, 0, 16, 16), true);
			backgroundTextureDarkgray = canvasTextureBackground.initSubTextureByRect("backgroundTextureDarkgray", new Rectangle(16*3, 0, 16, 16), true);
			backgroundTextureGoogleMap = canvasTextureBackground.initSubTextureByRect("backgroundTextureGoogleMap", new Rectangle(0, 16, 32, 32), true);
			if (!Starling.handleLostContext) canvasTextureBackground.canvas.dispose();

		}


		/*
		public static var navigationbarBackground:SubTexture;
		public static var navigationbarWithDescriptionBackground:SubTexture;
		public static var navigationToolbarBackground:SubTexture;

		private static function initBars():void
		{
			canvasTextureBars = initCanvasTextureFromClass(CanvasBars);
			navigationbarBackground = canvasTextureBars.initSubTextureByRect("navigationbarWithDescriptionBackground", new Rectangle(0, 0, 640, 88), true);
			navigationbarWithDescriptionBackground = canvasTextureBars.initSubTextureByRect("navigationbarWithDescriptionBackground", new Rectangle(0, 88, 640, 120), true);
			navigationToolbarBackground = canvasTextureBars.initSubTextureByRect("navigationToolbarBackground", new Rectangle(0, 208, 640, 88), true);
			canvasTextureBars.canvas.dispose();
		}





		public static var buttonBlueL:starling.textures.Texture;
		public static var buttonBlueArrowL:starling.textures.Texture;
		public static var buttonBlueTexture:starling.textures.Texture;
		public static var buttonBlueR:starling.textures.Texture;

		private static function initButons():void
		{
			canvasTextureButton = initCanvasTextureFromClass(CanvasButtons);
			canvasTextureButton.canvas.dispose();
		}



		private static function initIcons():void
		{
			canvasTextureIcons = initCanvasTextureFromClass(CanvasIcons);
			//

			canvasTextureIcons.canvas.dispose();
		}
		*/

		[Embed(source = "./assets/facebook.png")]
		private static var CanvasFacebook:Class;

		private static var canvasTextureFacebook:CanvasTextureSet;
		public static var fbNavigationbarBackground:starling.textures.Texture;
		public static var fbNavigationbarTitleLogin:starling.textures.Texture;
		public static var fbNavigationbarTitleLogout:starling.textures.Texture;
		public static var fbNavigationbarTitleFriend:starling.textures.Texture;
		public static var fbNavigationbarTitleFriends:starling.textures.Texture;
		public static var fbNavigationbarButtonCancel:starling.textures.Texture;
		public static var fbNavigationbarButtonCancel_down:starling.textures.Texture;
		public static var fbNavigationbarButtonOK:starling.textures.Texture;
		public static var fbNavigationbarButtonOK_down:starling.textures.Texture;
		public static var fbNavigationbarButtonBack:starling.textures.Texture;
		public static var fbNavigationbarButtonBack_down:starling.textures.Texture;
		public static var fbNavigationbarButtonSelected:starling.textures.Texture;
		public static var fbNavigationbarButtonAll:starling.textures.Texture;
		public static var fbSearchBar_L:starling.textures.Texture;
		public static var fbSearchBar_C:starling.textures.Texture;
		public static var fbSearchBar_R:starling.textures.Texture;
		public static var blankTexture:starling.textures.Texture;

		private static function initFacebook():void
		{
			canvasTextureFacebook = initCanvasTextureFromClass(CanvasFacebook);
			fbNavigationbarBackground = canvasTextureFacebook.initSubTextureByRect("fbNavigationbarBackground", new Rectangle(0, 0, 8, 128), true);
			fbNavigationbarTitleLogin = canvasTextureFacebook.initSubTextureByRect("fbNavigationbarTitleLogin", new Rectangle(161, 0, 102, 40), false);
			fbNavigationbarTitleLogout = canvasTextureFacebook.initSubTextureByRect("fbNavigationbarTitleLogout", new Rectangle(264, 0, 131, 40), false);
			fbNavigationbarTitleFriend = canvasTextureFacebook.initSubTextureByRect("fbNavigationbarTitleFriend", new Rectangle(161, 40, 248, 39), false);
			fbNavigationbarTitleFriends = canvasTextureFacebook.initSubTextureByRect("fbNavigationbarTitleFriends", new Rectangle(161, 40, 272, 39), false);

			fbNavigationbarButtonCancel = canvasTextureFacebook.initSubTextureByRect("fbNavigationbarButtonCancel", new Rectangle(161, 79, 120, 59), false);
			fbNavigationbarButtonOK = canvasTextureFacebook.initSubTextureByRect("fbNavigationbarButtonOK", new Rectangle(282, 79, 120, 59), false);
			fbNavigationbarButtonBack = canvasTextureFacebook.initSubTextureByRect("fbNavigationbarButtonBack", new Rectangle(403, 79, 120, 59), false);

			fbNavigationbarButtonCancel_down = canvasTextureFacebook.initSubTextureByRect("fbNavigationbarButtonCancel_down", new Rectangle(161, 138, 120, 59), false);
			fbNavigationbarButtonOK_down = canvasTextureFacebook.initSubTextureByRect("fbNavigationbarButtonOK_down", new Rectangle(282, 138, 120, 59), false);
			fbNavigationbarButtonBack_down = canvasTextureFacebook.initSubTextureByRect("fbNavigationbarButtonBack_down", new Rectangle(403, 138, 120, 59), false);
			
			fbNavigationbarButtonSelected = canvasTextureFacebook.initSubTextureByRect("fbNavigationbarButtonSelected", new Rectangle(161, 197, 120, 59), false);
			fbNavigationbarButtonAll = canvasTextureFacebook.initSubTextureByRect("fbNavigationbarButtonAll", new Rectangle(282, 197, 120, 59), false);

			fbSearchBar_L = canvasTextureFacebook.initSubTextureByRect("fbSearchBar", new Rectangle(0, 128, 58, 88), false);
			fbSearchBar_C = canvasTextureFacebook.initSubTextureByRect("fbSearchBar", new Rectangle(58, 128, 64, 88), false);
			fbSearchBar_R = canvasTextureFacebook.initSubTextureByRect("fbSearchBar", new Rectangle(122, 128, 38, 88), false);

			var blank:BitmapData = new BitmapData(8, 8, true, 0x00000000);
			blankTexture = starling.textures.Texture.fromBitmapData(blank, false);

			//uploaded to OpenGL then remove from the memory
			if (!Starling.handleLostContext) {
				blank.dispose();
				canvasTextureFacebook.canvas.dispose();
			}
		}

		public static var topScrubber:starling.textures.Texture;
		public static var bottomScrubber:starling.textures.Texture;
		public static var middleScrubber:starling.textures.Texture;

		private static function initScrubber():void
		{
			const RADIUS:int = 5;
			const COLOR:int = 0x000000;
			const ALP:Number = .5;
			const LINECOLOR:int = 0xFFFFFF;
			const LINEALP:Number = .5;

			var tempSprite:flash.display.Sprite;
			var bmpd:BitmapData;
			var mat:Matrix;


			//TOP
			tempSprite = new flash.display.Sprite();
			//tempSprite.graphics.lineStyle(1, LINECOLOR, LINEALP, false, LineScaleMode.NONE);
			tempSprite.graphics.beginFill(COLOR, ALP);
			tempSprite.graphics.drawCircle(RADIUS, RADIUS, RADIUS);

			bmpd = new BitmapData(RADIUS*2, RADIUS, true, 0x00000000);
			bmpd.draw(tempSprite);
			topScrubber = starling.textures.Texture.fromBitmapData(bmpd, false);
			if (!Starling.handleLostContext) bmpd.dispose();

			//BOTTOM
			mat = new Matrix();
			mat.translate(0, -RADIUS);
			bmpd = new BitmapData(RADIUS*2, RADIUS, true, 0x00000000);
			bmpd.draw(tempSprite, mat);
			bottomScrubber = starling.textures.Texture.fromBitmapData(bmpd, false);
			if (!Starling.handleLostContext) bmpd.dispose();

			//MIDDLE
			// remark because didn't use.
			/*tempSprite.graphics.clear();
			tempSprite.graphics.lineStyle(1, LINECOLOR, LINEALP, false, LineScaleMode.NONE);
			tempSprite.graphics.beginFill(COLOR, ALP);
			tempSprite.graphics.drawRect(0, -20, RADIUS*2, RADIUS*6+40);
			bmpd = new BitmapData(RADIUS*2, RADIUS*6, true, 0x00000000);
			mat = new Matrix();
			mat.translate(0, -2);
			bmpd.draw(tempSprite, mat);
			middleScrubber = starling.textures.Texture.fromBitmapData(bmpd, false);
			if (!Starling.handleLostContext) bmpd.dispose();*/
		}

		private static var isInit:Boolean = UIDefaultAssetManager._init();

		//utility
		private static function initCanvasTextureFromClass(canvasClass:Class):CanvasTextureSet
		{
			var bmpData:BitmapData = Bitmap(new canvasClass()).bitmapData;
			return new CanvasTextureSet(bmpData, true);
		}


		private static function _init():Boolean
		{
			/*initBars();
			initButons();
			initIcons();*/
			initBackground();
			initFacebook();
			initScrubber();


			return true;
		}

	}

}
