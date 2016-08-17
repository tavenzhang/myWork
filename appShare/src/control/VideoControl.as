/**
 * Created by Taven on 2015/9/9.
 */
package control {
import com.junkbyte.console.Cc;
import com.rover022.CBProtocol;
import com.rover022.IPlayer;
import com.rover022.ModuleNameType;
import com.rover022.event.PingEvent;
import com.rover022.tool.NetPing;
import com.rover022.tool.PingManager;

import display.ui.Alert;

import flash.events.Event;
import flash.utils.setTimeout;

import ghostcat.util.core.Singleton;

import manger.ClientManger;
import manger.ModuleLoaderManger;
import manger.UserVoDataManger;

import net.NetManager;

import tool.VideoTool;

public class VideoControl extends BaseControl {

    override public function regMsg():void {
        super.regMagHanlde(CBProtocol.rtmp_client_80002, handleMessgae);
        super.regMagHanlde(CBProtocol.systemPublicMessage, handleMessgae);
        super.regMagHanlde(CBProtocol.faildContactMic, handleMessgae);
        super.regMagHanlde(CBProtocol.deleteContactMic, handleMessgae);
        super.regMagHanlde(CBProtocol.listRtmpRoom_80001, handleMessgae);
        super.regMagHanlde(CBProtocol.songActionListPlay, handleMessgae);
    }

    override public function handleMessgae(data:*):void {
        var sObject:Object = data;
        switch (data.cmd) {

            case CBProtocol.rtmp_client_80002: //主播不处理 80002消息  80002消息返回{cmd:80002,result:(0：未直播 1：直播中)}
                if (!UserVoDataManger.roomAdmin) {
                    var isLive:Boolean = int(data.result) == 1;
                    var rtmpArr:Array = sObject.userrtmp == null ? [] : String(sObject.userrtmp).split(",");
                    onRtmpListResult(rtmpArr);
                }
                break;
            case CBProtocol.systemPublicMessage://连麦广播
                Alert.Show(sObject.content);
                break;
            case CBProtocol.faildContactMic://拒绝连麦
                Alert.Show("玩家拒绝了您的视频对话邀请．", "连麦失败");
                break;
            case CBProtocol.deleteContactMic://断开连麦
                ClientManger.getInstance().removeUserVideo(sObject);
                break;
            case CBProtocol.listRtmpRoom_80001://rtmp择优  主播列表
                Cc.log(sObject.rtmp);
                onRtmpListResult(String(sObject.rtmp).split(","));
                // UserVoDataManger.adminPingManger.addRtmpArray(String(sObject.rtmp).split(","));
                //UserVoDataManger.adminPingManger.addCliendRtmpArr(HttpService.RTMP_LIST);

                break;
            case CBProtocol.songActionListPlay://麦序 20002上麦,20003下麦(传流ID)
                //收到信息之后发送 签到任务
                if (sObject.items.length > 0) {
                    for (var i:int = 0; i < sObject.items.length; i++) {  //目前数组只有1 肯定1个视频
                        if (UserVoDataManger.userData.uid == sObject.items[i].uid) {
                            UserVoDataManger.userData.sid = sObject.items[i].sid;
                        }
                        sObject.items[i].headimg = VideoTool.formatHeadURL(sObject.items[i].headimg);
                    }
                    //播放视频
                    UserVoDataManger.formatStream(sObject.items[0]);//有视频
                    UserVoDataManger.userData.lastRtmp = sObject.items[0].rtmp; //记录最后使用的rtmp地址 用于地址选择判断
                } else {
                    UserVoDataManger.formatStream(null);//没有视频
                    UserVoDataManger.userData.lastRtmp = ""; //记录最后使用的rtmp地址
                }
                break;
        }
    }


    //返回rtmpList列表并进行播放调整
    public function onRtmpListResult(rtmpList:Array):void {
        rtmpList = rtmpList == null ? [] : rtmpList;
        Cc.log("onRtmpListResult------------------------------------------:" + rtmpList);
        if (!UserVoDataManger.roomAdmin) {
            if (rtmpList.length > 0) {
                UserVoDataManger.userPingManger.addCliendRtmpArr(rtmpList);
                UserVoDataManger.userPingManger.addEventListener(PingManager.ITEM_TESTOK, function (evt:Event):void {
                    var ping:NetPing = UserVoDataManger.userPingManger.fastBalanceRtmp;
                    if (ping) {
                        NetManager.getInstance().sendDataObject({"cmd": 20001, "rtmp": ping.rtmp});
                        UserVoDataManger.userPingManger.removeEventListener(PingManager.ITEM_TESTOK, arguments.callee);
                    }
                });
                UserVoDataManger.userPingManger.startTestSped();
            }
            else {
                NetManager.getInstance().sendDataObject({"cmd": 20001, "rtmp": ""});
            }
        } else {
            //设置直播rtml列表
                UserVoDataManger.adminPingManger.addCliendRtmpArr(rtmpList);      //NetManager.getInstance().sendDataObject({"cmd": CBProtocol.listRtmpRoom});//获取rtmp列表
                UserVoDataManger.adminPingManger.startTestSped();
                UserVoDataManger.adminPingManger.dispatchEvent(new Event(PingManager.ITEM_TESTOK));


        }
    }
}
}
