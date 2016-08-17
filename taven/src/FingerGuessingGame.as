/**
 * Created by roger on 2016/5/18.
 */
package {
import com.greensock.TweenLite;
import com.rover022.IVideoModule;
import com.rover022.IVideoRoom;
import com.rover022.display.IAssetMovieClip;
import com.rover022.event.CBModuleEvent;
import com.rover022.vo.VideoConfig;

import display.ui.Alert;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;

import game.carGame.IGamePane;
import game.fingerGame.BattlePane;
import game.fingerGame.FingerGameRoomVo;
import game.fingerGame.ListPane;
import game.fingerGame.RulePane;
import game.fingerGame.ui.ResPanel;

import net.GameSocket;

[SWF(width=616, height=426)]
public class FingerGuessingGame extends IAssetMovieClip implements IVideoModule {
	public var errorMsg:Array = [];
	//
	private var _rulePane:RulePane;
	private var _listPane:ListPane;
	private var _battlePane:BattlePane;
	//
	public var socket:GameSocket;

	public function FingerGuessingGame() {
		errorMsg[0]   = "失败";
		errorMsg[2]   = "系统异常";
		errorMsg[3]   = "参数错误";
		errorMsg[101] = "您的余额不足";
		errorMsg[102] = "游戏已结束";
		errorMsg[111] = "您已经发起划拳游戏,待游戏完毕后再发起新游戏";
		errorMsg[112] = "您已经参与划拳游戏,待游戏完毕后再发起新游戏";
		errorMsg[121] = "参与游戏失败,该游戏已过期";
		errorMsg[122] = "参与游戏失败,已经有用户参与 ";
		errorMsg[123] = "参与游戏失败,您已经发起划拳游戏,待游戏完毕后再参与游戏 ";
		errorMsg[124] = "参与游戏失败,您已经参与划拳游戏,待游戏完毕后再参与游戏";
		//setInterval(update, 1000);
		addEventListener(Event.ADDED_TO_STAGE, onAddStage);
		//
		createRunTextField();
	}

	private function onAddStage(event:Event):void {
		var f:Number = (stage.stageHeight - 440);
		TweenLite.to(this, 0.5, {y: f});
		removeEventListener(Event.ADDED_TO_STAGE, onAddStage);
		loaderAsset(VideoConfig.HTTP + "Modules/skin/FingerGuessingGameSkin.swf");
		stage.addEventListener(CBModuleEvent.RECONNECT_SOCKET, onreconnectSocket);
		//for test
//		flash.utils.setInterval(function () {
//			var obj:Object = JSON.parse('{"icon":0,"car":0,"type":11,"richLv":0,"recName":"","cmd":30001,"recUid":0,"sendName":"admin","recHidden":0,"sendUid":10000,"date":"2016-06-28 15:29:38","recLv":1,"lv":1,"vip":0,"recIcon":0,"sendHidden":0,"content":"恭喜【3145508】在划拳游戏中获得：1800 钻石"}');
//			setRunTextField(obj.content);
//		}, 5000);
	}

	public function loadSocketConfig():void {
		var urlLoader:URLLoader = new URLLoader();
		urlLoader.load(new URLRequest(VideoConfig.httpTomcat + "/video_gs/fingerServer?rid=" + VideoConfig.roomID + "&time=" + Math.random()));
		urlLoader.addEventListener(Event.COMPLETE, onSocketConfigLoadComplete);
		urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIoErrorHandle);
	}

	private function onSocketConfigLoadComplete(event:Event):void {
		var dataString:String = (event.currentTarget as URLLoader).data;
		var obj:Object        = JSON.parse(dataString);
		if (obj.ret == 1) {
			var hostArray:Array = String(obj.host).split(",");
			var port:int        = obj.port;
			initSockect(hostArray, port);
		}
	}

	private function onIoErrorHandle(event:IOErrorEvent):void {
		trace("游戏从tomcat获取socket地址链接不对");
		//
		trace("进入测试模式");
		//
		//
		var obj:Object      = JSON.parse('{"ret":1,"host":"10.1.100.104,10.1.100.113","port":1350}');
		var hostArray:Array = String(obj.host).split(",");
		var port:int        = obj.port;
		initSockect(hostArray, port);
	}

	private function onreconnectSocket(event:CBModuleEvent):void {
		if (socket) {
			socket.destroy();
		}
		showGameinfor();
	}

	public function set videoRoom(src:IVideoRoom):void {
	}

	public function get videoRoom():IVideoRoom {
		return null;
	}

	public function listNotificationInterests():Array {
		return [61001, 61002, 61003, 61004, 61005, 61006, 61007, 30001, 10001];
	}

	public function handleNotification(src:Object):void {
		var _vo:FingerGameRoomVo;
		if (src.ret != null && src.cmd != 10001) {
			if (src.ret != 1) {
				Alert.Show(errorMsg[src.ret]);
				return;
			}
		}
		switch (src.cmd) {
			case 10001:
				_rulePane.setanPress(true);
				break;
			case 61001:
				for (var i:int = src.items.length - 1; i >= 0; i--) {
					var _obj:Object = src.items[i];
					_vo             = FingerGameRoomVo.makeVo(_obj);
					_listPane.addRoom(_vo);
				}
				break;
			case 61002:
				break;
			case 61003:
				if (_listPane) {
					_vo = FingerGameRoomVo.makeVo(src);
					_listPane.addRoom(_vo);
				}
				break;
			case 61004:
				showGameRoom(src);
				break;
			case 61005:
				if (_listPane) {
					_listPane.removeRoomByID(src.gameId)
				}
				break;
			case 61007:
				_battlePane.showResult(src.items);
				break;
			case 30001:
				//{"icon":0,"car":0,"type":11,"richLv":0,"recName":"","cmd":30001,"recUid":0,"sendName":"admin","recHidden":0,"sendUid":10000,"date":"2016-06-28 15:29:38","recLv":1,"lv":1,"vip":0,"recIcon":0,"sendHidden":0,"content":"恭喜【3145508】在划拳游戏中获得：1800 钻石"}
				if (src.type == 11) {
					message = src.content;
					setRunTextField(message)
				}
		}
	}

	public function initSockect(hostArray:Array, port:int):void {
		socket        = new GameSocket(hostArray, port);
		socket.module = this;
		socket.startConnect();
		socket.addEventListener(Event.CLOSE, onSocketClose);
	}

	private function onSocketClose(event:Event):void {
		var reSetPane:ResPanel = new ResPanel();
		addChild(reSetPane);
	}

	override public function onViewDidLoad(event:Event):void {
		super.onViewDidLoad(event);
		setCanDrage(560);
		showGameinfor();
	}

	public function showGameinfor():void {
		_listPane   = null;
		_battlePane = null;
		//
		_rulePane   = new RulePane();
		popView(_rulePane);
		loadSocketConfig();
	}

	public function showGameRoomList():void {
		if (_listPane == null) {
			_listPane = new ListPane();
		}
		popView(_listPane);
	}

	public function showGameRoom(obj:Object):void {
		if (_battlePane == null) {
			_battlePane = new BattlePane();
		}
		popView(_battlePane);
		//
		_battlePane.setData(obj);
	}

	public function popView(src:Sprite):void {
		view.removeChildren();
		view.addChild(src);
		src.alpha = 0;
		setRunTextField(message);
		TweenLite.to(src, .3, {alpha: 1});
	}
}
}
