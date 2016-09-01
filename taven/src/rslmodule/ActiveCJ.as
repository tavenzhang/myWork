/**
 * Created by zhangxinhua on 16/9/1.
 */
package rslmodule {
import display.BaseRslModule;

import flash.events.Event;

import flash.events.MouseEvent;

import manger.DataCenterManger;

import taven.utils.TweenHelp;

public class ActiveCJ extends BaseRslModule {
    private var _ui:Taven_ActiveCJ;
    private var _userlist:Array;
    override  public function initView():void {
        _ui = new Taven_ActiveCJ();
        this.addChild(_ui);
    }

    override  public function addEventListeners():void {
        _ui.btnClose.addEventListener(MouseEvent.CLICK, onCloseHandle);
    }

    private function onCloseHandle(evt:MouseEvent):void
    {
        this.hide();
    }
// <--62001 {"num":1,"title":"","items":[{"name":"魂之杀殇1","uid":101239398}],"cmd":62001,"detail":""}
    override public function show():void {
        super.show();
        _ui.x = (this.stage.stageWidth-_ui.width)/2;
        _ui.y =  (this.stage.stageHeight-_ui.height)/2-40;
        _ui.txtName.text = DataCenterManger.activeCJData.title;
        _ui.txtDesc.text = DataCenterManger.activeCJData.detail;
        _ui.txtUsr.visible = false;
        _ui.txtUsr.text="";
        _userlist  = DataCenterManger.activeCJData.items;

        if(!_ui.mcAView.hasEventListener(Event.ENTER_FRAME))
        {
            _ui.mcAView.addEventListener(Event.ENTER_FRAME, onEnterFrameHandle)
        }
        _ui.mcAView.gotoAndPlay(1);
        if(_userlist.length>0)
        {
            for(var i:int=0;i<_userlist.length;i++)
            {
                _ui.txtUsr.text +=_userlist[i].name;
                if(i>0&&(i+1)%3==0)
                {
                    _ui.txtUsr.text +="\n";
                }
            }
        }
    }

    private function onEnterFrameHandle(evt:Event):void
    {
        if(_ui.mcAView.currentFrame==40)
        {
            _ui.txtUsr.visible = true;
            TweenHelp.fade( _ui.txtUsr,1,0.2,1);
            _ui.mcAView.removeEventListener(Event.ENTER_FRAME, onEnterFrameHandle)
        }
    }
}
}
