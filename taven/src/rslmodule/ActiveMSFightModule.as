/**
 * Created by taven on 2016/6/15.
 */
package rslmodule {
import com.rover022.CBProtocol;
import display.BaseRslModule;
import flash.events.MouseEvent;
import flash.utils.Dictionary;

import taven.enum.EventUtils;

public class ActiveMSFightModule extends BaseRslModule{
    private var _ui:active_moshouView;
    public function ActiveMSFightModule() {
    }

    override  public function initView():void {
        _ui = new active_moshouView();
        resetUI();
        this.addChild(_ui);
        _ui.x =20;
        _ui.y =80;
    }

    override  public function addEventListeners():void {
        _ui.btnClose.addEventListener(MouseEvent.CLICK, onCloseHandle)
    }

    override public function show():void {
        super.show();
        var data:Object = {};
        EventUtils.secndNetDataNew( CBProtocol.list_Active_15007, data, s2cGetListData);
    }

    public function s2cGetListData(data:*):void {
        resetUI();
        var dataList:Array = data.items;
        try
        {
            for (var i:int = 0; i < dataList.length; i++) {
                var active:Object = dataList[i];
                if (active) {
                    if (active.gid && active.gid > 0) {
                        var hostArr:Array = [];
                        var guestArray:Array=[];
                        var dataRankItems:Array = dataList[i].rankJsonList.split("||");
                        for (var k:int = 0; k < dataRankItems.length; k++) {
                            var item:Object = JSON.parse(dataRankItems[k]);
                            if (item&&item.type==1) {
                                hostArr.push(item);
                            }
                            else
                            {
                                guestArray.push(item);
                            }
                        }
                        upItemsView(hostArr, i,true);
                        upItemsView(guestArray, i,false);
                    }
                }
            }
        }
        catch (e:*)
        {

        }

    }

    
    private function onCloseHandle(evt:MouseEvent):void
    {
        this.hide();
    }

    private function resetUI():void {
        for (var i:int = 1; i <=5; i++)
        {
            _ui["mcGiftHost"+i].visible = false;
            _ui["mcGiftGuest"+i].visible=false;
            _ui["mc2GiftHost"+i].visible = false;
            _ui["mc2GiftGuest"+i].visible=false;
        }
    }

    private function upItemsView(dataList:Array,activeType:int,isHost:Boolean):void
    {
        for (var i:int = 1; i <=5; i++) {
            var item:* = dataList[i - 1];
            if(!item) {
                continue;
            }
            
            if (isHost) { // 主播榜出来
                if(activeType==0)
                {
                    _ui["mcGiftHost" + i].visible = true;
                    _ui["mcGiftHost" + i].txtName.text = "0"+i+".  " +item.nickname;
                    _ui["mcGiftHost" + i].txtValue.text= +item.score.toString()+" 个";
                    _ui["mcGiftHost" + i].txtAction.text="收:";
                }
                else
                {
                    _ui["mc2GiftHost" + i].visible = true;
                    _ui["mc2GiftHost" + i].txtName.text = "0"+i+".  " +item.nickname;
                    _ui["mc2GiftHost" + i].txtValue.text= item.score.toString()+" 个";
                    _ui["mc2GiftHost" + i].txtAction.text="收:";
                }
            }
            else {
                if(activeType==0)
                {
                    _ui["mcGiftGuest" + i].visible = true;
                    _ui["mcGiftGuest" + i].txtName.text = "0"+i+".  " +item.nickname;
                    _ui["mcGiftGuest" + i].txtValue.text= item.score.toString()+" 个";
                    _ui["mcGiftGuest" + i].txtAction.text="送:";
                }
                else
                {
                    _ui["mc2GiftGuest" + i].visible = true;
                    _ui["mc2GiftGuest" + i].txtName.text = "0"+i+".  " +item.nickname;
                    _ui["mc2GiftGuest" + i].txtValue.text= item.score.toString()+" 个";
                    _ui["mc2GiftGuest" + i].txtAction.text="送:";
                }
            }
        }
    }
}
}
