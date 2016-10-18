package taven.seatView{
import flash.events.Event;
import flash.events.MouseEvent;

import seatsModule.numBoxMc;

public class NumBox extends numBoxMc {
		
		public var coe:int = 20;//系数
		private var _base:int = 0;//基数
		private var _value:int = 1;//当前值
		public function NumBox():void {
			this.addEventListener(MouseEvent.CLICK, _numBoxClickEvent);
		}
		
		private function _numBoxClickEvent(e:MouseEvent):void {
			switch(e.target.name) {
				case "sub_bt":
					this.value--;
					break;
				case "add_bt":
					this.value++;
					break;
				case "submit_bt":
					this.dispatchEvent(new Event("submictEvent"));
					break;
			
				default:
			}
		}
		
		//基数
		public function set value(_v:int):void {
			if (_v<this.base) {
				_v = this.base;
			}
			
			this._value = _v;
			this.num_txt.text = this._value * this.coe+"";
		}
		public function get value():int {
			return this._value;
		}
		//基数
		public function set base(_v:int):void {
			this._base = _v;
			this.value = this._base;
		}
		public function get base():int {
			return this._base;
		}
	}
}