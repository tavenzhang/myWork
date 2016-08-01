package {
import com.kingjoy.view.LoadUI;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.utils.getDefinitionByName;
import flash.utils.setTimeout;

import ghostcat.manager.RootManager;

/**
 * ...
 * @author Roger
 */
[SWF(width=1500, height=700, backgroundColor="#00000")]
public class Preloader extends MovieClip {
    public function Preloader() {
        RootManager.register(this);
        addEventListener(Event.ENTER_FRAME, checkFrame);
        loaderInfo.addEventListener(ProgressEvent.PROGRESS, progress);
        loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioError);
        loaderInfo.addEventListener(Event.COMPLETE, loadingFinished)
    }

    private function ioError(e:IOErrorEvent):void {
    }

    private function progress(e:ProgressEvent):void {
        trace("progress");
        var perNumber:int = (int(e.bytesLoaded / e.bytesTotal * 30));
        LoadUI.setLoadInfo("加载进度...", perNumber);
    }

    private function checkFrame(e:Event):void {
        if (currentFrame == totalFrames) {
            stop();
            loadingFinished();
        }
    }

    private function loadingFinished(event:Event = null):void {
        trace("loadingFinished")
        removeEventListener(Event.ENTER_FRAME, checkFrame);
        loaderInfo.removeEventListener(ProgressEvent.PROGRESS, progress);
        loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
        LoadUI.setLoadInfo("加载进度...", 30);
        setTimeout(startup, 1000)
        //startup();
    }

    private function startup():void {
        trace(getDefinitionByName("VideoRoom"))
        var mainClass:Class = getDefinitionByName("VideoRoom") as Class;
        addChild(new mainClass() as DisplayObject);
    }
}
}