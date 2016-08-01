/**
 * Created by Administrator on 2015/3/26.
 */
package taven.chatModule {
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

public class CBScrollBar extends CbScrollBar {

    private var isDrage:Boolean = false;


    public var maskMC:Sprite;
    public var content:Sprite;

    private var _width:Number;
    private var _height:Number;

    /**
     * 容器的最大高度
     */
    private var _maxHeight:Number;
    private var _postion:Number = 0;
    private var _vBarVisible:Boolean;

    public function CBScrollBar(view:Sprite, _w:Number, _h:Number) {
        content = new Sprite();
        addChild(content);
        maskMC = new Sprite();
        maskMC.graphics.beginFill(0);
        maskMC.graphics.drawRect(0, 0, 10, 10);
        maskMC.graphics.endFill();
        addChild(maskMC);
        setSize(_w, _h);
        content.mask = maskMC;
        content.addChild(view);
        thumb_mc.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandle);

        addEventListener(MouseEvent.MOUSE_WHEEL, onWheelHandle);
    }


    private function onWheelHandle(event:MouseEvent):void {
        var rate:Number = 20;
        if (_vBarVisible) {
            if (event.delta > 0) {
                thumb_mc.y -= rate;
                if (thumb_mc.y < 0) {
                    thumb_mc.y = 0;
                }

            } else {
                thumb_mc.y += rate;
                if (thumb_mc.y > dragValue) {
                    thumb_mc.y = dragValue;
                }
            }
            postion = thumb_mc.y / dragValue;
        }
    }

    public function setSize(_w:Number, _h:Number):void {
        _width = _w;
        _height = _h;

        maskMC.width = _w;
        maskMC.height = _h;

        lineMc.x = _w;
        lineMc.height = _h;
        thumb_mc.x = _w;
    }

    public function update():void {
        if (_maxHeight > lineMc.height) {
            vBarVisible = true;
            updateThumb();
        } else {
            vBarVisible = false;
        }

    }

    public function updateThumb():void {
        if (!isDrage) {
            thumb_mc.y = postion * dragValue;
        }
    }

    public function updateHeightHandle():void {
        _postion = -content.y / maxValue;
        updateThumb();
    }


    private function onMouseDownHandle(event:MouseEvent):void {
        isDrage = true;
        thumb_mc.startDrag(false, new Rectangle(_width, 0, 0, dragValue));
        stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUP);
        addEventListener(Event.ENTER_FRAME, resizeTarget);
    }

    public function get dragValue():Number {
        return lineMc.height - thumb_mc.height;
    }

    private function resizeTarget(event:Event):void {
        postion = thumb_mc.y / dragValue;
    }

    public function get maxValue():Number {
        if (_maxHeight < _height) {
            return 0;
        } else {
            return (_maxHeight - _height);
        }

    }

    private function onStageMouseUP(event:MouseEvent):void {
        isDrage = false;
        thumb_mc.stopDrag();
        removeEventListener(Event.ENTER_FRAME, resizeTarget);
        stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUP);
    }

    public function setHeight(src:Number):void {
        this.lineMc.height = src;
    }

    public function get postion():Number {
        return _postion;
    }

    public function set postion(value:Number):void {
        if (value < 0) {
            value = 0;
        }
        if (value > 1) {
            value = 1;
        }
        _postion = value;
        content.y = -_postion * maxValue;

        update();
    }

    public function get vBarVisible():Boolean {
        return _vBarVisible;
    }

    public function set vBarVisible(value:Boolean):void {
        _vBarVisible = value;
        lineMc.visible = _vBarVisible;
        thumb_mc.visible = _vBarVisible;
    }

    public function get maxHeight():Number {
        return _maxHeight;
    }

    public function set maxHeight(value:Number):void {
        _maxHeight = value;
    }
}
}
