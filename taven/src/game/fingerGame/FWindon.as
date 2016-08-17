/**
 * Created by roger on 2016/5/18.
 */
package game.fingerGame {
import com.rover022.display.IAssetMovieClip;

import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.getDefinitionByName;

import game.fingerGame.ui.SimpleGameButton;

public class FWindon extends IAssetMovieClip {
	public function FWindon() {
	}

	protected function onCloseGameClick(event:MouseEvent = null):void {
		var pa:Sprite = getFGameMain();
		pa.parent.removeChild(pa);
	}

	public function getFGameMain():FingerGuessingGame {
		if (parent && parent.parent) {
			return parent.parent as FingerGuessingGame;
		} else {
			return null;
		}
	}

	public function sendSocketData(object:Object):void {
		getFGameMain().socket.sendDataObject(object);
	}

	public function set canClose(src:Boolean):void {
		view.closeBtn.visible = src;
		if (src) {
			view.closeBtn.addEventListener(MouseEvent.CLICK, onCloseGameClick);
			view.addChild(view.closeBtn)
		}
	}
}
}
