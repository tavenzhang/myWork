/**
 * Created by roger on 2016/5/18.
 */
package game.fingerGame {
import com.bit101.components.ScrollPane;
import com.bit101.components.VBox;
import com.rover022.vo.PlayerType;

import display.ui.Alert;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.setInterval;

import game.fingerGame.ui.AlphaScrollPane;
import game.tool.RunTool;

import manger.DataCenterManger;

public class ListPane extends FWindon {
	public var scrollPanel:ScrollPane;
	public var allRoomArray:Vector.<ItemUserContion> = new <ItemUserContion>[];
	public var vBox:VBox;

	public function ListPane() {
		view = getAssMovieClip("asset.f_gamelist");
		addChild(view);
		canClose = true;
		RunTool.buildBtn(view, "asset.n_btnSkin", 20, 0xff3fa1, "发起游戏", onCreateClick, 244, 318);
		//
		scrollPanel = new AlphaScrollPane(view, 43, 133);
		scrollPanel.setSize(540, 183);
		vBox = new VBox(scrollPanel.content);
		addEventListener(Event.ADDED_TO_STAGE, onAddStage);
		setInterval(onTick, 1000);
	}

	private function onTick():void {
		for each (var room:ItemUserContion in allRoomArray) {
			room.update();
		}
	}

	private function onAddStage(event:Event):void {
		removeEventListener(Event.ADDED_TO_STAGE, onAddStage);
		sendSocketData({cmd: 61001});
		//
		//update(null);
	}

	private function onCreateClick(event:MouseEvent):void {
		if (DataCenterManger.playerState == PlayerType.GUEST) {
			Alert.Show("请先登录");
			return;
		}
		var roomOption:RoomOptionPane = new RoomOptionPane(this);
		view.addChild(roomOption);
		canClose = true;
	}

	public function update(src:Object):void {
		//allRoomArray = [];
	}

	/**
	 * 添加房间
	 * @param _vo
	 */
	public function addRoom(_vo:FingerGameRoomVo):void {
		var object:ItemUserContion = new ItemUserContion(_vo, this);
		vBox.addChildAt(object, 0);
		allRoomArray.push(object);
		scrollPanel.update();
	}

	/**
	 * 移除房间
	 * @param itemUserContion
	 */
	public function removeRoom(itemUserContion:ItemUserContion):void {
		var _d:int = allRoomArray.indexOf(itemUserContion);
		if (_d != -1) {
			allRoomArray.splice(_d, 1);
			vBox.removeChild(itemUserContion);
			scrollPanel.update();
		}
	}

	/**
	 * 一次之能删除一个 没有做多id判断
	 * @param gameId
	 */
	public function removeRoomByID(gameId:Number):void {
		for (var i:int = 0; i < allRoomArray.length; i++) {
			if (allRoomArray[i].vo.gameId == gameId) {
				removeRoom(allRoomArray[i]);
				return;
			}
		}
	}
}
}

 
