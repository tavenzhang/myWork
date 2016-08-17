package taven.common {

import flash.events.StatusEvent;
import flash.text.TextFormat;

public class RightMenu extends rightMenuMc {
		
		private var menuBar_mc:MenuBar;
		public function RightMenu() {
			this.menuBar_mc = new MenuBar(new baseRedSelectMc(), new baseRedBorderMc());
			this.menuBar_mc.defaultTextFormat = new TextFormat("宋体", 14, 0xddaa99, true, null, null, null, null, "center");
			this.menuBar_mc.selectTextFormat = new TextFormat("宋体", 14, 0xFFFFFF, true, null, null, null, null, "center");
			this.menuBar_mc.buttonMode = true;
			this.menuBar_mc.addEventListener(StatusEvent.STATUS,_statusEvent);
			this.addChild(this.menuBar_mc);
		}
		public function set menuData(_ar:Array):void {
			this.menuBar_mc.menuData = _ar;
		}
		override public function get width():Number 
		{
			return this.menuBar_mc.width;
		}
		
		override public function set width(value:Number):void 
		{
			this.menuBar_mc.width = value;
		}
		override public function get height():Number 
		{
			return this.menuBar_mc.height;
		}
		
		override public function set height(value:Number):void 
		{
			this.menuBar_mc.height = value;
		}
		private function dispatchEventModule(_code:String,_data:String=""):void {
			this.dispatchEvent(new StatusEvent(StatusEvent.STATUS, false, false, _code, _data));
		}
		private function _statusEvent(e:StatusEvent):void {
			this.dispatchEventModule(e.code, e.level);
		}
		
	}
	
}
