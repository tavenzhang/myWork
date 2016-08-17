/**
 * Created by Administrator on 2015/6/22.
 */
package video {
import com.greensock.TweenLite;
import com.junkbyte.console.Cc;
import com.rover022.vo.PlayerType;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.utils.setInterval;

import manger.UserVoDataManger;

public class SignViewUI extends Sprite {
    public var view:SignMc;
    public var playView:VideoPlayerView;
    public const TYPE1_INFOR:String = "后台小弟疯跑中";

    public function SignViewUI(_playView:VideoPlayerView, _x:int, _y:int) {
        view = new SignMc();
        view.messageMc.gotoAndStop(1);
        view.messageMc._txt.text = TYPE1_INFOR;
        (view.messageMc._txt as TextField).autoSize = "left";
        view.messageMc.alpha = 0;
        view.signMc.gotoAndStop(1);
        view.speedTxt.text = "";
        addChild(view);
//        view.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
//        view.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
        playView = _playView;
        x = _x;
        y = _y;
        playView.addChild(this);
        //addEventListener(Event.ENTER_FRAME, onEnterFrameHandle);
        flash.utils.setInterval(showDataBytesPerSecond, 1000);
    }

    private function showDataBytesPerSecond():void {
        if (UserVoDataManger.playerState > PlayerType.PLAYER) {
            view.speedTxt.text = playView.currentdataBytesPerSecond.toFixed(1) + "KB/S";
        } else {
            view.speedTxt.text = "";
        }
    }

    private function onRollOut(event:MouseEvent):void {
        view.messageMc.visible = false;
    }

    private function onRollOver(event:MouseEvent):void {
        view.messageMc.visible = true;
        view.messageMc.alpha = 0;
        TweenLite.to(view.messageMc, 0.5, {alpha: 1});
    }

    public function update(_num:Number):void {
        if (_num < 0) {
            view.signMc.gotoAndStop(1);
        } else if (_num < 100) {
            view.signMc.gotoAndStop(2);
        } else if (_num < 1000) {
            view.signMc.gotoAndStop(3);
        } else if (_num < 5000) {
            view.signMc.gotoAndStop(4);
        } else {
            view.signMc.gotoAndStop(5);
        }
        if (0 > _num) {
            view.messageMc._txt.text = TYPE1_INFOR;
        } else {
            view.messageMc._txt.text = "延时" + _num + "毫秒";
        }
        view.messageMc.gotoAndStop(_num < 1000 ? 1 : 2);
         
    }
}
}
