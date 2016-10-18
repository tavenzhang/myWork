/**
 * Created by roger on 2016/6/21.
 */
package game.fingerGame.ui {
import flash.events.MouseEvent;

import game.fingerGame.FWindon;
import game.tool.RunTool;

public class ResPanel extends FWindon {
	private var startBtn:SimpleGameButton;

	public function ResPanel() {
		super();
		view = getAssMovieClip("asset.onCloseSkin");
		addChild(view);
		startBtn = RunTool.buildBtn(this, "asset.n_btnSkin", 20, 0xff3fa1, "重新连接", onClickHandle, 244, 223);
	}

	public function onClickHandle(e:MouseEvent):void {
		var _p:FingerGuessingGame = parent as FingerGuessingGame;
		if (_p.socket.socketClient.connected == false) {
			_p.showGameinfor();
		}
		parent.removeChild(this);
	}
}
}
