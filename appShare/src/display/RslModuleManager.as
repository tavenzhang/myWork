/**
 * Created by ws on 2015/8/17.
 */
package display {
import com.rover022.display.*;
import com.rover022.IVideoModule;
import com.rover022.IVideoRoom;
import com.rover022.ModuleNameType;

import com.rover022.vo.VideoConfig;

import flash.display.DisplayObject;
import flash.display.Sprite;

import flash.utils.Dictionary;

import mx.modules.ModuleBase;



public class RslModuleManager implements IVideoModule {

    private var moduleDictionary:Dictionary = new Dictionary();
    private static var _instance:RslModuleManager;
    private var _$videoroom:IVideoRoom;

    private var _rslContainer:Sprite = new Sprite();


    public function get rslContainer():Sprite {
        return _rslContainer;
    }

    public function getModule(modlueName:String):IBaseRslModule {
        var module:IBaseRslModule = moduleDictionary[modlueName] as IBaseRslModule;
        if (!module) {
            new LoaderHelp(VideoConfig.getRslModulePath(modlueName), function (rslModule:IBaseRslModule):void {
                        moduleDictionary[modlueName] = rslModule;
                        _rslContainer.addChild(rslModule.view)
                    }
            );
        }
        return module;
    }
    public function hideModuleByView(viewMc:DisplayObject):void
    {
        if(_rslContainer.contains(viewMc))
        {
            _rslContainer.removeChild(viewMc)
        }
    }

    public function removeModule(modlueName:String):void {
        var module:IBaseRslModule = moduleDictionary[modlueName] as IBaseRslModule;
        if (module) {
            if(_rslContainer.contains(module.view))
            {
                _rslContainer.removeChild(module.view)
            }
            module.dispose();
            delete moduleDictionary[modlueName];
        }
    }

    public function showModule(modlueName:String):void {
        var module:IBaseRslModule = moduleDictionary[modlueName] as IBaseRslModule;
        if (!module) {
            new LoaderHelp(VideoConfig.getRslModulePath(modlueName), function (rslModule:IBaseRslModule):void {
                         module = rslModule;
                         moduleDictionary[modlueName] = module;
                        _rslContainer.addChild(module.view)
                    }
            );
        }
        else
        {
            _rslContainer.addChild(module.view);
        }
    }

    public function toggleModule(modlueName:String):void
    {
        var module:IBaseRslModule = moduleDictionary[modlueName] as IBaseRslModule;
        if(module)
        {
            if(_rslContainer.contains(module.view))
            {
                hideModule(modlueName);
            }
            else
            {
                showModule(modlueName);
            }
        }
        else
        {
            showModule(modlueName);
        }
    }


    public function hideModule(modlueName:String):void {
        var module:IBaseRslModule = moduleDictionary[modlueName] as IBaseRslModule;
        if (module) {
            if(_rslContainer.contains(module.view))
            {
                _rslContainer.removeChild(module.view)
            }
        }
    }


    public function set videoRoom(src:IVideoRoom):void {
        _$videoroom = src;
    }

    public function get videoRoom():IVideoRoom {
        return _$videoroom
    }

    public function listNotificationInterests():Array {
        return [];
    }

    public function handleNotification(src:Object):void {

    }

    public function get $videoroom():IVideoRoom {
        return _$videoroom;
    }

    public static function get instance():RslModuleManager {
        if (!_instance) {
            _instance = new RslModuleManager();
        }
        return _instance;
    }

    public function set $videoroom(value:IVideoRoom):void {
        _$videoroom = value;
    }
}
}
