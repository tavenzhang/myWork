/**
 * Created by Taven on 2015/8/31.
 */
package control {
import com.rover022.CBProtocol;
import com.rover022.IChat;
import com.rover022.ModuleNameType;
import com.rover022.vo.RespondVo;

import flash.display.MovieClip;

import manger.ClientManger;
import manger.UserVoDataManger;
import manger.ModuleLoaderManger;

import net.NetManager;

import tool.FormatDataTool;

public class GiftAndVideoUIControl extends BaseControl {
    override public function regMsg():void {
        super.regMagHanlde(CBProtocol.richGift_40003, handleMessgae);
        super.regMagHanlde(CBProtocol.list_dateUsers_50005, handleMessgae);
        super.regMagHanlde(CBProtocol.sendGift, handleMessgae);
        super.regMagHanlde(CBProtocol.comboGift_40002, handleMessgae);
    }

    override public function handleMessgae(data:*):void {
        var sObject:Object = data;
        var view:MovieClip = ModuleLoaderManger.getInstance().getModule(ModuleNameType.VIDEO_ROOM) as MovieClip;
        var ichat:IChat;
        switch (data.cmd) {
            case CBProtocol.richGift_40003: //富豪礼物会上礼物跑道
                view.sides_Module.onRichMessage(sObject);
                if (sObject.isInRoom == 0) {
                    //ClientManger.getInstance().playGiftAnimation(sObject);//把数据传入到礼物模块
                    if (sObject.roomid == NetManager.getInstance().roomID) {
                        view.rankGift_Module.updateData([FormatDataTool.rankGift(sObject)]);
                    }
                }
                break;
            case CBProtocol.list_dateUsers_50005://查看预约列表人数
                // 通用处理  对于模块内部消息处理，不影响其他的模块的话 采取默认通用处理
                var id:int = int(sObject.cmd);
                if (UserVoDataManger.respondDic[id] != null) {
                    var item:RespondVo = UserVoDataManger.respondDic[id];
                    item.hanldeFuc(sObject);
                    item.destroy();
                    delete UserVoDataManger.respondDic[id];
                }
                break;
            case CBProtocol.sendGift://礼物
                ichat = ModuleLoaderManger.getInstance().getModule(ModuleNameType.CHAT_MODULE2) as IChat;
                ichat.onGiftChat(sObject);
                ClientManger.getInstance().playGiftAnimation(sObject);//把数据传入到礼物模块

                view.rankGift_Module.updateData([FormatDataTool.rankGift(sObject)]);

                break;
            case CBProtocol.comboGift_40002: // 礼物连续播放
                ichat = ModuleLoaderManger.getInstance().getModule(ModuleNameType.CHAT_MODULE2) as IChat;
                ichat.onComboGiftChat(sObject);
                break;
        }
    }
}
}
