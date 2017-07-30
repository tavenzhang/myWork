package com.rover022.vo
{
	public class RespondVo
	{
		
		private var _cmdId:uint;

		public function get hanldeFuc():Function
		{
			return _hanldeFuc;
		}
		/*命令id*/
		public function get cmdId():uint
		{
			return _cmdId;
		}
		/*命令回调函数*/
		private var _hanldeFuc:Function;
		public function RespondVo(cmdId:uint,hanldeFuc:Function)
		{
			_cmdId = cmdId;
			_hanldeFuc = hanldeFuc;
		}
		
		public function destroy():void
		{
			_hanldeFuc = null;
			_cmdId = 0;
		}
	}
}