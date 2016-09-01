/**
 * Created by roger on 2016/5/18.
 */
package game.fingerGame {
import com.rover022.display.IAssetMovieClip;
import com.rover022.vo.PlayerType;
import com.rover022.vo.VideoConfig;

import display.ui.Alert;

import flash.events.MouseEvent;

import game.fingerGame.ui.SimpleGameButton;
import game.tool.RunTool;

import manger.DataCenterManger;

public class ItemUserContion extends IAssetMovieClip {
	public var vo:FingerGameRoomVo;
	public var parentPane:ListPane;
	private var canyuBtn:SimpleGameButton;

	public function ItemUserContion(_vo:FingerGameRoomVo, listPane:ListPane) {
		view       = getAssMovieClip("asset.cellplaylist");
		vo         = _vo;
		parentPane = listPane;
		addChild(view);
		view.mouseChildren  = false;
		view.mouseEnabled   = false;
		view.name_txt.text  = _vo.sendName;
		view.money_txt.text = _vo.points + "钻石";
		view.time_txt.text  = "剩余:" + _vo.time + "秒";
		canyuBtn            = RunTool.buildBtn(this, "asset.c_btnSkin", 14, 0xffffff, "参与", onClick, 437, 0);
		if (vo.sendUid == DataCenterManger.userData.uid) {
			canyuBtn.visible = false;
		}
	}

	public function update():void {
		vo.time--;
		view.time_txt.text = "剩余:" + vo.time + "秒";
		//view.time_txt.text = "";
		if (vo.time <= 0) {
			parentPane.removeRoom(this);
		}
	}

	private function onClick(e:MouseEvent):void {
		if (DataCenterManger.playerState != PlayerType.GUEST) {
			parentPane.sendSocketData({cmd: 61004, gameId: vo.gameId, rid: VideoConfig.roomID});
		} else {
			Alert.Show("请先登录");
		}
	}
}
}
