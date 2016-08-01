/**
 * Created by roger on 2016/3/7.
 */
package taven.sideGroup {
import com.bit101.components.PushButton;
import com.greensock.TweenLite;

import flash.display.Sprite;
import flash.events.Event;
import flash.filters.DropShadowFilter;


/**
 * 射击roger
 * 面板
 * 1带投影的UI
 * 2带关闭按钮
 * 3自动居中
 * 别乱用哦
 * 2016 03 07
 */
public class BasePaneUI extends Sprite {
    public var autoAnimate:Boolean = true;

    public function BasePaneUI() {
        super();
        addEventListener(Event.ADDED_TO_STAGE, addedToStageEvent);
        init();
        var btn:PushButton = new PushButton(this, width - 40, 0, "CLOSE", closeClick);
        btn.width = 40;
        btn.alpha = 0.8;
        btn.draw();
        //
        this.filters = [new DropShadowFilter()];
    }

    protected function init():void {
    }

    protected function closeClick(evt:Event):void {
        if (parent) {
            parent.removeChild(this);
        }
    }

    protected function addedToStageEvent(event:Event):void {
        this.x = (stage.stageWidth - this.width) / 2;
        this.y = (stage.stageHeight - this.height) / 2 - 100;
        if (autoAnimate) {
            this.alpha = 0.2;
            TweenLite.to(this, 0.5, {alpha: 1, y: "-50"});
        }
    }
}
}
