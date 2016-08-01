/**
 * Created by Administrator on 2015/7/15.
 */
package game.carGame {
import com.greensock.TweenLite;
import com.greensock.easing.Linear;
import com.rover022.ModuleNameType;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.geom.Rectangle;
import flash.utils.getDefinitionByName;

import game.tool.RunTool;

public class GameBetAndRunUI extends IGamePane {
	public var betTimeTop:int    = 25;
	public var animationTime:int = 10;
	public var runTime:int       = 10;
	private var _gameOverMc:MovieClip;
	public var racers:Array;
	private var _carNum:uint;
	private var _points:int;
	public var topArray:Array    = [0, 0, 0, 0];
	private var totalPoints:int;
	private var masterObj:Object;
	public static var bei:int    = 1;
	public var maxBetLine:int    = 2;
	public var bitUIArray:Array  = [];
	public var lay_game:Sprite;

	public function GameBetAndRunUI(_src:CarGame) {
		super(_src);
		view = getAssMovieClip("carGameMc");
		view.closeBtn.addEventListener(MouseEvent.CLICK, onCloseGame);
		addChild(view);
		_gameOverMc         = getAssMovieClip("winPanelMc");
		_gameOverMc.x       = 93;
		_gameOverMc.y       = 87;
		_gameOverMc.filters = [new flash.filters.DropShadowFilter(2, 2)];
		lay_game            = view.grassland.backGroundMc;
		//
		view.addChild(view.contorUI);
		racers = [];
		for (var i:int = 0; i < maxBetLine; i++) {
			var bit:RaceSkin = new RaceSkin();
			bit.x            = 95;
			bit.y            = 222 + i * 100;
			bit.id           = i;
			view.contorUI.addChild(bit);
			bitUIArray.push(bit);
			//
		}
		addEventListener("BiT_CLICK", onSubClick);
		//addEventListener(Event.ADDED_TO_STAGE, onAddStage);
	}

	private function onAddStage(event:Event):void {
		buildAnimal();
	}

	//初始化小动物
	public function buildAnimal():void {
		var i:int;
		for (i = 0; i < racers.length; i++) {
			var object:Object = racers[i];
			view.grassland.removeChild(object)
		}
		racers = [];
		for (i = 0; i < maxBetLine; i++) {
			var an_array:Array    = ["play1", "play2", "play3", "play4"];
			var animotion:Class   = getDefinitionByName(an_array[CarGame.animals[i]]) as Class;
			var _anClip:MovieClip = new animotion();
			view.grassland.addChild(_anClip);
			_anClip.x = 0;
			_anClip.y = 20 + 80 * (i + 1);
			racers.push(_anClip);
		}
	}

	public function initButtonBei(src:int):void {
		bei = src;
		for (var i:int = 0; i < bitUIArray.length; i++) {
			var _clip:RaceSkin = bitUIArray[i];
			_clip.setBitLable(src);
		}
	}

	private function makeNewButton(src:MovieClip):void {
		src.buttonMode = true;
		makePressEff(src);
		src.addEventListener(MouseEvent.CLICK, onSubClick);
	}

	private function onSubClick(event:Event):void {
		var carNum:int = event.target.id + 1;
		var points:int = event.target.bid;
		if (masterObj.uid == carGame.uid) {
			carGame.showMessage("庄家自己不能下注");
			return;
		}
		if (carGame.uid < 50000) {
			carGame.showMessage("用户未登录")
			return
		}
		var userObjct:Object = carGame.videoRoom.getDataByName(ModuleNameType.USERDATA);
		if (userObjct.points < points) {
			carGame.showMessage("你的钱不够押注.");
			return;
		}
		carGame.videoRoom.sendDataObject({
			"cmd":    60002,
			"uid":    carGame.uid,
			"carNum": carNum,
			"points": points,
			"rid":    carGame.rid
		});
	}

	public static function makePressEff(mc3:Sprite):void {
		mc3.buttonMode = true;
		mc3.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
		mc3.addEventListener(MouseEvent.MOUSE_UP, onUp);
		mc3.addEventListener(MouseEvent.RELEASE_OUTSIDE, onUp);
		function onUp(e:MouseEvent):void {
			mc3.scaleX = mc3.scaleY = 1;
		}

		function onDown(e:MouseEvent):void {
			mc3.scaleX = mc3.scaleY = 0.9;
		}
	}

	private function onClickHandle(event:MouseEvent):void {
		initRun();
	}

	public function initBit():void {
		totalPoints           = 0;
		view.contorUI.visible = true;
		initAnimation();
		runTime = betTimeTop;
		initButtonBei(bei);
	}

	public function initRun():void {
		view.contorUI.visible = false;
		initAnimation();
		runTime = 10;
		TweenLite.to(lay_game, animationTime, {x: -978, onComplete: onGameOver, ease: Linear.easeNone});
	}

	public function runByRandom():void {
		var _f:int = int(Math.random() * racers.length);
		runAndMiddleByNumer(_f);
	}

	public function runAndMiddleByNumer(src:int):void {
		var mc:GameReadyMc = new GameReadyMc();
		addChild(mc);
		//trace("animationTime:", animationTime);
		var runTime:Number      = animationTime / 2;
		var runLandWidth:Number = 380;
		var faWidth:Number      = Math.random() > 0.5 ? 40 : -40;
		for (var i:int = 0; i < racers.length; i++) {
			var clip:MovieClip = racers[i] as MovieClip;
			if (i == src) {
				//win logic
				TweenLite.to(clip, runTime, {
					x:                runLandWidth / 2 + faWidth,
					onComplete:       winFun,
					onCompleteParams: [clip],
					ease:             Linear.easeNone,
					delay:            0.5
				});
				trace("win is run", runLandWidth / 2 + faWidth)
			} else {
				trace("lose is run", runLandWidth / 2 - faWidth);
				TweenLite.to(clip, runTime, {
					x:                runLandWidth / 2 - faWidth,
					onComplete:       loseFun,
					onCompleteParams: [clip],
					ease:             Linear.easeNone,
					delay:            0.5
				});
			}
		}
		function winFun(src:MovieClip):void {
			TweenLite.to(src, runTime, {x: runLandWidth});
		}

		function loseFun(src:MovieClip):void {
			TweenLite.to(src, runTime, {x: runLandWidth - 20 - int(Math.random() * 20)});
		}
	}

	public function onGameOver():void {
		view.addChild(_gameOverMc);
		_gameOverMc.y = 127;
		TweenLite.to(_gameOverMc, 0.5, {y: "-40"});
		_gameOverMc.s_txt.text = _carNum + "号";
		_gameOverMc.f_txt.text = "0";
		RunTool.makeTextFieldRunAnimation(_gameOverMc.f_txt, 0, _points);
	}

	public function initAnimation():void {
		topArray = [0, 0, 0, 0];
		var clip:MovieClip;
		for each (var skin:RaceSkin in bitUIArray) {
			skin.init();
		}
		for each (clip in racers) {
			clip.x = 0;
		}
		lay_game.x         = 0;
		view.timeTxt.text  = "0";
//		view.bossName.text = "";
		view.mybetTxt.text = "0";
		if (_gameOverMc.parent) {
			view.removeChild(_gameOverMc);
		}
	}

	override public function updateTime():void {
		super.updateTime();
		if (runTime > 0) {
			runTime--;
		}
		view.timeTxt.text = runTime.toString();
	}

	public function updateWinData(src:Object):void {
		view.bossName.text = src.nickName;
		view.mybetTxt.text = totalPoints.toString();
		runAndMiddleByNumer(src.carNum - 1);
		_carNum = src.carNum;
		_points = src.points;
	}

	public function updateData(src:Object):void {
		//var s:Object = JSON.parse('{"nickName":"魂之杀殇地方","ret":2108,"cmd":60002,"items":[{"carNum":1,"linePoints":10000,"points":0},{"carNum":2,"linePoints":10000,"points":0}],"uid":101120974,"totalPoints":0,"type":0}')
		//src = s;
		if (src.ret == 1) {
			str = "【" + src.nickName + "】" + "共下注了:" + src.totalPoints + "钻石!";
			carGame.showMessage(str);
			//
			showResultView(src);
		} else {
			var str:String = carGame.errorMsg[src.ret];
			if (str != null) {
				carGame.showMessage(str);
				if (src.ret == 2108) {
					showResultView(src);
				}
			} else {
				carGame.showMessage("未知错误" + src.ret);
			}
		}
	}

	private function showResultView(src:Object):void {
		if (src.type == 0) {
			setTotalPoints(src.totalPoints);
		}
		for (var i:int = 0; i < src.items.length; i++) {
			var object:Object = src.items[i];
			var _index:uint   = object.carNum - 1;
			var _mc:RaceSkin  = bitUIArray[_index] as RaceSkin;
			_mc.setTopPoint(object.linePoints);
			_mc.setSelfPoint(object.points);
		}
	}

	public function setTotalPoints(src:int):void {
		RunTool.makeTextFieldRunAnimation(view.mybetTxt, totalPoints, src);
		totalPoints = src;
	}

	public function updateBitData(src:Object):void {
		view.bossName.text = src.nickName;
		masterObj          = src;
	}
}
}

import com.greensock.TweenLite;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.getDefinitionByName;

import game.carGame.GameBetAndRunUI;

class GameReadyMc extends Sprite {
	private var view:MovieClip;

	public function GameReadyMc():void {
		var _class:Class = getDefinitionByName("gameReadyMc") as Class;
		view             = new _class() as MovieClip;
		addChild(view);
		TweenLite.to(this, 0.5, {x: "500", delay: 1, onComplete: onDispo});
		this.x = 243;
		this.y = 212;
	}

	private function onDispo():void {
		parent.removeChild(this);
	}
}
class RaceSkin extends MovieClip {
	public var view:MovieClip;
	public var index:int;
	public var id:int;
	public var bid:int;

	public function RaceSkin():void {
		var _class:Class = getDefinitionByName("raceMc") as Class;
		view             = new _class() as MovieClip;
		addChild(view);
		view.bitSkin.alpha = 0;
		addEventListener(MouseEvent.ROLL_OVER, showT);
		addEventListener(MouseEvent.ROLL_OUT, outT);
		function showT(e:MouseEvent):void {
			view.bitSkin.alpha = 1;
		}

		function outT(e:MouseEvent):void {
			view.bitSkin.alpha = 0;
		}

		for (var i:int = 1; i <= 3; i++) {
			var _btn:MovieClip = view.bitSkin["brt" + i + "_btn"];
			_btn.addEventListener(MouseEvent.CLICK, onCliCK);
			_btn.gotoAndStop(i);
			_btn.b_mc.visible = false;
			GameBetAndRunUI.makePressEff(_btn);
		}
	}

	private function onCliCK(e:MouseEvent):void {
		bid             = e.currentTarget.bid;
		var event:Event = new Event("BiT_CLICK", true);
		dispatchEvent(event)
	}

	public function init():void {
		setSelfPoint(0)
		setTopPoint(0);
		for (var i:int = 1; i <= 3; i++) {
			var _btn:MovieClip = view.bitSkin["brt" + i + "_btn"];
			_btn.b_mc.visible  = false;
		}
	}

	public function setBitLable(bei:int):void {
		makeLabelText(view.bitSkin.brt1_btn, 10 * bei, bei, "10");
		makeLabelText(view.bitSkin.brt2_btn, 30 * bei, bei, "30");
		makeLabelText(view.bitSkin.brt3_btn, 50 * bei, bei, "50");
	}

	/**
	 * 设置按钮下注金额和显示文字
	 * @param src
	 * @param bid
	 * @param _name
	 */
	public function makeLabelText(src:MovieClip, bid:uint, _frame:int, _name:String):void {
		src.bid          = bid;
		src.b_mc.visible = true;
		switch (_frame) {
			case 3:
				src.b_mc.gotoAndStop(2);
				break;
			case 5:
				src.b_mc.gotoAndStop(3);
				break;
			default :
				src.b_mc.visible = false;
				break;
		}
	}

	public function setSelfPoint(points:int):void {
		view.s_Mc.selfTxt.text = "下注:" + points;
	}

	public function setTopPoint(linePoints:int):void {
		view.s_Mc.topTxt.text = "总金额:" + linePoints;
	}
}
