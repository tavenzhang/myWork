/**
 * Created by roger on 2016/5/18.
 */
package game.fingerGame {
import flash.events.MouseEvent;
import flash.utils.clearInterval;
import flash.utils.setInterval;

import game.fingerGame.ui.SimpleGameButton;
import game.tool.RunTool;

public class RulePane extends FWindon {
	public var startBtn:SimpleGameButton;
	private var count:int = 0;
	private var id:uint;

	public function RulePane() {
		view = getAssMovieClip("asset.f_gamerule");
		addChild(view);
		canClose         = true;
		startBtn         = RunTool.buildBtn(this, "asset.n_btnSkin", 20, 0xff3fa1, "进入游戏", changeGameState, 244, 296);
		id               = flash.utils.setInterval(update, 100);
		startBtn.visible = false;
	}

	private function update():void {
		if (count > 8) {
			count = 0;
			return;
		}
		if (count == 0) {
			view.connectinfor_txt.text = "后台小弟疯狂连接服务器中";
		} else {
			view.connectinfor_txt.text += ".";
		}
		count++;
	}

	public function changeGameState(e:MouseEvent):void {
		getFGameMain().showGameRoomList();
	}

	public function setanPress(b:Boolean):void {
		clearInterval(id);
		view.connectinfor_txt.text = "服务器连接成功";
		startBtn.visible           = true;
	}
}
}
