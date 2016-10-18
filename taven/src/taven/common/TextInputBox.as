package taven.common {

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.system.IME;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;

public class TextInputBox extends MovieClip {
		private var _textFormat:TextFormat = new TextFormat("宋体", 12, 0x000000, false);
		public var input_txt:TextField;
		public var num_txt:TextField;
		public var close_bt:SimpleButton;
		public var send_bt:SimpleButton;
		public function TextInputBox() {
			this.input_txt = new TextField();
			this.input_txt.type = TextFieldType.INPUT;
			this.input_txt.x = 17;
			this.input_txt.y = 42;
			this.input_txt.width = 315;
			this.input_txt.height = 70;
			this.input_txt.defaultTextFormat = this._textFormat;
			this.input_txt.text = "";
			this.input_txt.multiline = false;
			this.input_txt.wordWrap = true;
			this.input_txt.maxChars = 30;
			this.input_txt.addEventListener(Event.CHANGE, _inputChangeEvent);
			this.addChild(this.input_txt);
			
			this.num_txt.text = this.input_txt.maxChars.toString();
			
			this.addEventListener(FocusEvent.FOCUS_IN, _setIMEChinese);//--------输入中文
			this.addEventListener(MouseEvent.CLICK, _clickMouseEvent);
		}
		public function get text():String 
		{
			return this.input_txt.text;
		}
		
		public function set text(value:String):void 
		{
			this.input_txt.text = value;
		}
		//------------------尺寸变化
		private function _setIMEChinese(e:FocusEvent):void {
			this.stage.focus = this.input_txt;
			IME.enabled = true;
		}
		
		private function _inputChangeEvent(e:Event):void {
			this.num_txt.text = (this.input_txt.maxChars-this.input_txt.length).toString();
		}
		
		private function _clickMouseEvent(e:MouseEvent):void {
			switch(e.target) {
				case this.close_bt:
					this.visible = false;
					break;
				case this.send_bt:
					this.dispatchEvent(new Event("inputCompleteEvent"));
					this.visible = false;
					break;
				default:
			}
		}
		override public function get visible():Boolean 
		{
			return super.visible;
		}
		
		override public function set visible(value:Boolean):void 
		{
			if (value) {
				this.input_txt.text = "";
				this.num_txt.text = this.input_txt.maxChars.toString();
			}
			super.visible = value;
		}
	}
	
}
