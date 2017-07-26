package net.area80.uikit.component
{
	import flash.geom.Rectangle;
	
	import net.area80.starling.TextureUtils;
	
	import starling.core.RenderSupport;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;


	/**
	 *
	 * @author EXIT
	 *   0   1
	 *  |-| |-|
	 *   0 1 2  I 2
	 *   3 4 5
	 *   6 7 8  I 3
	 *
	 *   0 1 2
	 *
	 *     0
	 *     1
	 *     2
	 *
	 */
	public class UI9Slice extends Sprite
	{
		public static const NINE_SCALE:String = "ninescale";
		public static const THREE_SCALE_HORIZONTAL:String = "threescalehorizontal";
		public static const THREE_SCALE_VERTICAL:String = "threescalevertical";

		private var type:String;
		private var isRepeateTexture:Boolean;
		private var _width:Number = 0;
		private var _height:Number = 0;

		private var invalid:Boolean = false;
		private var isInit:Boolean = false;

		private var vectorImage:Vector.<Image> = new Vector.<Image>();
		private var vectorEdgeSize:Vector.<Number> = new Vector.<Number>();

		/**
		 * 
		 * @param _type
		 * @param _isRepeateTexture Deprecated
		 * 
		 */
		public function UI9Slice(_type:String, _isRepeateTexture:Boolean = false)
		{
			super();
			type = _type;
			isRepeateTexture = _isRepeateTexture;
		}

		public function initWithImages(_vectorImage:Vector.<Image>):UI9Slice
		{
			if (isInit) {
				throw new Error("UI9SliceImage has been initialized, cannot reinit !!! ");
			}
			vectorImage = _vectorImage;
			if ((type==NINE_SCALE&&vectorImage.length!=9)||
				(type==THREE_SCALE_HORIZONTAL&&vectorImage.length!=3)||
				(type==THREE_SCALE_VERTICAL&&vectorImage.length!=3)) {
				throw new Error("{UI9SliceImage} length of vectorImage is not compatible!!!");
			}

			initImageAndVariable();
			invalid = true;
			isInit = true;
			return this;
		}

		private function initImageAndVariable():void
		{
			if (type==NINE_SCALE) {
				vectorEdgeSize.push(vectorImage[0].width);
				vectorEdgeSize.push(vectorImage[2].width);
				vectorEdgeSize.push(vectorImage[0].height);
				vectorEdgeSize.push(vectorImage[6].height);
				if (_width==0) {
					_width = vectorImage[0].width+vectorImage[1].width+vectorImage[2].width;
				}
				if (_height==0) {
					_height = vectorImage[0].height+vectorImage[3].height+vectorImage[6].height;
				}
			} else if (type==THREE_SCALE_HORIZONTAL) {
				vectorEdgeSize.push(vectorImage[0].width);
				vectorEdgeSize.push(vectorImage[2].width);
				if (_width==0) {
					_width = vectorImage[0].width+vectorImage[1].width+vectorImage[2].width;
				}
				if (_height==0) {
					_height = vectorImage[0].height;
				}
			} else if (type==THREE_SCALE_VERTICAL) {
				vectorEdgeSize.push(vectorImage[0].height);
				vectorEdgeSize.push(vectorImage[2].height);
				if (_width==0) {
					_width = vectorImage[0].width;
				}
				if (_height==0) {
					_height = vectorImage[0].height+vectorImage[1].height+vectorImage[2].height;
				}
			}
			var i:int;
			for (i = 0; i<=vectorImage.length-1; i++) {
				//vectorImage[i].touchable = false;
				addChild(vectorImage[i]);
			}
		}

		/**
		 * UPDATE TEXUTRE
		 *  when width or height has changed
		 *
		 */

		public function updateTexture():void
		{
			unflatten();
			var i:uint;
			if (type==NINE_SCALE) {
				updateTexture9Scale();
			} else if (type==THREE_SCALE_HORIZONTAL) {
				updateTexture3ScaleHorizontal()
			} else if (type==THREE_SCALE_VERTICAL) {
				updateTexture3ScaleVertical();
			}
			flatten();
			invalid = false;
		}

		private function updateTexture9Scale():void
		{
			var edgeRight:Number = _width-vectorEdgeSize[1];
			var edgeBottom:Number = _height-vectorEdgeSize[3];
			var centerWidth:Number = _width-vectorEdgeSize[0]-vectorEdgeSize[1];
			var centerHeight:Number = _height-vectorEdgeSize[2]-vectorEdgeSize[3];

			vectorImage[1].x = vectorEdgeSize[0];
			vectorImage[4].x = vectorEdgeSize[0];
			vectorImage[7].x = vectorEdgeSize[0];

			vectorImage[2].x = edgeRight;
			vectorImage[5].x = edgeRight;
			vectorImage[8].x = edgeRight;

			vectorImage[3].y = vectorEdgeSize[2];
			vectorImage[4].y = vectorEdgeSize[2];
			vectorImage[5].y = vectorEdgeSize[2];

			vectorImage[6].y = edgeBottom;
			vectorImage[7].y = edgeBottom;
			vectorImage[8].y = edgeBottom;

			vectorImage[1].width = centerWidth;
			vectorImage[4].width = centerWidth;
			vectorImage[7].width = centerWidth;

			vectorImage[3].height = centerHeight;
			vectorImage[4].height = centerHeight;
			vectorImage[5].height = centerHeight;

			//if (isRepeateTexture) {
				if(vectorImage[1].texture.repeat) TextureUtils.updateRepeatTexture(vectorImage[1], vectorImage[1].texture);
				if(vectorImage[4].texture.repeat) TextureUtils.updateRepeatTexture(vectorImage[4], vectorImage[4].texture);
				if(vectorImage[7].texture.repeat) TextureUtils.updateRepeatTexture(vectorImage[7], vectorImage[7].texture);
				if(vectorImage[3].texture.repeat) TextureUtils.updateRepeatTexture(vectorImage[3], vectorImage[3].texture);
				if(vectorImage[5].texture.repeat) TextureUtils.updateRepeatTexture(vectorImage[5], vectorImage[5].texture);
				
			//}
		}

		private function updateTexture3ScaleHorizontal():void
		{
			vectorImage[1].x = vectorEdgeSize[0];
			vectorImage[2].x = _width-vectorEdgeSize[1];
			vectorImage[1].width = _width-vectorEdgeSize[0]-vectorEdgeSize[1];

			//if (isRepeateTexture) {
				if(vectorImage[1].texture.repeat) TextureUtils.updateRepeatTexture(vectorImage[1], vectorImage[1].texture);
			//}
		}

		private function updateTexture3ScaleVertical():void
		{
			vectorImage[1].y = vectorEdgeSize[0];
			vectorImage[2].y = _height-vectorEdgeSize[1];
			vectorImage[1].height = _height-vectorEdgeSize[0]-vectorEdgeSize[1];

			//if (isRepeateTexture) {
				if(vectorImage[1].texture.repeat) TextureUtils.updateRepeatTexture(vectorImage[1], vectorImage[1].texture);
			//}
		}


		/**
		 * Override
		 */

		override public function render(support:RenderSupport, parentAlpha:Number):void
		{
			if (invalid) {
				updateTexture();
			}
			super.render(support, parentAlpha);
		}

		override public function get width():Number
		{
			return _width;
		}

		override public function set width(value:Number):void
		{
			if (type==THREE_SCALE_VERTICAL)
				return ;
			invalid = true;
			_width = value;
		}

		override public function get height():Number
		{
			return _height;
		}

		override public function set height(value:Number):void
		{
			if (type==THREE_SCALE_HORIZONTAL)
				return;
			invalid = true;
			_height = value;
		}

		override public function set scaleX(value:Number):void
		{
			throw new Error("ScaleX is not supported!!!");
		}

		override public function set scaleY(value:Number):void
		{
			throw new Error("ScaleY is not supported!!!");
		}
		
		override public function getBounds(targetSpace:DisplayObject, resultRect:Rectangle=null):Rectangle
		{
			if(invalid) updateTexture();
			var b:Rectangle = super.getBounds(targetSpace, resultRect);
			return super.getBounds(targetSpace, resultRect);
		}
		
	}
}
