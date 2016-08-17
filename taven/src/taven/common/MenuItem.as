package taven.common
{
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

public class MenuItem extends MovieClip
	{		
		private var _defaultTextFormat:TextFormat;
		private var _txt:TextField;
		private var _w:Number=0;
		private var _h:Number = 0;
		private var mask_mc:Sprite;
		public function MenuItem(_textFormat:TextFormat=null) {
			this.mouseChildren = false;
			if (_textFormat) {
				this._defaultTextFormat = _textFormat;
			}else {
				this._defaultTextFormat = new TextFormat("宋体",12,0x000000,null,null,null,null,null,TextFormatAlign.CENTER);
			}
			
			this._txt = new TextField();
			this._txt.wordWrap = false;
			this._txt.multiline = false;
			this._txt.mouseEnabled = false;
			this._txt.defaultTextFormat = this._defaultTextFormat;
			this.addChild(this._txt);
			this.mask_mc = new Sprite();
			this.addChild(this.mask_mc);
			this._txt.mask = this.mask_mc;
		}
		private function drawGraphics(_spr:Sprite):void {
			var _g:Graphics = _spr.graphics;
			_g.clear();
			_g.beginFill(0xFFFFFF, 0);
			_g.drawRect(0, 0, this._w, this._h);
			_g.endFill();	
		}
		public function renderModule():void {
			this.drawGraphics(this);
			this.drawGraphics(this.mask_mc);
		
			this._txt.width = this._w;
			this._txt.height = this._h;
			this._txt.y = (this._h - this._txt.textHeight)/2;
		}
		//文本
		public function set text(_v:String):void {
			this._txt.text = _v;
			this._txt.y = int(this._h - this._txt.textHeight)/2-2;
		}
		public function get text():String {
			return this._txt.text;
		}
		
		public function set textFormat(_v:TextFormat):void {
			if (_v) {
				this._txt.defaultTextFormat = _v;
				this._txt.setTextFormat(_v);
			}else {
				this._txt.defaultTextFormat = this._defaultTextFormat;
				this._txt.setTextFormat(this._defaultTextFormat);
			}
		}
		//宽、高
		override public function get width():Number 
		{
			return this._w;
		}
		
		override public function set width(value:Number):void 
		{
			this._w = value;
			this.renderModule();
		}
		override public function get height():Number 
		{
			return this._h;
		}
		
		override public function set height(value:Number):void 
		{
			this._h = value;
			this.renderModule();
		}
	}
}