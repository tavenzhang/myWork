package shareElement{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;


	public class autoTextField extends MovieClip {
		public var txt:TextField;
		public var border_mc:MovieClip;
		public function autoTextField():void {
			this.txt.mouseEnabled = false;
			this.txt.autoSize = TextFieldAutoSize.LEFT;
			this.txt.wordWrap = false;
		}
		public function set text(_v:String):void {
			this.txt.text = _v;
			
			this.border_mc.width = this.txt.width + 4;
			this.border_mc.height = this.txt.height + 2;
		}
		public function get text():String {
			return this.txt.text;
		}
	}
}