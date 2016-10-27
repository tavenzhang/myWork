/**
 * Created by Administrator on 2015/4/8.
 */
package com.kingjoy.view.control {
import com.rover022.vo.VideoConfig;
import tool.VideoTool;

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;

public class ScrollStageControl {
    public var view:VideoRoom;
    public var scrollStage_Module:MovieClip;

    public function ScrollStageControl(_view:VideoRoom) {
        view = _view;
        scrollStage_Module = VideoTool.getMovieClipInstance("shareElement.scrollShare");
        scrollStage_Module.height = 200;
        scrollStage_Module.visible = false;
        scrollStage_Module.addEventListener(Event.ADDED_TO_STAGE, onAddStageHandle);

        view.stageSpr.addChild(scrollStage_Module);

        scrollStage_Module.addEventListener(Event.SCROLL, onStageScrollHandle);
        view.stage.addEventListener(Event.RESIZE, onResizeStageHandle);

        onResizeStageHandle(null);
    }

    private function onAddStageHandle(event:Event):void {
        scrollStage_Module.stage.addEventListener(MouseEvent.MOUSE_WHEEL, function (e:MouseEvent):void {
            if (e.delta > 0) {
                scrollStage_Module.value -= 4;
            } else {
                scrollStage_Module.value += 4;
            }
        })
    }

    /**
     * 尺寸变化
     * @param e
     */
    private function onResizeStageHandle(e:Event):void {
        if (view.stage.stageHeight < 700) {
            scrollStage_Module.x = view.stage.stageWidth - 30;
            scrollStage_Module.step = 700 - view.stage.stageHeight;
            scrollStage_Module.y = (view.stage.stageHeight - scrollStage_Module.height) / 3
        } else {
            scrollStage_Module.step = 0;
        }

        //礼物
        if (view.giftSpr) {
            view.giftSpr.x = (view.stage.stageWidth - VideoConfig.WIDTH) / 2;
        }
    }

    /**
     * 尺寸变化
     * @param e
     */
    private function onStageScrollHandle(e:Event):void {
        view.appLay.y = -scrollStage_Module.value;
    }
}
}
