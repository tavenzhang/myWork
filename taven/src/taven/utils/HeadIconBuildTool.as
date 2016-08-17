/**
 * Created by Administrator on 2015/6/17.
 */
package taven.utils {
import flash.display.Loader;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;

/**
 * 人物信息元素制造器
 *
 */
public class HeadIconBuildTool {
    public function HeadIconBuildTool() {
    }

    public static function loaderUserHead(headimg:String, head_mc:MovieClip):void {
        if (head_mc.mainUrl == headimg) {
            return;
        }
        head_mc.mainUrl = headimg;
        var loader:Loader = new Loader();
        loader.load(new URLRequest(headimg));
        loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOErrorHandle);
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
        head_mc.addChild(loader);
        function onComplete(e:Event):void {
            loader.width = 50;
            loader.height = 50;
        }

        function onIOErrorHandle(e:IOErrorEvent):void {
            head_mc.addChild(new HandIcon())
        }
    }

    public static function makerUserHead(_x:int, _y:int):MovieClip {
        var mc:headIcon = new headIcon();
        mc.buttonMode = true;
        //mc.head_mc.mask = mc.mask_mc;
        mc.x = _x;
        mc.y = _y;
        return mc;
    }
}
}
