package taven.common
{
import com.greensock.TweenLite;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.StatusEvent;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.text.TextFormat;

public class MenuBar extends MovieClip

	{
		public var body_mc:Sprite;
		private var text_mc:Sprite;	
		private var select_mc:Sprite;
		private var over_mc:Sprite;
		private var line_bitmap:Bitmap;
		
		public var selectTextFormat:TextFormat;
		public var defaultTextFormat:TextFormat;
		public var selectFilters:Array;//选中效果
		public var selectItem:MenuItem;
		private var _lineRect:Rectangle;//分割线区域
		
		private var menuBase:ScaleBitmap;
		private var overBase:ScaleBitmap;
		private var borderBase:ScaleBitmap;
		private var lineBase:ScaleBitmap;
		
		private var menuArray:Array;
		private var _w:Number=0;
		private var _h:Number=0;
		public function MenuBar(_select:Object, _border:Object, _over:Object = null,_divline:Object=null) {
			this.visible = false;
			
			this.body_mc = new Sprite;
			this.body_mc.mouseChildren = false;
			this.body_mc.mouseEnabled = false;
			this.addChild(this.body_mc);
			
			this.select_mc = new Sprite();
			this.addChild(this.select_mc);
			
			this.text_mc = new Sprite;
			this.addChild(this.text_mc);
			
			if (_border is BitmapData) {
				this.borderBase = new ScaleBitmap(_border as BitmapData);
			}else {
				var _borderData:BitmapData = new BitmapData(_border.width, _border.height, true, 0x000000);
				_borderData.draw(_border as DisplayObject);
				this.borderBase = new ScaleBitmap(_borderData);
			}			
			this.borderBase.scale9Grid = new Rectangle((_border.width-1)/2, (_border.height-1)/2, 1, 1);
			this.body_mc.addChild(this.borderBase);
			
			if (_over) {
				this.over_mc = new Sprite();
				this.addChild(this.over_mc);
				
				if (_over is BitmapData) {
					this.overBase = new ScaleBitmap(_over as BitmapData);
				}else {
					var _overData:BitmapData = new BitmapData(_over.width, _over.height, true, 0x000000);
					_overData.draw(_over as DisplayObject);
					this.overBase = new ScaleBitmap(_overData);
				}			
				this.overBase.scale9Grid = new Rectangle((_over.width - 1) / 2, (_over.height - 1) / 2, 1, 1);
				this.overBase.alpha = 0;
				this.body_mc.addChild(this.overBase);	
				this.overBase.mask = this.over_mc;
			}
			
			this.divline(_divline);//分割线
			
			if (_select is BitmapData) {
				this.menuBase = new ScaleBitmap(_select as BitmapData);
			}else {
				var _selectData:BitmapData = new BitmapData(_select.width, _select.height, true, 0x000000);
				_selectData.draw(_select as DisplayObject);
				this.menuBase = new ScaleBitmap(_selectData);
			}			
			this.menuBase.scale9Grid = new Rectangle((_select.width-1)/2, (_select.height-1)/2, 1, 1);
			this.body_mc.addChild(this.menuBase);
			
			this.menuBase.mask = this.select_mc;
			this.addEventListener(MouseEvent.CLICK, _menuClickEvent);
			this.addEventListener(MouseEvent.MOUSE_OVER, _menuOverEvent);
			this.addEventListener(MouseEvent.ROLL_OUT, _menuOutEvent);
		}
		//分割线
		public function divline(_v:Object, _rect:Rectangle = null):void {
			this._lineRect = _rect;
			if (_v) {
				if (_v is BitmapData) {
					this.lineBase = new ScaleBitmap(_v as BitmapData);
				}else {
					var _lineData:BitmapData = new BitmapData(_v.width+2, _v.height, true, 0x000000);
					_lineData.draw(_v as DisplayObject,new Matrix(1, 0, 0, 1, 1));
					this.lineBase = new ScaleBitmap(_lineData);
				}			
				this.lineBase.scale9Grid = new Rectangle(_v.width / 3, _v.height / 3, _v.width / 3, _v.height / 3);
				
				this.line_bitmap = new Bitmap;
				if (this._lineRect) {
					this.line_bitmap.x = this._lineRect.x;
					this.line_bitmap.y = this._lineRect.y;
				}
				this.addChild(this.line_bitmap);
			}else if(this.line_bitmap){
				this.removeChild(this.line_bitmap);
				this.line_bitmap = null;
			}
		}
		private function dispatchEventModule(_code:String,_data:String=""):void {
			this.dispatchEvent(new StatusEvent(StatusEvent.STATUS, false, false, _code, _data));
		}
		//渲染
		private function renderModule():void {
			for (var i:int = 0; i < this.text_mc.numChildren; i++ ) {
				this.text_mc.getChildAt(i).visible = false;
			}
			this.visible = false;
			this._w = 0;
			this._h = 0;
			
			
			if (this.menuArray) {
				if (this.line_bitmap) {
					if(this.line_bitmap.bitmapData){
						this.line_bitmap.bitmapData.dispose();
					}
					if (this._lineRect) {
						this.line_bitmap.bitmapData = new BitmapData(this.borderBase.width, this._lineRect.height, true, 0x000000);
						this.lineBase.height = this._lineRect.height;
					}else{
						this.line_bitmap.bitmapData = new BitmapData(this.borderBase.width, this.borderBase.height, true, 0x000000);
						this.lineBase.height = this.borderBase.height;
					}
				}
				this._w = this.menuBase.width / this.menuArray.length;
				this._h = this.menuBase.height;
				var _item:MenuItem;
				for (i=0; i < this.menuArray.length; i++ ) {
					_item = this.text_mc.getChildByName(this.menuArray[i].name) as MenuItem;
					if(!_item){
						_item = new MenuItem(this.defaultTextFormat);
					}
					_item.visible = true;
					_item.x = _w*i;
					_item.width = _w;
					_item.height = _h;
					_item.text = this.menuArray[i].label;
					_item.name = this.menuArray[i].name;
					this.text_mc.addChild(_item);
					if (i > 0 && this.line_bitmap) {
						this.line_bitmap.bitmapData.draw(this.lineBase, new Matrix(1, 0, 0, 1, _item.x));
					}
				}
				this.visible = true;	
			}
			for (i = 0; i < this.text_mc.numChildren; i++ ) {
				_item = this.text_mc.getChildAt(i) as MenuItem;
				if (_item && !_item.visible) {
					this.text_mc.removeChildAt(i);
					i--;
				}
			}
			this.drawMask();
			
			if (this.overBase) {
				this.drawOver();
			}
			this.dispatchEventModule("render");
		}
		//选中状态
		private function drawMask():void {
			var _g:Graphics = this.select_mc.graphics;
			_g.clear();
			_g.beginFill(0xFFFFFF, 0);
			_g.drawRect(0, 0, this._w,this._h);
			_g.endFill();
		}
		//滑过状态
		private function drawOver():void {
			var _g:Graphics = this.over_mc.graphics;
			_g.clear();
			_g.beginFill(0xFFFFFF, 0);
			_g.drawRect(0, 0, this._w,this._h);
			_g.endFill();
		}
		//菜单数组
		public function set menuData(_ar:Array):void {
			this.menuArray = _ar;
			this.renderModule();
			this.setMenuIndex = 0;
		}
		//设置over状态
		public function set overSprite(_v:Sprite):void {
			if (this.over_mc) {
				this.removeChild(this.over_mc);
				this.over_mc = null;
			}
			if (this.overBase) {
				this.body_mc.removeChild(this.overBase);
				this.overBase = null;
			}
			this.over_mc = _v;
			if(this.over_mc){
				this.over_mc.visible = false;
				this.addChild(this.over_mc);
			}
		}
		//闪烁
		public function trigger(_v:Boolean):void {
			
		}
		//宽、高
		override public function get width():Number 
		{
			return this.menuBase.width;
		}
		
		override public function set width(value:Number):void 
		{
			this.menuBase.width = value;
			if(this.overBase){
				this.overBase.width = value;
			}
			this.borderBase.width = value;
			this.renderModule();
		}
		override public function get height():Number 
		{
			return this.menuBase.height;
		}
		
		override public function set height(value:Number):void 
		{
			this.menuBase.height = value;
			if(this.overBase){
				this.overBase.height = value;
			}
			this.borderBase.height = value;
			this.renderModule();
		}
		
		public function get itemWidth():Number {
			return this._w;
		}
		public function get itemHeight():Number {
			return this._h;
		}
		
		public function set setMenuName(_v:String):void {
			var _item:MenuItem;
			for (var i:int = 0; i < this.text_mc.numChildren; i++ ) {
				_item = this.text_mc.getChildAt(i) as MenuItem;
				if (_item.name==_v) {
					this.selectItem = _item;
					this.renderSelect();
					break;
				}
			}
		}
		public function set setMenuIndex(_v:int):void {
			var _item:MenuItem;
			if(_v<this.text_mc.numChildren){
				_item = this.text_mc.getChildAt(_v) as MenuItem;
				if (_item) {
					this.selectItem = _item;
					this.renderSelect();
				}
			}
		}
		//----------------------
		private function renderSelect():void {
			var _item:MenuItem;
			for (var i:int = 0; i < this.text_mc.numChildren; i++ ) {
				_item = this.text_mc.getChildAt(i) as MenuItem;
				_item.textFormat = this.defaultTextFormat;
				_item.filters = null;
			}
			if(this.selectItem){
				this.selectItem.textFormat = this.selectTextFormat;
				this.selectItem.filters = this.selectFilters;
				this.select_mc.x = this.selectItem.x;
				this.dispatchEventModule("menu", this.selectItem.name);
			}
		}
		private function _menuClickEvent(e:MouseEvent):void {
			if (e.target is MenuItem) {
				if (this.selectItem != e.target) {
					this.selectItem = e.target as MenuItem;
					this.renderSelect();
				}
			}
		}
		private function _menuOverEvent(e:MouseEvent):void {
			if (e.target is MenuItem) {
				if(this.overBase){
					TweenLite.to(this.overBase, .5, { "alpha":1 } )
					TweenLite.to(this.over_mc, .5, { "x":e.target.x } )
				}else if (this.over_mc) {
					this.over_mc.x = e.target.x;
					this.over_mc.visible = true;
				}
			}
		}
		private function _menuOutEvent(e:MouseEvent):void {
			if(this.overBase){
				TweenLite.to(this.overBase, .5, { "alpha":0 } )
			}else if(this.over_mc){
				this.over_mc.visible = false;
			}
		}
	}
}