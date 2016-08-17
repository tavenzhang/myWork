/**
 * Created by Administrator on 2015/11/12.
 */
package display.ui {
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

public class CBScrollPanel extends Sprite {
    public var view:Sprite      = new Sprite();
    public var bgView:Sprite    = new Sprite();
    public var thumbView:Sprite = new Sprite();

    private var bgBitMap:ScaleBitmap;
    private var thumbBitMap:ScaleBitmap;

    private var contontWidth:int  = 270;
    private var contontHeight:int = 170;
    [Embed(source="thumbImage_taven.png")]
    public var thumbImage_taven:Class;
    [Embed(source="trackImage_taven.png")]
    public var trackImage_taven:Class;

    public function CBScrollPanel():void {
        addChild(view);

        bgBitMap            = new ScaleBitmap(new trackImage_taven().bitmapData);
        bgBitMap.scale9Grid = new Rectangle(2, 14, 8, 20);
        bgBitMap.height     = contontHeight;
        bgView.addChild(bgBitMap);
        bgView.x = 270;
        //
        thumbBitMap = new ScaleBitmap(new thumbImage_taven().bitmapData);
        thumbView.addChild(thumbBitMap);
        thumbView.x = 270;

        addChild(bgView);
        addChild(thumbView);
        thumbView.buttonMode = true;
        thumbView.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandle);

    }

    private function onMouseDownHandle(event:MouseEvent):void {
        thumbView.startDrag(false, new Rectangle(contontWidth - 10, 0, 0, contontHeight - 46));
        stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUpHandle);
        addEventListener(Event.ENTER_FRAME, onEnterFrameHandle);
    }

    public function updateT():void {
        bgView.visible = thumbView.visible = view.height > contontHeight ? true : false;
    }


    private function onEnterFrameHandle(event:Event):void {
        var percent:Number = thumbView.y / (contontHeight - 46);
        view.y             = -(view.height - contontHeight) * percent;
        //trace(view.y, percent)
    }


    private function onMouseUpHandle(event:MouseEvent):void {
        thumbView.stopDrag();
        stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpHandle);
        removeEventListener(Event.ENTER_FRAME, onEnterFrameHandle);
    }

    public function setSize(w:Number, h:Number):void {
        thumbView.x = w - 10;
        bgView.x    = w - 10;

        //
        contontWidth  = w;
        contontHeight = h;


        //
        bgBitMap.height = contontHeight;
        this.scrollRect = new Rectangle(0, 0, contontWidth + 40, contontHeight);
        //
        updateT();
    }

}
}