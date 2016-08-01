package {//通用事件
	import flash.events.Event;
	public class ktvEvent extends Event {
		public var data:*;
		public var dataObject:Object;
		public static const KTV_TypeEvent:String = "ktvObjectEvent";//通用事件
		public static const KTV_DataEvent:String = "ktvDataEvent";//通用数据事件
		public static const KTV_MenuEvent:String = "ktvMenuEvent";//主菜单
		public static const KTV_IconEvent:String = "ktvIocnEvent";//图标栏
		public static const KTV_MouseEvent:String = "ktvMouseEvent";//鼠标事件
		public function ktvEvent(_dataObject:Object = null, _data:*= null, _type:String= "ktvObjectEvent", _bubbles:Boolean = false, _cancelable:Boolean = false):void {
			this.data = _data;
			this.dataObject = _dataObject;
			super(_type,_bubbles,_cancelable);
		}
	}
}