/**
 * Created by Administrator on 2015/7/20.
 */
package game.tool {
import com.greensock.TweenLite;
import com.greensock.easing.Linear;

import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.utils.getDefinitionByName;
import flash.utils.getTimer;

import game.fingerGame.ui.SimpleGameButton;

public class RunTool {
    public function RunTool() {
    }

    public static function startDragemc(soureMc:MovieClip):void {
        soureMc.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        function onMouseUp(e:MouseEvent):void {

            //var drageMc:Sprite = e.currentTarget as Sprite;
            soureMc.stopDrag();
            soureMc.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        }

        function onMouseDown(e:MouseEvent):void {
            //trace("onMouseDown");
            var drageMc:Sprite = e.currentTarget as Sprite;
            //soureMc.isDown = true;
            //soureMc.initPoint = new Point(com.rover022.event.stageX, com.rover022.event.stageY);
            drageMc.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp)
            drageMc.startDrag()
        }
    }

    public static function makeTextFieldRunAnimation(src:TextField, cur:Number, fnum:Number):void {
        var _arr:Object = {};
        _arr.x = cur;
        TweenLite.to(_arr, 0.5, {x: fnum, onUpdate: updateFun, ease: Linear.easeNone});
        function updateFun():void {
            src.text = int(_arr.x).toString();
        }
    }

    public static function buildBtn(parent:DisplayObjectContainer, classSkin:String, fontsize:Number, fontcolor:Number, txt:String, clickFun:Function, _x:Number, _y:Number):SimpleGameButton {
        var _class:Class = getDefinitionByName(classSkin) as Class;
        var skin:MovieClip = new _class as MovieClip;
        var btn:SimpleGameButton = new SimpleGameButton(skin, fontsize, fontcolor, txt)
        btn.addEventListener(MouseEvent.CLICK, clickFun);
        parent.addChild(btn);
        btn.x = _x;
        btn.y = _y;
        return btn;
    }

    public static function addEnterFrameClick(src:MovieClip, func:Function):void {
        //src.addEventListener(MouseEvent.CLICK, )
        src.addEventListener(MouseEvent.MOUSE_DOWN, onDownHandle);
        src.addEventListener(MouseEvent.MOUSE_UP, onDispose);
        src.addEventListener(MouseEvent.RELEASE_OUTSIDE, onDispose);
        src.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        function onDownHandle(e:Event):void {
            src.downTime = getTimer();
            src.isJustDown = true;
            func.call(null, src);
        }

        function onDispose(e:Event):void {
            src.removeEventListener(Event.ENTER_FRAME, onEnterFrame)
        }

        function onEnterFrame(e:Event):void {
            if (src.isJustDown) {
                if (getTimer() - src.downTime > 1000)
                    src.isJustDown = false;
            } else {
                if (getTimer() - src.downTime > 200) {
                    func.call(null, src);
                    src.downTime = getTimer();
                }
            }
        }
    }
}
}
