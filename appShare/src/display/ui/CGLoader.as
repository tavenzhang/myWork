/**
 * Created by Administrator on 2015/6/19.
 */
package display.ui {
import com.greensock.TweenLite;

import flash.display.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;

public class CGLoader extends Loader {
    public function CGLoader() {
        super();
        contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandle);
        contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandle);
    }

    private function onCompleteHandle(event:Event):void {
        this.alpha = 0;
        TweenLite.to(this, 0.4, {alpha: 1});
    }

    private function ioErrorHandle(event:IOErrorEvent):void {
    }
}
}
