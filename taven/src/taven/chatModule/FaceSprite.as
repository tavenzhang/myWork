/**
 * Created by Administrator on 2015/4/1.
 */
package taven.chatModule {
import com.rover022.ModuleNameType;

import flash.display.Loader;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;

public class FaceSprite extends MovieClip {
    public var id:String;

    public function FaceSprite(_id:int,icoPre:String):void {
        id = String(_id);
        if (id.length == 1) {
            id = "0" + id;
        }

        buttonMode = true;

        var loader:Loader = new Loader();
        loader.load(new URLRequest(icoPre + 'image/face/' + id + ".swf"));
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandle);
        loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandle);
        addChild(loader);
    }

    private function ioErrorHandle(event:IOErrorEvent):void {
        trace(id,"error");
    }

    private function completeHandle(event:Event):void {

    }
}
}
