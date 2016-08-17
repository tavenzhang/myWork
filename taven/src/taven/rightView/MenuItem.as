package taven.rightView{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	public class MenuItem extends Sprite {
		private var txt:TextField;
		public var label:String;
		public var data:*;
		private var overSpr:Sprite;
		public function MenuItem():void {
			this.mouseChildren = false;
			
			this.overSpr = new Sprite;
			this.overSpr.visible = false;
			this.addChild(this.overSpr);
			
			this.txt = new TextField;
			this.txt.autoSize = "left";
			this.txt.x = 10;
			this.txt.y = 8;
			this.txt.height = 18;
			this.txt.mouseEnabled = false;
			this.txt.textColor = 0xa8cce1;
			this.addChild(this.txt);
			this.addEventListener(MouseEvent.ROLL_OVER, _itemOverEvent);
			this.addEventListener(MouseEvent.ROLL_OUT, _itemOutEvent);
		}
		public function formatItem(_obj:Object):void {
			this.graphics.clear();
			this.graphics.endFill();
			this.overSpr.graphics.clear();
			this.overSpr.graphics.endFill();

			this.label = _obj.label;
			this.data = _obj.data;
			this.txt.text = this.label;
		}
		public function renderGraphics(_w:int):void {
			this.graphics.clear();
			this.graphics.beginFill(0x000000,0);
			this.graphics.drawRect(0, 0, 200, 36);
			this.graphics.lineStyle(1, 0x2e3b44,.5);
			this.graphics.moveTo(0, 0);
			this.graphics.lineTo(194, 0);
			this.graphics.endFill();
			
			this.overSpr.graphics.clear();
			this.overSpr.graphics.beginFill(0x3d5e73);
			this.overSpr.graphics.drawRect(0, 1,194, 36);
			this.overSpr.graphics.endFill();
		}
		private function _itemOverEvent(e:MouseEvent):void {
			this.overSpr.visible = true;
		}
		private function _itemOutEvent(e:MouseEvent):void {
			this.overSpr.visible = false;
		}
		public function gc():void {
			this.removeEventListener(MouseEvent.ROLL_OVER, _itemOverEvent);
			this.removeEventListener(MouseEvent.ROLL_OUT, _itemOutEvent);
			while (this.numChildren > 0) {
				this.removeChildAt(0);
			}
			this.txt = null;
			this.overSpr = null;
		}
	}
}