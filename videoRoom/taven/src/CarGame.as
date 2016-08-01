/**
 * Created by Administrator on 2015/7/7.
 */
package {
import com.greensock.TweenLite;
import com.rover022.IVideoModule;
import com.rover022.IVideoRoom;
import com.rover022.ModuleNameType;
import com.rover022.display.IAssetMovieClip;
import com.rover022.vo.VideoConfig;

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.net.SharedObject;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.utils.Dictionary;
import flash.utils.Timer;
import flash.utils.setInterval;

import game.carGame.GameBetAndRunUI;
import game.carGame.GameInfor;
import game.carGame.GameReadyUI;
import game.carGame.GameWaitUI;
import game.carGame.IGamePane;
import game.tool.RunTool;

[SWF(width=750, height=400)]
public class CarGame extends IAssetMovieClip implements IVideoModule {
	private var _viewRoom:IVideoRoom;
	public var GAMEREADY:String            = "GAMEREADY";
	public var GAMESUSERBET:String         = "GAMESUSERBET";
	public var GAMESTART:String            = "GAMESTART";
	private var _state:String;
	private var gameReadyUI:GameReadyUI;
	private var gameBitUI:GameBetAndRunUI;
	private var initialized:Boolean        = false;
	public var gameTimer:Timer;
	public var currentPane:IGamePane;
	public var errorMsg:Dictionary         = new Dictionary();
	public var alwaysShowGameInfor:Boolean = true;
	private var gameMsg:String             = "";
	public static const animals:Array      = [0, 1];

	public function CarGame() {
		errorMsg[2104] = "当前时间不能抢庄";
		errorMsg[2105] = "抢庄倍数不对";
		errorMsg[2106] = "当前时间不能下注";
		errorMsg[2107] = "庄家不能下注";
		errorMsg[2108] = "下注金额超过赔付额";
		errorMsg[2114] = "用户钻石不足";
		errorMsg[-1]   = "用户金额不足";
		loaderAsset(VideoConfig.HTTP + "Modules/skin/carGameSkin.swf");
		addEventListener(Event.ADDED_TO_STAGE, onAddStageHandle);
		createRunTextField(34, 458);
//		//
//		flash.utils.setInterval(function () {
//			setRunTextField("11111111111111111111");
//		}, 2000)
	}

	private function onAddStageHandle(event:Event):void {
		var f:Number = (stage.stageHeight - 550);
		TweenLite.to(this, 0.5, {y: f});
	}

	override public function onViewDidLoad(event:Event):void {
		super.onViewDidLoad(event);
		setCanDrage();
		var so:SharedObject = SharedObject.getLocal("gamedata", "/");
//        trace("so.data.alwaysShowGameInfor", so.data.alwaysShowGameInfor);
		if (so.data.alwaysShowGameInfor != undefined) {
			alwaysShowGameInfor = so.data.alwaysShowGameInfor;
		}
		if (VideoConfig.isShowGameHelp && alwaysShowGameInfor) {
			//如果后台开启 且 用户自己配置也开启 才显示
			showGameinfor();
		} else {
			initUI();
		}
	}

	public function get uid():uint {
		return videoRoom.getDataByName(ModuleNameType.USERDATA).uid;
	}

	public function get rid():uint {
		return videoRoom.getDataByName(ModuleNameType.USERROOMDATA).roomid;
	}

	public function showGameinfor():void {
		new GameInfor(this).active();
	}

	public function initUI():void {
		popView(new GameWaitUI(this));
		initialized = true;
		//
		gameReadyUI = new GameReadyUI(this);
		gameBitUI   = new GameBetAndRunUI(this);
		//初始化主场景;
		gameTimer   = new Timer(1000, 0);
		gameTimer.addEventListener(TimerEvent.TIMER, onUpdateHandle);
		gameTimer.start();
	}

	private function onUpdateHandle(event:TimerEvent):void {
		if (currentPane) {
			currentPane.updateTime();
		}
	}

	public function set videoRoom(src:IVideoRoom):void {
		_viewRoom = src;
	}

	public function get videoRoom():IVideoRoom {
		return _viewRoom;
	}

	public function get state():String {
		return _state;
	}

	public function set state(value:String):void {
		_state = value;
		//trace("游戏状态..", state);
		if (gameReadyUI == null) {
			return;
		}
		switch (value) {
			case GAMEREADY:
				popView(gameReadyUI);
				gameReadyUI.init();
				break;
			case GAMESUSERBET:
				popView(gameBitUI);
				gameBitUI.initBit();
				break;
			case GAMESTART:
				popView(gameBitUI);
				gameBitUI.initRun();
				break
		}
	}

	public function popView(src:IGamePane):void {
		if (currentPane) {
			currentPane.removeFromSuperview();
		}
		currentPane = src;
		addChildAt(currentPane, 0);
		src.alpha = 0;
		TweenLite.to(src, .3, {alpha: 1});
		setRunTextField(gameMsg);
	}

	//#############################################收到通知消息################################################
	public function listNotificationInterests():Array {
		return [60001, 60002, 60003, 60004, 60005, 30001];
	}

	public function handleNotification(src:Object):void {
		if (!initialized) {
			return;
		}
		switch (src.cmd) {
			case 60001:
				gameReadyUI.upateData(src);
				break;
			case 60002:
				gameBitUI.updateData(src);
				break;
			case 60003:
				state = GAMEREADY;
				break;
			case 60004:
				CarGame.animals[0] = src.items[0].animal;
				CarGame.animals[1] = src.items[1].animal;
				gameBitUI.buildAnimal();
				gameBitUI.updateBitData(src);
				state = GAMESUSERBET;
				break;
			case 60005:
				CarGame.animals[0] = src.items[0].animal;
				CarGame.animals[1] = src.items[1].animal;
				gameBitUI.buildAnimal();
				gameBitUI.updateWinData(src);
				state = GAMESTART;
				break;
			case 30001:
				if (currentPane && src.type == 8) {
					gameMsg = src.content;
					setRunTextField(gameMsg);
				}
				break;
		}
	}

	public function showMessage(s:String):void {
		var mc:MovieClip               = getAssMovieClip("tipMc");
		mc.txt.text                    = s;
		(mc.txt as TextField).autoSize = TextFieldAutoSize.CENTER;
		mc.mouseChildren               = false;
		mc.mouseEnabled                = false;
		mc.x                           = 275;
		mc.y                           = 200;
		TweenLite.to(mc, 1, {y: "-60", delay: .5, onComplete: disMc});
		function disMc():void {
			mc.parent.removeChild(mc);
		}

		addChild(mc);
	}
}
}






