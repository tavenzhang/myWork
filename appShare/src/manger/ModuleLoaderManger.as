/**
 * Created by Administrator on 2015/4/8.
 */
package manger {
import com.greensock.events.LoaderEvent;
import com.greensock.loading.SWFLoader;
import com.rover022.IVideoModule;
import com.rover022.IVideoRoom;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.utils.Dictionary;

public class ModuleLoaderManger {
    private static var _instance:ModuleLoaderManger;
    public var moduleDictionary:Dictionary;

    public function ModuleLoaderManger() {
        moduleDictionary = new Dictionary();
    }

    public static function getInstance():ModuleLoaderManger {
        if (_instance == null) {
            _instance = new ModuleLoaderManger();
        }
        return _instance;
    }

    public function getModule(_name:String):DisplayObject {
        return moduleDictionary[_name];
    }

    public function register(_name:String, clip:DisplayObject):void {
        moduleDictionary[_name] = clip;
    }

    public function handleNontice(src:Object):void {
        //for each (var _module:IVideoModule in moduleDictionary) {
        for (var _name:* in moduleDictionary) {
            if (moduleDictionary[_name] is IVideoModule) {
                var _omodule:IVideoModule = moduleDictionary[_name] as IVideoModule;
                if (_omodule && _omodule.listNotificationInterests() && _omodule.listNotificationInterests().indexOf(src.cmd) != -1) {
                    _omodule.handleNotification(src);
                }
            }
        }
    }

    public function loadModule(_view:IVideoRoom, _x:int, _y:int, url:String, _class:String, moudle_name:String):void {
        if (moduleDictionary[moudle_name]) {
            trace("app 中已经运行着这个模块");
            return;
        }
        moduleDictionary[moudle_name] = url;
        var loader:SWFLoader = new SWFLoader(url, {onComplete: onModuleComplete});
        loader.load();
        function onModuleComplete(e:LoaderEvent):void {
            var clipclass:Class = loader.getClass(_class);
            var imodele:IVideoModule = new clipclass();
            imodele.videoRoom = _view;
            var _clip:DisplayObject = imodele as DisplayObject;
            _clip.x = _x;
            _clip.y = _y;
            (_view as MovieClip).addChild(_clip);
            register(moudle_name, _clip);
            //trace("加载结束")
        }
    }
}
}
