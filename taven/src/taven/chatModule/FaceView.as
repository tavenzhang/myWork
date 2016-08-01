/**
 * Created by Administrator on 2015/4/1.
 */
package taven.chatModule {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;

import ChatRoomModule;

public class FaceView extends Sprite {
    public var inputUI:InputUI;

    public function FaceView(_inputUI:InputUI,imagePre:String) {
        var bitmapData:BitmapData = new expbasemap();
        var bitMap:Bitmap = new Bitmap(bitmapData);
        addChild(bitMap);
        //"/01"
        inputUI = _inputUI;
        for (var i:int = 0; i < 42; i++) {
            var object:FaceSprite = new FaceSprite(i+1,imagePre);
            object.x = 8 + 26 * (i % 9);
            object.y = 28 + 26 * int(i / 9);
            addChild(object);
            object.addEventListener(MouseEvent.CLICK, onClick);
            ChatRoomModule.faceArr["/" + object.id] = imagePre+ "image/face/" + object.id + ".swf";
        }
    }



    private function onClick(event:MouseEvent):void {
        var mc:FaceSprite = event.currentTarget as FaceSprite;
        var begin:int = inputUI.textField.selectionBeginIndex;
        var end:int = inputUI.textField.selectionEndIndex;
        var words:String = inputUI.textField.text;
        inputUI.textField.text = words.substring(0, begin) + "{/" + mc.id +"}"+ words.substring(end);
        inputUI.textField.setSelection(begin + 5, begin + 5);
        stage.focus = inputUI.textField;
        visible = false;
    }
}
}



