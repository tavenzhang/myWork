/**
 * Created by ws on 2015/8/18.
 */
package display {
import com.rover022.IVideoRoom;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Loader;
import flash.display.Sprite;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.net.URLRequest;


public class LoaderHelp extends Sprite {

    private var loader:Loader;

     private var _sucFun:Function;


    public function LoaderHelp(url:String,fun:Function)
    {
        super();
        _sucFun = fun;
        loader = new Loader();
        //loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler);
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
        loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
        loader.load(new URLRequest(url));
        trace(" URLRequest.load===="+url);
    }


    private function completeHandler(e:Event):void {
        var loader:Loader = Loader(e.target.loader);
        if(_sucFun!=null)
        {
            _sucFun(loader.content);
        }
        //loader.unload();
        loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, completeHandler);
        loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
        _sucFun =null;
    }

    private function onError(e:Event):void {
        var loader:Loader = Loader(e.target.loader);
        trace("loaderView 资源错误:"+loader.loaderInfo);
    }

}
}
