package display {
import com.rover022.IVideoModule;
import com.rover022.IVideoRoom;

import flash.display.DisplayObject;

import flash.display.MovieClip;
import flash.events.Event;


public class BaseModule extends MovieClip implements IVideoModule {
    protected var $view:DisplayObject;

    private var _isShowEffect:Boolean;
    /**主程序接口 可以获取各种公用模块*/
    protected var $videoroom:IVideoRoom;

    public function BaseModule() {
        initView();
        initListeners();
        addEventListener(Event.ADDED_TO_STAGE, onAddToStageHandle);

    }

    protected function onAddToStageHandle(event:Event):void {

    }

    protected function initView():void {

    }

    protected function initListeners():void {

    }

    protected function showEffect():void {
        TweenHelp.fade(this, 0.2, 0.2, 1);
    }

    public function handMessage(data:*):void {

    }


    public function dispose():void {
        if ($view) {
            if ($view.parent) {
                $view.parent.removeChild($view);
            }
        }

    }


    override public function set visible(value:Boolean):void {
        super.visible = value;
        if (super.visible) {
            if (isShowEffect)
                showEffect();
        }
        /*else
         {
         if(isShowEffect)
         TweenUtils.fade(this,0.5,1,0);
         }*/

    }

    public function show():void {
       visible = true;
    }

    public function hide():void {
        visible = false;
    }

    public function get isShowEffect():Boolean {
        return _isShowEffect;
    }

    public function set isShowEffect(value:Boolean):void {
        _isShowEffect = value;
    }

    public function set videoRoom(src:IVideoRoom):void {
        $videoroom = src;
    }

    public function get videoRoom():IVideoRoom {
        return $videoroom
    }

    public function listNotificationInterests():Array {
        return [];
    }

    public function handleNotification(src:Object):void {
    }
}
}