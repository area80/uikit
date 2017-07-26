package net.area80.uikit.component
{
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.SoftKeyboardEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.StageText;
	import flash.text.StageTextInitOptions;
	
	import net.area80.uikit.AppDelegate;
	import net.area80.uikit.UITouchEvent;
	import net.area80.uikit.UITouchResponder;
	import net.area80.uikit.UIViewHelper;
	import net.area80.uikit.component.UIBaseComponent;
	
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.textures.SubTexture;
	import starling.textures.Texture;
	import starling.utils.getNextPowerOfTwo;
	
	public class UIStageText extends UIBaseComponent
	{
		private var touchQuad:Quad;
		private var touchResponder:UITouchResponder;
		
		private var _stageText:StageText;
		private var _width:uint=100;
		private var _height:uint=35;
		private var _textureIsInvalid:Boolean = false;
		private var _imageSnapShot:Image;
		private var _bRemoveStageText:Boolean = false;
		private var bmpd:BitmapData; // for android handlelostcontext
		
		private var _paddingTop:int = 0;
		private var _paddingBottom:int = 0; 
		private var _paddingLeft:int = 0;
		private var _paddingRight:int = 0;
		private var _hint:String = "";
		
		public var responder:UIStageTextResponder;
		
		private var IsfocusOutOnReturnKey:Boolean;
		
		/** helper object */
		private static var sOrigin:Point = new Point();
		
		public static const STAGETEXT_OFFSET:String = "STAGETEXT_OFFSET";
		
		public function UIStageText(Multiline:Boolean = false, IsfocusOutOnReturnKey:Boolean = false)
		{
			super();
			
			this.IsfocusOutOnReturnKey = IsfocusOutOnReturnKey;
			
			var stio:StageTextInitOptions = new StageTextInitOptions(Multiline);
			_stageText = new StageText(stio);
			
			this.responder = new UIStageTextResponder(_stageText);
			
			touchQuad = new Quad(_width,_height,0xFF0000);
			touchQuad.alpha = 0;
			addChild(touchQuad);
			touchQuad.addEventListener(TouchEvent.TOUCH, touchProcess);
			
			touchResponder = new UITouchResponder();
			touchResponder.addEventListener(UITouchEvent.TOUCH_TAB, touchHandler);
			
			_stageText.addEventListener(FocusEvent.FOCUS_OUT, focusOutHandler);
			_stageText.addEventListener(FocusEvent.FOCUS_IN, focusInHandler);
			_stageText.addEventListener(flash.events.Event.CHANGE, onTextChange);
			
			invalid();
			
			Starling.current.addEventListener(starling.events.Event.CONTEXT3D_CREATE, onContextCreated);
			
			_stageText.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, onSoftKeyboardActivate);
		}

		private function onSoftKeyboardActivate(event:SoftKeyboardEvent):void
		{
			var offset:int = 0;

			var p:Point = new Point(this.x,this.y);
			p = this.localToGlobal(p);
			//if the softkeyboard is open and the field is at least partially covered
			if( (Starling.current.nativeStage.softKeyboardRect.y != 0) && (p.y + this.height > Starling.current.nativeStage.softKeyboardRect.y) ) 
				offset = p.y + this.height - Starling.current.nativeStage.softKeyboardRect.y; 
			//but don't push the top of the field above the top of the screen 
			if( p.y - offset < 0 ) offset += p.y - offset;

			dispatchEventWith(STAGETEXT_OFFSET,false,{offset:offset,activekeyboard:true});
			_stageText.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE,onSoftKeyboardDeactivate);
		}
		
		private function onSoftKeyboardDeactivate(e:SoftKeyboardEvent):void{
			_stageText.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE,onSoftKeyboardDeactivate);
			dispatchEventWith(STAGETEXT_OFFSET,false,{offset:0,activekeyboard:false});
			if (_stageText.stage) {
				focusOutHandler(new FocusEvent(FocusEvent.FOCUS_OUT,false));
			}
		}
		
		private function onContextCreated(e:starling.events.Event):void{
			_textureIsInvalid = true;
			createTexture();
			if(_imageSnapShot) _imageSnapShot.visible = true;
			_stageText.stage = null;
		}
		
		private function touchProcess(e:TouchEvent):void{
			UIViewHelper.processTouch(touchQuad,touchResponder,e);
		}
		
		protected function onTextChange(event:flash.events.Event):void{
			_textureIsInvalid = true;
			if (_stageText.multiline && IsfocusOutOnReturnKey){
				var txt:String = _stageText.text;
				if (txt.length>0){
					if (txt.charAt(txt.length-1)=="\n"){
						_stageText.text = _stageText.text.slice(0,txt.length-1);
						AppDelegate.flashStage.focus = null;
					}
				}
			}
			responder.dispatchEvent(event);
		}
		
		protected function focusOutHandler(event:FocusEvent):void
		{
			if(_textureIsInvalid) {
				createTexture();
			}
			if(_imageSnapShot) _imageSnapShot.visible = true;
			_stageText.stage = null;
			responder.dispatchEvent(event);
		}
		protected function focusInHandler(event:FocusEvent):void
		{
			if(_stageText.text==_hint) {
				_stageText.text = "";
			}
			_bRemoveStageText = false; // Ensure not remove StageText while focus in
			responder.dispatchEvent(event);
		}
		protected function touchHandler(event:UITouchEvent):void
		{
			// if touch from snapshot
			if(_stageText.stage) return;
			if(!_stageText.editable) return;
			if(_imageSnapShot) _imageSnapShot.visible = false;
			_stageText.stage = AppDelegate.flashStage;
			_stageText.assignFocus();
		}
		
		protected function createTexture ():void {
			if(_stageText.text=="") {
				_stageText.text = _hint;
			}

			var w:int = Math.round(_stageText.viewPort.width);
			var h:int = Math.round(_stageText.viewPort.height);
			var bmpdTemp:BitmapData = new BitmapData(w,h,true,0x000000); // _stageText.drawViewPortToBitmapData need width height same with _stageText.viewPort
			_stageText.drawViewPortToBitmapData(bmpdTemp);
			
			if (bmpd){
				bmpd.dispose();
				bmpd = null;
			}
			
			// we need power of two otherwise Texture.fromBitmapData will create new one
			bmpd = new BitmapData( getNextPowerOfTwo(w) , getNextPowerOfTwo(h), true , 0 );
			bmpd.copyPixels(bmpdTemp, bmpdTemp.rect, sOrigin);
			
			bmpdTemp.dispose();
			bmpdTemp = null;
			
			var texture:Texture = new SubTexture( Texture.fromBitmapData(bmpd,false) , new Rectangle(0,0, w, h), true );
			texture.root.onRestore = null; // dont' want starling restore because we will create new one

			//if (!Starling.handleLostContext){
				bmpd.dispose();
				bmpd = null;
			//}
			
			if(!_imageSnapShot) {
				_imageSnapShot = new Image(texture);
				_imageSnapShot.touchable = false;
				addChild(_imageSnapShot);
			} else {
				_imageSnapShot.texture.dispose();
				_imageSnapShot.texture = texture;
				_imageSnapShot.readjustSize();
			}
			_imageSnapShot.width = _width-(paddingLeft+paddingRight);
			_imageSnapShot.height = _height-(paddingTop+paddingBottom);
			_imageSnapShot.readjustSize();
			_imageSnapShot.x = paddingLeft;
			_imageSnapShot.y = paddingTop;
			
			_imageSnapShot.alpha = (_stageText.text == _hint)?.2:1;
			
			_textureIsInvalid = false;
		}
		
		override public function invalid():void
		{
			_textureIsInvalid = true;
			super.invalid();
		}
		
		override public function dispose():void
		{
			touchQuad.removeEventListener(TouchEvent.TOUCH, touchProcess);
			touchResponder.removeAllListeners();
			
			Starling.current.removeEventListener(starling.events.Event.CONTEXT3D_CREATE, onContextCreated);

			if (_stageText){
				_stageText.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, onSoftKeyboardActivate);
				_stageText.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE,onSoftKeyboardDeactivate);
				
				_stageText.removeEventListener(flash.events.Event.COMPLETE,onStageTextComplete);
				
				_stageText.removeEventListener(FocusEvent.FOCUS_OUT, focusOutHandler);
				_stageText.removeEventListener(FocusEvent.FOCUS_IN, focusInHandler);
				_stageText.removeEventListener(flash.events.Event.CHANGE, onTextChange);
				_stageText.dispose();
				_stageText = null;
			}
			if(_imageSnapShot){
				removeChild(_imageSnapShot);
				_imageSnapShot.texture.dispose();
				_imageSnapShot.dispose();
				_imageSnapShot = null;
			}
			if (bmpd){
				bmpd.dispose();
				bmpd = null;
			}
		}
		
		public function get stageText():StageText {
			return _stageText;
		}

		override public function render(support:RenderSupport, parentAlpha:Number):void
		{
			if (_invalid){
				touchQuad.width = _width;
				touchQuad.height = _height;
			}
			
			_stageText.viewPort = new Rectangle(Math.round(support.modelViewMatrix.tx + paddingLeft*support.modelViewMatrix.a),
				Math.round(support.modelViewMatrix.ty +paddingTop*support.modelViewMatrix.a),
				Math.round((_width-(paddingLeft+paddingRight))*support.modelViewMatrix.a),
				Math.round((_height-(paddingTop+paddingBottom))*support.modelViewMatrix.d)
			);
			if(_textureIsInvalid && _stageText.stage==null) {
				_stageText.stage = AppDelegate.flashStage;
				
				// wait stagetext complete before drawViewPortToBitmapData to ensure stagetext draw with correct viewport (need for android)
				_stageText.addEventListener(flash.events.Event.COMPLETE,onStageTextComplete);
			}
			if (_bRemoveStageText){
				_stageText.stage = null;
				_bRemoveStageText = false;
			}
			super.render(support, parentAlpha);
		}
		
		private function onStageTextComplete(e:flash.events.Event):void{
			_stageText.removeEventListener(flash.events.Event.COMPLETE,onStageTextComplete);
			createTexture();
			if(_imageSnapShot) _imageSnapShot.visible = true;
			// can't remove stagetext here because it will make application crash on android
			_bRemoveStageText = true;
		}
		
		
		//get/set
		
		public function get paddingRight():int
		{
			return _paddingRight;
		}
		
		public function set paddingRight(value:int):void
		{
			_paddingRight = value;
			invalid();
		}
		public function get hint():String
		{
			return _hint;
		}
		
		public function set hint(value:String):void
		{
			_hint = value;
			invalid();
		}
		public function get paddingLeft():int
		{
			return _paddingLeft;
		}
		
		public function set paddingLeft(value:int):void
		{
			_paddingLeft = value;
			invalid();
		}
		
		public function get paddingBottom():int
		{
			return _paddingBottom;
		}
		
		public function set paddingBottom(value:int):void
		{
			_paddingBottom = value;
			invalid();
		}
		
		public function get paddingTop():int
		{
			return _paddingTop;
		}
		
		public function set paddingTop(value:int):void
		{
			_paddingTop = value;
			invalid();
		}
		
		public function set autoCapitalize(autoCapitalize:String):void
		{
			this._stageText.autoCapitalize = autoCapitalize;
		}
		
		public function set autoCorrect(autoCorrect:Boolean):void
		{
			this._stageText.autoCorrect = autoCorrect;
		}
		
		public function set fontColor(color:uint):void
		{
			this._stageText.color = color;
		}
		
		public function set displayAsPassword(displayAsPassword:Boolean):void
		{
			this._stageText.displayAsPassword = displayAsPassword;
		}
		public function get displayAsPassword():Boolean
		{
			return _stageText.displayAsPassword;
		}
		public function set editable(editable:Boolean):void
		{
			if (editable){
				this.touchQuad.addEventListener(TouchEvent.TOUCH, touchProcess);
			}else{
				this.touchQuad.removeEventListener(TouchEvent.TOUCH, touchProcess);
			}
			this._stageText.editable = editable;
		}
		
		public function set fontFamily(fontFamily:String):void
		{
			this._stageText.fontFamily = fontFamily;
		}
		
		public function set fontPosture(fontPosture:String):void
		{
			this._stageText.fontPosture = fontPosture;
		}
		
		public function set fontSize(fontSize:int):void
		{
			this._stageText.fontSize = fontSize;
			invalid();
		}
		
		public function get fontSize():int
		{
			return this._stageText.fontSize;
		}
		
		public function set fontWeight(fontWeight:String):void
		{
			this._stageText.fontWeight = fontWeight;
		}
		
		public function set locale(locale:String):void
		{
			this._stageText.locale = locale;
		}
		
		public function set maxChars(maxChars:int):void
		{
			this._stageText.maxChars = maxChars;
		}
		public function get maxChars():int
		{
			return _stageText.maxChars;
		}
		public function set restrict(restrict:String):void
		{
			this._stageText.restrict = restrict;
		}
		public function get restrict():String
		{
			return _stageText.restrict;
		}
		public function set returnKeyLabel(returnKeyLabel:String):void
		{
			this._stageText.returnKeyLabel = returnKeyLabel;
		}
		
		public function get selectionActiveIndex():int
		{
			return this._stageText.selectionActiveIndex;
		}
		
		public function get selectionAnchorIndex():int
		{
			return this._stageText.selectionAnchorIndex;
		}
		
		public function set softKeyboardType(softKeyboardType:String):void
		{
			this._stageText.softKeyboardType = softKeyboardType;
		}
		public function get softKeyboardType():String
		{
			return _stageText.softKeyboardType;
		}
		public function set text(text:String):void
		{
			this._stageText.text = text;
		}
		public function get text():String
		{
			return (_stageText.text==_hint) ? "" : _stageText.text;
		}
		public function set textAlign(textAlign:String):void
		{
			this._stageText.textAlign = textAlign;
		}
		
		public override function set visible(value:Boolean):void
		{
			super.visible = value;
			this._stageText.visible = value;
		}
		
		public function get multiline():Boolean
		{
			return this._stageText.multiline;
		}
		
		public function assignFocus():void
		{
			if(_imageSnapShot) _imageSnapShot.visible = false;
			_stageText.stage = AppDelegate.flashStage;
			this._stageText.assignFocus();
		}
		
		public function selectRange(anchorIndex:int, activeIndex:int):void
		{
			this._stageText.selectRange(anchorIndex, activeIndex);
		}
		
		public override function set width(width:Number):void
		{
			this._width = width;	
			invalid();	
		}
		
		public override function get width():Number
		{
			return this._width;
		}
		
		public override function set height(height:Number):void
		{
			_height = height;
			invalid();
		}
		
		public override function get height():Number
		{
			updateIfInvalid();
			return this._height;
		}
		
	}
}