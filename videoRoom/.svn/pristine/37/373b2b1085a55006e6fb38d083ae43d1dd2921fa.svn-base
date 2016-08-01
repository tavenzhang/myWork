package  {
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.Timer;
	public class baseScroll extends Sprite {		
		protected var rect:Rectangle = null;//Thumb滑动区域	
		protected var _oldY:int = 0;//滑块运动判断
		protected var incre:int = 0;//增量
		protected var increBool:Boolean = true;//区分增量是加是减
		protected var time:Timer = null;//增加增量
		
		protected var _value:int = 0;//当前值
		protected var _step:int = 0;//总长度
		protected var _buttonMode:Boolean = false;//手形
		protected var _autoScale:Boolean = false;//自动缩放
		protected var _stepNum:int = 1;//步进值
		protected var _oldValue:int = 0;//原始value值
		protected var _minScale:int = 10;//最小缩小数值
		protected var _maxScale:int = 0;//最大放大数值
		
		public var Thumb:Sprite = null;//滑块
		public var Track:Sprite = null;//轨迹
		public var trackRect:Rectangle;//轨迹区域(没有Track时使用)
		public var UpButton:SimpleButton = null;//向上按钮
		public var DownButton:SimpleButton = null;//身下按钮
		public var scaleMinValue:int = 10;//缩放最小值
		private var _initH:Number = 0;//原始高
		private var _nowH:Number = 0;//当前高
		public function baseScroll(thumb:Sprite = null, track:Sprite = null, rect:Rectangle = null, upButton:SimpleButton = null, downButton:SimpleButton = null):void {
			this.formatBaseScroll(thumb, track, rect, upButton, downButton);
		}	
		protected function formatBaseScroll(thumb:Sprite = null, track:Sprite = null, rect:Rectangle = null, upButton:SimpleButton = null, downButton:SimpleButton = null):void {
			if (thumb) {
				this.Thumb = thumb;	
			}
			if (track) {
				this.Track = track;	
				this._initH = this.Track.height;
			}
			if (rect) {
				this.trackRect = rect;	
				this._initH = this.trackRect.height;
			}
			if (upButton) {
				this.UpButton = upButton;	
			}
			if (downButton) {
				this.DownButton = downButton;	
			}
			if (this.Thumb && (this.Track || this.trackRect)&&!this.rect) { 
				this.initRectangle();
			}
			
			this._nowH = this._initH;
		}
		public static function initBaseScroll(thumb:Sprite = null,track:Sprite = null,rect:Rectangle=null,upButton:SimpleButton = null,downButton:SimpleButton = null):baseScroll {
			return new baseScroll(thumb, track, rect, upButton, downButton);
		}
		public static function initBaseScrollObject(_owern:Sprite,rect:Rectangle=null):baseScroll {
			return new baseScroll(_owern.getChildByName("Thumb") as Sprite, _owern.getChildByName("Track") as Sprite, rect,_owern.getChildByName("UpButton") as SimpleButton, _owern.getChildByName("DownButton") as SimpleButton);
		}
		
		protected  function initRectangle():void {
			if (this.Thumb && (this.Track || this.trackRect)) {
				this.Thumb.buttonMode = false;
				for (var i:int = 0; i < this.Thumb.numChildren; i++ ) {
					if (this.Thumb.getChildAt(i) is SimpleButton) {
						SimpleButton(this.Thumb.getChildAt(i)).useHandCursor = false;
					}
				}	
				
				if (this.Track) {//如果有轨道用轨道
					this.rect = new Rectangle(this.Thumb.x, this.Track.y, 0, this.Track.height-this.Thumb.height);
					this.trackRect=this.rect.clone();
					this.trackRect.height+=this.Thumb.height;//加上滑块的高度
				}else {//没有轨道就用轨道区域
					this.rect = this.trackRect.clone();
					this.rect.height -= this.Thumb.height;//去除滑块的高度
				}
				
				this.Thumb.addEventListener(MouseEvent.MOUSE_DOWN, _downThumbEvent);
				this.Thumb.addEventListener(MouseEvent.MOUSE_UP, _upThumbEvent);	
				this.Thumb.y = this.rect.y;
				
				if (this.UpButton) {
					this.UpButton.addEventListener(MouseEvent.MOUSE_DOWN, _downUpEvent);
				}
				if (this.DownButton) {
					this.DownButton.addEventListener(MouseEvent.MOUSE_DOWN, _downDownEvent);
				}
				if (this.UpButton || this.DownButton) {
					this.time = new Timer(600);
					this.time.addEventListener(TimerEvent.TIMER, _timeEvent);
				}
			}
		}
		
		protected  function _downThumbEvent(e:MouseEvent):void {
			this.Thumb.startDrag(false, this.rect);
			this.Thumb.addEventListener(Event.ENTER_FRAME, _thumbEnterEvent);
			if (this.Thumb.root) {
				this.Thumb.root.addEventListener(MouseEvent.MOUSE_UP, _upThumbEvent);
				this.Thumb.root.addEventListener(MouseEvent.ROLL_OUT, _upThumbEvent);
			}
		}
		protected  function _upThumbEvent(e:MouseEvent):void {
			this.Thumb.stopDrag();	
			this.Thumb.removeEventListener(Event.ENTER_FRAME, _thumbEnterEvent);
			if (this.Thumb.root) {
				this.Thumb.root.removeEventListener(MouseEvent.MOUSE_UP, _upThumbEvent);
				this.Thumb.root.removeEventListener(MouseEvent.ROLL_OUT, _upThumbEvent);
			}
		}
		public  function _thumbEnterEvent(e:Event = null):void {
			if (this._oldY != Math.floor(this.Thumb.y)) {
				this.dealWith();
				this._oldY = Math.floor(this.Thumb.y);
			}
		}
		//------------------------------
		protected  function dealWith():void {
			this._value = Math.round(Math.floor(this.Thumb.y - this.rect.y) / this.rect.height * this._step);
			if (this._oldValue != this._value) {
				this.dispatchEvent(new Event(Event.SCROLL));
			}
			this._oldValue = this._value;
		}		
		protected  function pointSrcoll():void {
			var _nowY:Number = this._value / this._step * this.rect.height + this.rect.y;
			if (isNaN(_nowY)) {
				_nowY = this.rect.y;
			}
			this.Thumb.y = _nowY;
		}
		
		
		//----------------上下按钮
		protected  function _downUpEvent(e:MouseEvent):void {
			this.UpButton.addEventListener(MouseEvent.MOUSE_UP, _upUpEvent);
			this.UpButton.addEventListener(MouseEvent.ROLL_OUT, _upUpEvent);
					
			this.incre = this._stepNum;
			this.increBool = false;
			this.time.delay = 600;
			
			this.time.start();
		}
		protected  function _upUpEvent(e:MouseEvent):void {
			this.UpButton.removeEventListener(MouseEvent.MOUSE_UP, _upUpEvent);
			this.UpButton.removeEventListener(MouseEvent.ROLL_OUT, _upUpEvent);
			
			this.time.stop();
			this.value -= this._stepNum;
		}
		//*下按钮,增加
		protected  function _downDownEvent(e:MouseEvent):void {
			this.DownButton.addEventListener(MouseEvent.MOUSE_UP, _upDownEvent);
			this.DownButton.addEventListener(MouseEvent.ROLL_OUT, _upDownEvent);
					
			this.incre = int(this._stepNum);
			this.increBool = true
			this.time.delay = 600;
			
			this.time.start();
		}
		protected  function _upDownEvent(e:MouseEvent):void {
			this.DownButton.removeEventListener(MouseEvent.MOUSE_UP, _upDownEvent);
			this.DownButton.removeEventListener(MouseEvent.ROLL_OUT, _upDownEvent);
			this.time.stop();
			this.value += this._stepNum;
		}

		protected  function _timeEvent(e:TimerEvent):void {
			this.time.delay = 20;
			this.incre += this._stepNum;
			if (this.incre > 20) {
				this.incre = 20;
			}
			if (this.increBool) {
				this.value += this.incre;				
			}else {
				this.value -=this.incre;
			}
		}		
		
		//-----------------------
		//属性
		//*数值
		public  function set value(_v:int):void {
			if (_v < 0) {
				_v = 0;
			}else if (_v >this.step){
				_v = this.step;
			}
			this._value = _v;
			
			this.pointSrcoll();			
			if (this._oldValue!=this._value) {
				this.dispatchEvent(new Event(Event.SCROLL));
			}
			this._oldValue = this._value;
		}
		public  function get value():int {
			return this._value;
		}
		//*步长
		public  function set step(_v:int):void {
			if (_v < 0) {
				_v = 0;
			}
			this._step = _v;
			this.dispatchEvent(new Event("scrollStep"));
			
			if (this._step == 0) {
				this.value = 0;
				this.Thumb.visible = false;
				if (!this.Thumb.visible) {
					this.dispatchEvent(new Event("scrollFalse"));
				}
			}else {
				this.Thumb.visible = true;
				this.scaleMode();
				if (this.Thumb.visible) {
					this.dispatchEvent(new Event("scrollTrue"));
				}
			}
		}
		public  function get step():int {
			return this._step;
		}
		//*按钮步长
		public  function set stepNum(_v:int):void {
			if (_v < 1) {
				_v = 1;
			}
			this._stepNum = _v;
		}
		public  function get stepNum():int {
			return this._stepNum;
		}
		//鼠标模式
		public override function set buttonMode(_v:Boolean):void {
			this._buttonMode = _v;
			this.Thumb?this.Thumb.buttonMode = this._buttonMode:0;
			this.UpButton?this.UpButton.useHandCursor = this._buttonMode:0;
			this.DownButton?this.DownButton.useHandCursor = this._buttonMode:0;
		}
		public override function get buttonMode():Boolean {
			return this._buttonMode;
		}
		//自动缩放
		public  function set autoScale(_v:Boolean):void {
			this._autoScale = _v;
			if(_v){//自动缩放
				this.scaleMode();
			}else {//不缩放
				if (this.Thumb.getChildByName("ThumbBg")) {
					this.Thumb.getChildByName("ThumbBg").scaleY = 1;
				}else{
					this.Thumb.scaleY = 1;
				}
				this.rect.height = this.trackRect.height - this.Thumb.height;
			}
		}
		public  function get autoScale():Boolean {
			return this._autoScale;
		}
		protected  function scaleMode():void {
			if (this.rect&&this._autoScale) {
				var num:int = int(this.trackRect.height - this.step*.1);//高度不断增加
				if (num < int(this.trackRect.height)) {
					if (this.Thumb.getChildByName("ThumbBg")) {
						this.Thumb.getChildByName("ThumbBg").height = num < this.scaleMinValue?this.scaleMinValue:num;
					}else{
						this.Thumb.height = num < this.scaleMinValue?this.scaleMinValue:num;
					}
					this.rect.height = this.trackRect.height - this.Thumb.height;
				}
			}
		}
		//覆写
		override public function get height():Number 
		{
			return this._nowH;
		}
		
		override public function set height(value:Number):void 
		{
			this.rect.height = value-this.Thumb.height;
			this.trackRect.height = value;
			
			if (this.Track) {
				this.Track.height = value;
			}
			
			this._nowH = value;
			this.pointSrcoll();
		}
		//----------------
		public function reSet():void {
			this.height = this._initH;
			if (this.step > 0) {
				this.value = 0;
			}else{
				this.step = 0;
			}
		}
		public function gc():void {
			try{
				if (this.time) {
					this.time.stop();
					this.time.removeEventListener(TimerEvent.TIMER, _timeEvent);
				}
				
				if (this.Thumb) {
					this.Thumb.removeEventListener(MouseEvent.MOUSE_DOWN, _downThumbEvent);
					this.Thumb.removeEventListener(MouseEvent.MOUSE_UP, _upThumbEvent);
					if (this.Thumb.root) {
						this.Thumb.root.removeEventListener(MouseEvent.MOUSE_UP, _upThumbEvent);
						this.Thumb.root.removeEventListener(MouseEvent.ROLL_OUT, _upThumbEvent);
					}
				}				
					
				if (this.UpButton) {
					this.UpButton.removeEventListener(MouseEvent.MOUSE_DOWN, _downUpEvent);
					this.UpButton.removeEventListener(MouseEvent.MOUSE_UP, _upUpEvent);
					this.UpButton.removeEventListener(MouseEvent.ROLL_OUT, _upUpEvent);
				}
				if (this.DownButton) {
					this.DownButton.removeEventListener(MouseEvent.MOUSE_DOWN, _downDownEvent);
					this.DownButton.removeEventListener(MouseEvent.MOUSE_UP, _upDownEvent);
					this.DownButton.removeEventListener(MouseEvent.ROLL_OUT, _upDownEvent);
				}
			}catch (e:*) {
			}
			this.rect = null;
			this.time = null;
			
			this.Thumb = null;
			this.Track = null;
			this.trackRect = null;
			this.UpButton = null;
			this.DownButton = null;
		}
	}
}