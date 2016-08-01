/**
 * Created by Administrator on 2015/7/15.
 */
package game.carGame {
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.events.MouseEvent;
import flash.text.TextField;

import game.tool.RunTool;

public class GameReadyUI extends IGamePane {
	public var topTime:int     = 20;
	public var curenTime:int   = 20;
	public var curentMoney:int = 0;

	public function GameReadyUI(_carGame:CarGame) { 
		super(_carGame);
		view = getAssMovieClip("xiazhuMc");
		view.closeBtn.addEventListener(MouseEvent.CLICK, onCloseGame);
		addChild(view);
		makeButton(view.bet1Btn, "1倍", onClickHandle);
		makeButton(view.bet2Btn, "3倍", onClickHandle);
		makeButton(view.bet3Btn, "5倍", onClickHandle);
	}

	override public function updateTime():void {
		if (curenTime > 0) {
			curenTime--;
			view.timeTxt.text = curenTime.toString() + " 秒";
		}
	}

	private function onClickHandle(e:MouseEvent):void {
		var _clip:DisplayObject = e.currentTarget as DisplayObject;
		if (_clip.alpha != 1) {
			return;
		}
		var times:int = 0;
		switch (e.currentTarget.name) {
			case "bet1Btn":
				times = 1;
				break;
			case "bet2Btn":
				times = 3;
				break;
			case "bet3Btn":
				times = 5;
				break;
		}
		if (carGame.uid < 50000) {
			carGame.showMessage("用户未登录");
			return
		}
		carGame.videoRoom.sendDataObject({
			"cmd":   60001,
			"uid":   carGame.uid,
			"times": times,
			"rid":   carGame.rid
		});//发送飞屏
	}

	public function setButtonFalse(src:int):void {
		var _arr:Array = [1, 3, 5];
		for (var i:int = 0; i < _arr.length; i++) {
			var btn:MovieClip = view["bet" + (i + 1) + "Btn"];
			var b:Boolean     = _arr[i] > src ? true : false;
			btn.mouseChildren = btn.mouseEnabled = b;
			btn.alpha = b ? 1 : 0.5;
		}
	}

	public function init():void {
		setButtonFalse(0);
		GameBetAndRunUI.bei = 1;
		curenTime           = topTime;
		view.timeTxt.text   = curenTime.toString();
		view.zNametxt.text  = "";
		setCurentMoney(0, true);
		view.toMoneyTxt.text = GameBetAndRunUI.bei + " 倍"
	}

	public function setCurentMoney(_num:int, useAnimation:Boolean = false):void {
		if (useAnimation) {
			RunTool.makeTextFieldRunAnimation(view.myMoneyTxt, curentMoney, _num);
		} else {
			view.myMoneyTxt.text = _num.toString();
		}
		curentMoney = _num;
	}

	public function makeButton(mc:MovieClip, _txt:String, fun:Function):void {
		var myText:TextField = (mc.name_txt as TextField)
		myText.text          = _txt;
		myText.mouseEnabled  = false;
		mc.addEventListener(MouseEvent.CLICK, fun);
	}

	public function upateData(src:Object):void {
		if (src.ret == 1) {
			view.zNametxt.text = src.nickName;
			setCurentMoney(src.points, true);
			GameBetAndRunUI.bei  = int(src.points / 2000);
			view.toMoneyTxt.text = GameBetAndRunUI.bei + " 倍";
			setButtonFalse(GameBetAndRunUI.bei);
		} else {
			var str:String = carGame.errorMsg[src.ret];
			if (str != null) {
				carGame.showMessage(str);
			} else {
				carGame.showMessage("未知错误" + src.ret);
			}
		}
	}
}
}
