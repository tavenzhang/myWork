/**
 * Created by roger on 2016/6/14.
 */
package game.fingerGame {
public dynamic class FingerGameRoomVo {
	public var gameId:int;
	public var sendUid:String;
	public var sendName:String;
	public var createTime:Number;
	public var points:Number;
	public var status:String;
	public var time:Number;

	public function FingerGameRoomVo() {
	}

	public static function makeVo(src:Object):FingerGameRoomVo {
		var vo:FingerGameRoomVo = new FingerGameRoomVo();
		for (var _name:String in src) {
			vo[_name] = src[_name];
		}
		return vo;
	}
}
}
