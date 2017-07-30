/**
 * Created by chenbin on 2015/8/17.
 */
package display.ui {
import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.utils.getTimer;
import flash.utils.setTimeout;

public class MaskLoaderMc extends Sprite {
    public var mess:String = "后台小兰开始偷偷尝试重新连接...";
    public var count:int = 1;
    private var textField:TextField;
    private var lastTime:int;

    public function MaskLoaderMc(_count:int = 1) {
        count = _count;
        mess = mess + count + "次";
        addEventListener(Event.ADDED_TO_STAGE, onAddStageHandle);
        setTimeout(dis, 3000);
    }

    private function dis():void {
        if (parent) {
            parent.removeChild(this);
        }
    }

    private function onAddStageHandle(event:Event):void {
        removeEventListener(Event.ADDED_TO_STAGE, onAddStageHandle);
        graphics.beginFill(0, .5);
        graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
        graphics.endFill();
        textField = new TextField();
        textField.defaultTextFormat = new TextFormat("宋体", 12, 0xffffff);
        addChild(textField);
        textField.width = 480;
        textField.autoSize = TextFieldAutoSize.CENTER;
        textField.x = stage.stageWidth / 2;
        textField.y = stage.stageHeight / 2;
        //textField.text = "后台小弟开始偷偷尝试重新连接";
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    private function onEnterFrame(event:Event):void {
        if (textField.text.length < mess.length) {
            if (getTimer() - lastTime > 100) {
                lastTime = getTimer();
                textField.appendText(mess.charAt(textField.text.length));
            }
        } else {
            removeEventListener(Event.ENTER_FRAME, onEnterFrame)
        }
    }
}
}
