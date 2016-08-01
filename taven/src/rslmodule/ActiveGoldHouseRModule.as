/**
 * Created by taven on 2016/5/20.
 */
package rslmodule {


import com.rover022.CBProtocol;

import display.BaseRslModule;

import flash.events.MouseEvent;
import flash.utils.clearInterval;
import flash.utils.setInterval;

import taven.enum.EventUtils;

public class ActiveGoldHouseRModule extends BaseRslModule{
    private var _ui:taven_myHouseView;
    private var _timeId:uint;
    private var leftTtime:int;

   override  public function initView():void {
       _ui = new taven_myHouseView();
       resetUI()
       this.addChild(_ui);
       _ui.x =100;
       _ui.y =200;
    }

    override  public function addEventListeners():void {
        _ui.btnClose.addEventListener(MouseEvent.CLICK, onCloseHandle)
    }


    override public function show():void {
        super.show();
       // NetManager.getInstance().sendDataObject()
        var data:Object = new Object();
        EventUtils.secndNetDataNew( CBProtocol.list_Active_15006, data, s2cGetListData);
    }

    public function s2cGetListData(data:*):void
    {
        var hostArr:Array=[];
        var guestArr:Array=[];
       var items:Array = data.items;
        if(items.length>0)
        {
            for(var i:int=0;i<items.length;i++)
            {
                if(items[i].type==1)
                {
                    hostArr.push(items[i]);
                }
                else
                {
                    guestArr.push(items[i]);
                }
            }
        }
        upItemsView(hostArr,true);
        upItemsView(guestArr,false);
        clearInterval(_timeId);
        leftTtime = data.time/1000;
        if(leftTtime>0)
        {
            _timeId = setInterval(flushTime,1000);
        }
        flushTime();
    }

    private function  flushTime():void
    {
        leftTtime = leftTtime<=0 ?0:leftTtime;
        var time:Number = leftTtime;
        var day:int = int(time/(60*60*24));
        _ui.txtDay.text = day.toString();
        _ui.txtDay.text =day<10? ("0"+day).toString():day.toString();
        time = time%(60*60*24);
        var hour:int = time/(60*60);
        _ui.txtHour.text = hour<10 ?("0"+hour):hour.toString();
        time =time%(60*60)
        var min:int = time/60
        _ui.txtMin.text = min<10 ?("0"+min):min.toString();
        if(min<=0&&day<=0&&hour<=0)
        {
            clearInterval(_timeId);
        }
        leftTtime--;
    }

    private function onCloseHandle(evt:MouseEvent):void
    {
       this.hide();
    }

    private function resetUI():void {
        for (var i:int = 1; i <=10; i++)
        {
            _ui["itemHost"+i].visible = false;
            _ui["itemHost"+i].mouseChildren=false;
            _ui["itemGuest"+i].visible = false;
            _ui["itemGuest"+i].mouseChildren=false;
            _ui.txtDay.text="00";
            _ui.txtHour.text="00"
            _ui.txtMin.text="00";

        }
    }
    private function upItemsView(dataList:Array,isHost:Boolean):void
    {
            for (var i:int = 1; i <= 10; i++) {
                var item:* = dataList[i - 1];
                if (isHost) {
                    if (dataList[i - 1]) {
                        _ui["itemHost" + i].visible = true;
                        _ui["itemHost" + i].txtName.text = i+"." +item.nickname;
                        _ui["itemHost" + i].txtValue.text= item.score.toString()+"米";
                    }
                    else {
                        _ui["itemHost" + i].visible = false;
                    }
                }
                else {
                    if (dataList[i - 1]) {
                        _ui["itemGuest" + i].visible = true;
                        _ui["itemGuest" + i].txtName.text = i+"." +item.nickname;
                        _ui["itemGuest" + i].txtValue.text= item.score.toString()+"个";
                    }
                    else {
                        _ui["itemGuest" + i].visible = false;
                    }
                }
            }
    }
}
}
