﻿/**
 * Created by Taven on 2015/9/9.
 */
package control {
import com.junkbyte.console.Cc;
import com.rover022.CBProtocol;
import com.rover022.ModuleNameType;

import display.BaseModule;

import flash.display.MovieClip;

import manger.ClientManger;
import manger.DataCenterManger;

import manger.ModuleLoaderManger;

import tool.FormatDataTool;

public class RankAndInfoControl extends BaseControl {
    // 贵族坐席 排行榜 贡献以及公告 和主播信息管理
    override public function regMsg():void {
        super.regMagHanlde(CBProtocol.roomBoard, handleMessgae);
        super.regMagHanlde(CBProtocol.moneyChange, handleMessgae);
        super.regMagHanlde(CBProtocol.moneyChange2, handleMessgae);
        super.regMagHanlde(CBProtocol.RankMonyDay_15005, handleMessgae);
        super.regMagHanlde(CBProtocol.getKtvOrder, handleMessgae);
        super.regMagHanlde(CBProtocol.pushKtvOrder, handleMessgae);
        super.regMagHanlde(CBProtocol.VIP_LIST_18002, handleMessgae);
    }

    override public function handleMessgae(data:*):void {
        var sObject:Object = data;
        var userInfo_Module:MovieClip;
        var rankView_Module:MovieClip = ModuleLoaderManger.getInstance().getModule(ModuleNameType.RANKVIEWMODULE) as MovieClip;

        switch (data.cmd) {
            case CBProtocol.roomBoard://公告
                var _clip:MovieClip = ModuleLoaderManger.getInstance().getModule(ModuleNameType.ROOMMESS) as MovieClip;
                if (_clip) {
                    _clip.txt.text = sObject.content;
                }
                ClientManger.getInstance().roomPublic = sObject.content;
                ClientManger.getInstance().addChatSpanMessage({
                    message: "[房间消息]:" + sObject.content,
                    color: "0x00b4dc"
                });
                break;
            case CBProtocol.moneyChange://主播费用增加通知
                userInfo_Module = ModuleLoaderManger.getInstance().getModule(ModuleNameType.USERINFOUI) as MovieClip;
                if (sObject.uid == DataCenterManger.userData.uid) {
                    DataCenterManger.userData.lv = sObject.lv;
                    userInfo_Module.userObject = DataCenterManger.userData;//右上角用户信息
                }
                var roomPlayInfor:MovieClip = ModuleLoaderManger.getInstance().getModule(ModuleNameType.VIDEO_PLAY_INFO) as MovieClip;
                roomPlayInfor.updataExp(sObject);
                break;

            case CBProtocol.moneyChange2://扣费心跳通知
                DataCenterManger.userData.points = sObject.points;
                DataCenterManger.userData.richLv = sObject.richLv;
                userInfo_Module = ModuleLoaderManger.getInstance().getModule(ModuleNameType.USERINFOUI) as MovieClip;
                userInfo_Module.userObject = DataCenterManger.userData;//右上角用户信息
                ModuleLoaderManger.getInstance().getModule(ModuleNameType.PLAYINFOMODULE)["monyChange"]();

                break;
            case CBProtocol.RankMonyDay_15005://本日贡献共计
                rankView_Module.updateTotal(sObject.total, false);
                break;
            case CBProtocol.getKtvOrder://本场贡献排行 强制刷新贡献列表
                rankView_Module.updateData(FormatDataTool.rankViewArray(sObject.items), false, true);
                break;
            case CBProtocol.pushKtvOrder://本场贡献有字段更改
                rankView_Module.updateData([FormatDataTool.rankView(sObject)]);
                break;
            case CBProtocol.VIP_LIST_18002://获取vip列表
                //Cc.log("CBProtocol.VIP_LIST_18002===");
                //vipModule.handMessage(sObject);
                break

        }
    }
}
}
