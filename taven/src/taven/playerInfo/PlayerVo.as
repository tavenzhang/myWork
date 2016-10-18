package taven.playerInfo
{
	import taven.utils.MathUtils;

	public class PlayerVo
	{
		private var _power:int;
		private var _name:String;
		
		private var _useLv:int;
		
		private var _data:Object;
		
		public function PlayerVo(obj:Object)
		{
			_data = obj;
			power = _data.power;
			_name = _data.name;
			level = _data.level;
		}

		/** 1 2 管理员  0是观众*/
		public function get power():int
		{
			return _power;
		}

		/**用户名*/
		public function get name():String
		{
			return _name;
		}

		/**用户等级*/
		public function get level():int
		{
			return _useLv;
		}

		public function set power(value:int):void
		{
			_power = value;
			if(_power!=1&&_power!=2)
			{
				_power =0;
			}
		}

		public function set level(value:int):void
		{
			_useLv = MathUtils.clamp(value,1,31);
		}

		public function get data():Object
		{
			return _data;
		}


	}
}