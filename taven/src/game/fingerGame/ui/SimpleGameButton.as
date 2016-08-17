/**
 * Created by roger on 2016/5/18.
 */
package game.fingerGame.ui {
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

public class SimpleGameButton extends Sprite {
	public var skin:DisplayObject;
	public var contex:Sprite = new Sprite();
	private var label:TextField;

	public function SimpleGameButton(_skin:DisplayObject, fontsize:Number, fontcolor:Number, text:String) {
		skin     = _skin;
		contex   = new Sprite();
		contex.x = _skin.width / 2;
		contex.y = _skin.height / 2;
		addChild(contex);
		addEventListener(MouseEvent.MOUSE_DOWN, onDown);
		addEventListener(MouseEvent.MOUSE_UP, onUp);
		addEventListener(MouseEvent.RELEASE_OUTSIDE, onUp);
		_skin.x = -_skin.width / 2;
		_skin.y = -_skin.height / 2;
		contex.addChild(skin);
		//
		label              = _skin["label"];
		label.mouseEnabled = false;
		label.text         = text;
		buttonMode         = true;
	}

	private function onDown(event:MouseEvent):void {
		contex.scaleX = contex.scaleY = 0.9;
	}

	private function onUp(event:MouseEvent):void {
		contex.scaleX = contex.scaleY = 1;
	}
}
}
