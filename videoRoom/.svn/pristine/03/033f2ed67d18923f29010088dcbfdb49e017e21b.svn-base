/**
 * Created by Administrator on 2015/6/19.
 */
package com.kingjoy.view.control {
import flash.display.MovieClip;
import flash.events.MouseEvent;
import flash.events.TextEvent;

import videoRoom.textInputBoxUI;

public class RoomEditViewUI extends MovieClip {
    public var view:videoRoom.textInputBoxUI;
    public var func:Function;

    public function RoomEditViewUI(_func:Function) {
        func = _func;
        view = new textInputBoxUI();
        view._inputTxt.maxChars = 20;
        view.num_txt.text = (20 - view._inputTxt.text.length).toString();
        view.close_bt.addEventListener(MouseEvent.CLICK, closeHandle);
        view.send_bt.addEventListener(MouseEvent.CLICK, sendClick);
        view._inputTxt.addEventListener(TextEvent.TEXT_INPUT, onTextEditHandle);
        addChild(view);
    }

    private function onTextEditHandle(event:TextEvent):void {
        view.num_txt.text = (20 - view._inputTxt.text.length).toString();
    }

    private function sendClick(event:MouseEvent):void {
        if (view._inputTxt.text.length > 0) {
            func.call(null, view._inputTxt.text)
        }
        closeHandle(null)
    }

    private function closeHandle(event:MouseEvent):void {
        this.parent.removeChild(this);
        func = null;
    }
}
}
