package shareElement{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Rectangle;
	public class scrollShare extends MovieClip {
		public var thumb_mc:MovieClip;
		public var track_mc:MovieClip;
		private var _thumb:scaleSprite;
		private var _track:scaleSprite;
		private var _scroll:baseScroll;
		public function scrollShare():void {
			//轨道元件
			this._track=new scaleSprite(this.track_mc);
			this._track.scale9Grid = new Rectangle(4, 10, 4, 10);
			this._track.height = 100;			
			//滑块元件
			this._thumb=new scaleSprite(this.thumb_mc);
			this._thumb.scale9Grid = new Rectangle(4, 10, 4, 10);
			
			this._scroll = new baseScroll(this._thumb, this._track);
			this._scroll.buttonMode=true;//设置手手型
			this._scroll.addEventListener(Event.SCROLL, _scrollEvent);//滚动事件
			this._scroll.addEventListener("scrollFalse", _scrollFalseEvent);//隐藏事件
			this._scroll.addEventListener("scrollTrue", _scrollTrueEvent);//显示事件
			//this._scroll.step = 0;
		}
		//*
		private function _scrollEvent(e:Event){
			this.dispatchEvent(new Event(Event.SCROLL));
		}
		private function _scrollFalseEvent(e:Event){
			this.visible=false;
		}
		private function _scrollTrueEvent(e:Event){
			this.visible=true;
		}
		
		//-----------------------public
		//*step
		public function get step():int 
		{
			return this._scroll.step;
		}
		
		public function set step(value:int):void 
		{
			this._scroll.step = value;
		}
		//*value
		public function get value():Number 
		{
			return this._scroll.value;
		}
		
		public function set value(value:Number):void 
		{
			this._scroll.value = value;
		}
		//*autoScale
		public function get autoScale():Boolean 
		{
			return this._scroll.autoScale;
		}
		
		public function set autoScale(value:Boolean):void 
		{
			this._scroll.autoScale = value;
		}
		//*buttonMode
		override public function get buttonMode():Boolean 
		{
			return this._scroll.buttonMode;
		}
		
		override public function set buttonMode(value:Boolean):void 
		{
			this._scroll.buttonMode = value;
		}
		//*height
		override public function get height():Number 
		{
			return this._scroll.height;
		}
		
		override public function set height(value:Number):void 
		{
			this._scroll.height = value;
		}
	}
}