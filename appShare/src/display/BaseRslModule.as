/**
 * Created by ws on 2015/8/17.
 */
package display {
import com.rover022.display.*;
import com.rover022.IVideoRoom;

import flash.display.DisplayObject;

import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.filters.DropShadowFilter;

import ghostcat.display.transfer.Boob;

import mx.events.ModuleEvent;

public class BaseRslModule extends Sprite implements IBaseRslModule{
    protected var $isShowEffect:Boolean=true;
    private var _isShow:Boolean =false;

    public function resize():void {
    }

    public function BaseRslModule() {
        this.mouseEnabled =false;
        initView();
        addEventListeners();
        addEventListener(Event.ADDED_TO_STAGE,onShowView);
      //  this.filters = [new DropShadowFilter()];
    }

    private function  onResize(evt:Event):void
    {
        resize();
    }

    public function initView():void {

    }

    public function addEventListeners():void {

    }
    
    protected function onShowView(evt:Event):void
    {
        show();
    }

    public function dispose():void {
        this.stage.removeEventListener(Event.RESIZE,onResize);
        removeEventListener(Event.ADDED_TO_STAGE,onShowView);
    }
    //显示窗口
    public function show():void {
        this.visible=true;
        this.mouseChildren = true;
        this.alpha = 1;
        if ($isShowEffect)
        {
            TweenHelp.fade(this,0.3,0.2,1);
        }
    }

    public function hide():void{
        this.mouseChildren = false;
        var view:DisplayObject = this;
        if($isShowEffect)
        {
            TweenHelp.fade(this,0.5,1,0,function():void{
                RslModuleManager.instance.hideModuleByView(view);
            });
        }
        else
        {
            RslModuleManager.instance.hideModuleByView(this);
       }
    }


    public function get view():DisplayObjectContainer {
        return this;
    }
}
}
