package taven.flyScreen
{
	

	public class MessageVo
	{
		private var _message:String;
		
		private var _time:uint;
		
		public function MessageVo(messageStr:String,timeNum:uint)
		{
			message = messageStr;
			time=timeNum;
		}
		
		
		public function get time():uint
		{
			return _time;
		}

		public function set time(value:uint):void
		{
			_time = value;
		}

		public function get message():String
		{
			return _message;
		}

		public function set message(value:String):void
		{
			_message = value;
		}

	}
}