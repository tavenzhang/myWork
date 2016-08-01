/**
 * Created by chenbin on 2015/8/24.
 */
package taven.chatModule {
import com.greensock.TweenLite;

import com.greensock.loading.ImageLoader;

import flash.display.MovieClip;

import flash.display.Sprite;
import flash.events.Event;

 

/**
 * 连续送礼面板
 */
public class ComboxPane extends Sprite {
    public var view:lianxuMc;
    public var giftMc:MovieClip;

    public function ComboxPane() {
        super();
        view = new lianxuMc();
        addChild(view);
        addEventListener(Event.ADDED_TO_STAGE, onAddStageHandle);
        y = Math.random() * 60;
        giftMc = new MovieClip();
        addChild(giftMc);
        giftMc.y = 35;
    }

    private function onAddStageHandle(event:Event):void {
        TweenLite.to(this, 3, {x: "50"});
        TweenLite.to(this, 1, {alpha: 0, delay: 3, onComplete: dispose});
    }

    public function loaderImageIcon(src:String):void {
        var _image:ImageLoader = new ImageLoader(src, {
            width: 24,
            height: 24,
            container: giftMc
        });
        _image.load();
    }

    private function dispose():void {
        if (parent) {
            parent.removeChild(this)
        }

    }
}
}
