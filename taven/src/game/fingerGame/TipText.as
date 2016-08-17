/**
 * Created by roger on 2016/5/20.
 */
package game.fingerGame {
import com.greensock.TweenLite;
import com.rover022.display.IAssetMovieClip;

import flash.text.TextField;

public class TipText extends IAssetMovieClip {
	public function TipText(src:Number) {
		view = getAssMovieClip("asset.a_tip");
		addChild(view);
		myTextField.text   = Math.abs(src).toString();
		view.mouseChildren = false;
		view.mouseEnabled  = false;
		x                  = 640;
		y                  = 170;
		alpha              = 0;
		TweenLite.to(this, 1, {x: 80, alpha: 1, onComplete: moveToform});
		if (src < 0) {
			view.gotoAndStop(2);
			myTextField.textColor = 0xff0000;
		}
	}

	public function get myTextField():TextField {
		return view.moneyTxt;
	}

	private function moveToform():void {
		TweenLite.to(this, 1, {x: -640, alpha: 0, onComplete: disPlayFun, delay: 2})
	}

	private function disPlayFun():void {
		if (parent) {
			parent.removeChild(this);
		}
	}
}
}
