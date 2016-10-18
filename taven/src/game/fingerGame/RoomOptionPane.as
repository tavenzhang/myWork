/**
 * Created by roger on 2016/5/18.
 */
package game.fingerGame {
import com.rover022.vo.VideoConfig;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.MouseEvent;

import game.tool.RunTool;

public class RoomOptionPane extends FWindon {
	public var bitArray:Array = [20, 50, 100, 200, 500, 1000, 2000, 5000];
	private var point:Number  = bitArray[0];
	private var _pPane:ListPane;

	public function RoomOptionPane(paren:ListPane) {
		_pPane = paren;
		view   = getAssMovieClip("asset.f_gameoption");
		addChild(view);
		canClose = false;
		//
		RunTool.buildBtn(this, "asset.n_btnSkin", 20, 0xff3fa1, "确定", onCreateClick, 166, 300);
		RunTool.buildBtn(this, "asset.b_btnSkin", 20, 0xff3fa1, "取消", onBackClick, 344, 300);
		view.bitBtn.buttonMode                = true;
		(view.bitBtn as Sprite).mouseChildren = false;
		view.bitBtn.addEventListener(MouseEvent.CLICK, onBitHandle);
		comboxUI.visible = false;
		addChild(comboxUI);
		for (var i:int = 0; i < bitArray.length; i++) {
			var object:MovieClip         = comboxUI["select_mc" + i];
			object.moneyTxt.text         = bitArray[i] + "钻石";
			object.moneyTxt.mouseEnabled = false;
			object.point                 = bitArray[i];
			object.buttonMode            = true;
			object.addEventListener(MouseEvent.CLICK, onSubClick)
		}
	}

	private function onSubClick(event:MouseEvent):void {
		point                         = event.currentTarget.point;
		view.bitBtn.realMoneyTxt.text = point + "钻石";
	}

	public function get comboxUI():MovieClip {
		return view.viewUI;
	}

	private function onBitHandle(event:MouseEvent):void {
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		comboxUI.visible = true;
	}

	private function onMouseUp(event:MouseEvent):void {
		stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		comboxUI.visible = false;
	}

	private function onBackClick(event:MouseEvent):void {
		destroy();
	}

	private function onCreateClick(event:MouseEvent):void {
		_pPane.sendSocketData({cmd: 61002, rid: VideoConfig.roomID, points: point});
		destroy();
	}

	public function destroy():void {
		_pPane = null;
		parent.removeChild(this);
	}
}
}
