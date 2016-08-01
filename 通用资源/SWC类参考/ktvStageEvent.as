package {//stage通用事件
	import flash.events.Event;
	public class ktvStageEvent extends Event {
		public var data:*;
		public static const KTV_StageEvent:String = "ktvStageEvent";//通用事件
		public function ktvStageEvent(_data:*="",  _type:String = "ktvStageEvent", _bubbles:Boolean = false, _cancelable:Boolean = false):void {
			this.data = _data;
			super(_type,_bubbles,_cancelable);
		}
		
	}
	
}