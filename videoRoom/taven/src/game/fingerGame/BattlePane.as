/**
 * Created by roger on 2016/5/18.
 */
package game.fingerGame {
import com.greensock.TweenLite;
import com.greensock.TweenMax;
import com.greensock.plugins.BlurFilterPlugin;
import com.greensock.plugins.TintPlugin;
import com.greensock.plugins.TweenPlugin;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.utils.setInterval;
import flash.utils.setTimeout;

import game.fingerGame.ui.SimpleGameButton;
import game.tool.RunTool;

import manger.UserVoDataManger;

public class BattlePane extends FWindon {
	public const SUCCESS:int            = 2;
	public const PING:int               = 4;
	public const LOST:int               = 3;
	public var maxTime:int;
	private var sureBtn:SimpleGameButton;
	private var gameId:Number;
	private var faceArr:Vector.<Sprite> = new <Sprite>[];
	private var players:Object;
	public var grow:GlowFilter          = new GlowFilter(0xffcc00, 1, 3, 3, 4);

	public function BattlePane() {
		view = getAssMovieClip("asset.f_gamebattle");
		addChild(view);
		canClose = true;
		//
		sureBtn  = RunTool.buildBtn(this, "asset.n_btnSkin", 20, 0xff3fa1, "选定出拳", sureMyChoice, 366, 282);
		view.p1.gotoAndStop(1);
		view.p2.gotoAndStop(2);
		for (var i:int = 0; i < 3; i++) {
			var btnClip:MovieClip = view["chioce" + i];
			btnClip.faceMc.addEventListener(MouseEvent.CLICK, onChioceClick);
			btnClip.faceMc.gotoAndStop(i + 1);
			btnClip.addEventListener(MouseEvent.CLICK, onChioceClick);
			btnClip.buttonMode = true;
			faceArr.push(btnClip);
		}
		view.resultMc.gotoAndStop(1);
		view.p1.rotationY = 1;
		view.p2.rotationY = 180;
		addEventListener(Event.ADDED_TO_STAGE, onAddStage);
		setInterval(updateTime, 1000);
	}

	public function showHarryUp():void {
		var mc:Sprite   = getAssMovieClip("asset.hurryupMc");
		var point:Point = new Point(myTitleClip.x, myTitleClip.y);
		mc.x            = point.x;
		mc.y            = point.y;
		view.addChild(mc);
		TweenLite.to(mc, 1.5, {
			y: "-20", onComplete: function ():void {
				mc.parent.removeChild(mc);
			}
		})
	}

	private function updateTime():void {
		if (maxTime > 0) {
			maxTime--;
			if (isOver == false) {
				if (maxTime == 3) {
					showHarryUp();
				}
				view.guanggao_txt.text = "请选择";
			} else {
				view.guanggao_txt.text = "已选定";
			}
			view.time_txt.text = "剩余:" + maxTime + "秒";
		} else {
			view.time_txt.text = "时间到";
		}
	}

	private function onAddStage(event:Event):void {
		TweenPlugin.activate([TintPlugin]);
		sureBtn.mouseChildren = false;
		sureBtn.mouseEnabled  = true;
		sureBtn.alpha         = 1;
		view.p1_name.text     = "??";
		view.p2_name.text     = "??";
		view.resultMc.gotoAndStop(1);
		maxTime               = 15;
		view.time_txt.visible = true;
		setPushButtonVisible(true);
		for each (var sprite:Sprite in faceArr) {
			sprite.filters = [];
		}
	}

	/**
	 * 点了选择之后 全部的按钮应该不可以再点击了
	 * @param b
	 */
	public function setPushButtonVisible(b:Boolean):void {
		for (var i:int = 0; i < faceArr.length; i++) {
			faceArr[i].visible = b;
		}
		sureBtn.visible = b;
	}

	private function onTestBackClick(e:MouseEvent = null):void {
		getFGameMain().showGameRoomList();
	}

	private function getFinsihType(obj:Array):int {
		if (obj[0].points == obj[1].points) {
			return PING;
		}
		if (obj[0].uid == UserVoDataManger.userData.uid) {
			return obj[0].points > obj[1].points ? SUCCESS : LOST;
		}
		if (obj[1].uid == UserVoDataManger.userData.uid) {
			return obj[1].points > obj[0].points ? SUCCESS : LOST;
		}
		return PING;
	}

	private function getScoreobj(obj:Array):int {
		if (obj[0].uid == UserVoDataManger.userData.uid) {
			return obj[0].points;
		} else {
			return obj[1].points;
		}
	}

	private function getFinsihArray(obj:Array):Array {
		var _arr:Array = [];
		for (var i:int = 0; i < obj.length; i++) {
			var object:Object = obj[i];
			_arr.push(object.finger)
		}
		return _arr;
	}

	/**
	 * 是否游戏已经出了结果;
	 */
	public function get isOver():Boolean {
		return !sureBtn.visible;
	}

	/**
	 * 显示游戏结果
	 *
	 * @param obj
	 */
	public function showResult(obj:Array):void {
		view.time_txt.visible = false;
		//
		setPushButtonVisible(false);
		var type:int     = getFinsihType(obj);
		var score:Number = getScoreobj(obj);
		var arr:Array    = getFinsihArray(obj);
		//
		TweenPlugin.activate([BlurFilterPlugin]);
		view.p1.gotoAndStop(1);
		view.p2.gotoAndStop(1);
		view.p1.rotationY = 0;
		view.p2.rotationY = 180;
		TweenMax.to(view.p1, 0, {blurFilter: {blurX: 10}});
		TweenMax.to(view.p2, 0, {blurFilter: {blurY: 10}});
		TweenLite.to(view.p1, 1.5, {rotationY: 180 * 2 * 3});
		TweenLite.to(view.p2, 1.5, {rotationY: 180 * (2 * 3 + 1)});
		setTimeout(onPlayCompleteFun, 1000);
		function onPlayCompleteFun():void {
			view.p1.gotoAndStop(arr[0]);
			view.p2.gotoAndStop(arr[1]);
			TweenMax.to(view.p1, 0, {blurFilter: {blurX: 0}});
			TweenMax.to(view.p2, 0, {blurFilter: {blurY: 0}});
			var tipmc:TipText = new TipText(score);
			addChild(tipmc);
			view.resultMc.gotoAndStop(type);
		}

		setTimeout(onTestBackClick, 5000);
	}

	public function get myTitleClip():MovieClip {
		if (players[0].uid == UserVoDataManger.userData.uid) {
			return view.p1;
		} else {
			return view.p2;
		}
	}

	private function onChioceClick(event:MouseEvent):void {
		var index:int = 0;
		switch (event.currentTarget.name) {
			case "chioce0":
				index = 1;
				break;
			case "chioce1":
				index = 2;
				break;
			case "chioce2":
				index = 3;
				break;
		}
		myTitleClip.gotoAndStop(index);
		for each (var sprite:Sprite in faceArr) {
			sprite.filters = null;
		}
		event.currentTarget.filters = [grow];
	}

	private function sureMyChoice(e:MouseEvent):void {
		setPushButtonVisible(false);
		sendSocketData({cmd: 61006, gameId: gameId, finger: myTitleClip.currentFrame});
	}

	/**
	 * 设置游戏左右两边角色的数据
	 * @param obj
	 */
	public function setData(obj:Object):void {
		players           = obj.items;
		gameId            = obj.gameId;
		view.p1_name.text = obj.items[0].name;
		view.p2_name.text = obj.items[1].name;
		if (obj.items[0].uid == UserVoDataManger.userData.uid) {
			view.guanggao_txt.x = 52;
			view.p2.gotoAndStop(5);
		} else {
			view.guanggao_txt.x = 433;
			view.p1.gotoAndStop(4);
		}
	}
}
}
