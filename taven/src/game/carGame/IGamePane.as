/**
 * Created by Administrator on 2015/7/15.
 */
package game.carGame {
import com.rover022.display.IAssetMovieClip;

import flash.events.Event;
import flash.events.MouseEvent;

public class IGamePane extends IAssetMovieClip {
	public var carGame:CarGame;

	public function IGamePane(src:CarGame):void {
		carGame = src;
	}

	public function active():void {
		carGame.addChild(this);
	}

	public function removeFromSuperview():void {
		if (parent) {
			parent.removeChild(this);
		}
	}

	public function updateTime():void {
	}

	protected function onCloseGame(event:MouseEvent = null):void {
		parent.parent.removeChild(parent);
	}
}
}
