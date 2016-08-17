/**
 * Created by Taven on 2015/9/9.
 */
package control {
import com.rover022.CBProtocol;
import com.rover022.IChat;
import com.rover022.IPlayer;
import com.rover022.ModuleNameType;
import com.rover022.vo.GiftVo;

import display.BaseModule;
import display.ui.Alert;

import flash.display.MovieClip;

import ghostcat.manager.FontManager;

import manger.ClientManger;
import manger.ModuleLoaderManger;
import manger.UserVoDataManger;

import net.NetManager;

import tool.FormatDataTool;

// 全局消息控制器
public class RoomManageControl extends BaseControl {

    //主播房间管理 以及用户管理 control
    override public function regMsg():void {
        super.regMagHanlde(CBProtocol.listUser, handleMessgae);
        super.regMagHanlde(CBProtocol.onEnterRoom, handleMessgae);
        super.regMagHanlde(CBProtocol.onOutRoom, handleMessgae);
        super.regMagHanlde(CBProtocol.onGetMoreUserInfor, handleMessgae);
        super.regMagHanlde(CBProtocol.addManger, handleMessgae);
        super.regMagHanlde(CBProtocol.removeManger, handleMessgae);
        super.regMagHanlde(CBProtocol.listManger, handleMessgae);
        super.regMagHanlde(CBProtocol.kickOut, handleMessgae);
        super.regMagHanlde(CBProtocol.featureRoom, handleMessgae);
        super.regMagHanlde(CBProtocol.pushFobTime, handleMessgae);
        super.regMagHanlde(CBProtocol.userInviteVideo, handleMessgae);
        super.regMagHanlde(CBProtocol.rejUserInviteVideo, handleMessgae);
        super.regMagHanlde(CBProtocol.listAutor, handleMessgae);
        super.regMagHanlde(CBProtocol.onListUserChange, handleMessgae);
        super.regMagHanlde(CBProtocol.closeRtmp, handleMessgae);
    }

    override public function handleMessgae(data:*):void {
        var sObject:Object = data;
        var view:MovieClip = ModuleLoaderManger.getInstance().getModule(ModuleNameType.VIDEO_ROOM) as MovieClip;
        var vipModule:BaseModule = ModuleLoaderManger.getInstance().getModule(ModuleNameType.RANK_VIP) as BaseModule;
        switch (data.cmd) {
            case CBProtocol.listUser://玩家列表
                //KTVUnion.setLoadInfo("获取玩家信息..",100);//-----------loading信息
                view.logo_Module.peopleInfo = sObject;
                sObject.flushPerson = true;
                view.playInfo_Module.updateUserData(sObject, FormatDataTool.userDataArray(sObject.items));
                sObject.flushPerson = false;
                vipModule.handMessage(data);
                break;
            case CBProtocol.onEnterRoom://玩家进入
                //KTVUnion.setLoadInfo("进入视频大厅..",98);//-----------loading信息
//                var a:String = '{"guests":0,"lv":1,"uid":105061,"name":"101203","richLv":1,"icon":1107,"isAuchor":false,"sex":0,"car":120107,"total":3,"vip":1107,"cmd":11002,"ruled":0}';
//                sObject = JSON.parse(a);
                vipModule.handMessage(data);
                (ModuleLoaderManger.getInstance().getModule(ModuleNameType.RANK_VIP) as BaseModule).handMessage(sObject);//vip贵宾席 交给module自己处理
                view.logo_Module.peopleInfo = sObject;
                if (sObject.ruled != -1) {
                    if (UserVoDataManger.userData.uid == sObject.uid) {
                        ClientManger.getInstance().formatPurview(sObject.ruled);//用户
                    }
                    if (int(sObject.car && sObject.hidden != 1) > 0) {
                        view.parking_Module.updateData([FormatDataTool.parkCar(sObject)]);
                    }
                    var ichat:IChat = ModuleLoaderManger.getInstance().getModule(ModuleNameType.CHAT_MODULE2) as IChat;
                    ichat.onPeopleEnter(sObject);
                    view.playInfo_Module.updateUserData(sObject, [FormatDataTool.userData(sObject)]);
                }
                if (sObject.car > 0) {
                    ClientManger.getInstance().playGiftAnimation({
                        gid: sObject.car,
                        gnum: "1",
                        animationType: GiftVo.TYPE_TRANSPORTATION
                    });
                }
                break;
            case CBProtocol.onOutRoom://玩家退出
                vipModule.handMessage(data);
                (ModuleLoaderManger.getInstance().getModule(ModuleNameType.RANK_VIP) as BaseModule).handMessage(sObject);//vip贵宾席 交给module自己处理
                view.logo_Module.peopleInfo = sObject;
                if (sObject.ruled != -1) {
                    view.playInfo_Module.updateUserData(sObject, [FormatDataTool.userData(sObject)], true);
                    view.parking_Module.updateData([FormatDataTool.parkCar(sObject)], true);
                }
                break;
            case CBProtocol.onGetMoreUserInfor://查询获取更多用户
                vipModule.handMessage(data);
                sObject.flushPerson = true;
                view.playInfo_Module.updateUserData(sObject, FormatDataTool.userDataArray(sObject.items));
                sObject.flushPerson = false;
                break;
            case CBProtocol.addManger://添加 管理员
                vipModule.handMessage(data);
                view.playInfo_Module.updateUserData(null, [FormatDataTool.userData(sObject)]);
                if (UserVoDataManger.userData.uid == sObject.uid) {//是自己
                    ClientManger.getInstance().formatPurview(sObject.ruled);//用户
                    Alert.Show("恭喜您被主播提升为本房间管理员!", "通知", true, 3, true);
                }
                break;
            case CBProtocol.removeManger://删除 管理员
                vipModule.handMessage(data);
                var _userObject:Object = view.playInfo_Module.getDataByUid(sObject.uid);
                if (_userObject) {
                    _userObject.ruled = 0;
                    view.playInfo_Module.updateUserData(null, [FormatDataTool.userData(_userObject)]);
                    if (UserVoDataManger.userData.uid == sObject.uid) {//是自己
                        ClientManger.getInstance().formatPurview(0);//用户
                        Alert.Show("很遗憾!\n您被主播撤消了本房间管理员资格!", "通知", true, 3, true);
                    }
                }
                break;
            case CBProtocol.listManger://列表 管理员
                vipModule.handMessage(data);
                view.playInfo_Module.updateUserData(null, FormatDataTool.userDataArray(sObject.items));
                break;
            case CBProtocol.kickOut://踢出房间
                var isSelf:Boolean = UserVoDataManger.getInstance().isSelf(sObject.uid);
                //var outerIsSelf:Boolean = UserVoDataManger.getInstance().isSelf(sObject.outId);
                var _names:String = FormatDataTool.getNickeNameByInt(sObject.name, sObject.hidden);
                //0 禁言 1 踢人
                if (sObject.mark == 0) {
                    if (isSelf) {
                        Alert.Show("已经把'" + sObject.outName + "'禁言,他30分钟内将无法在你的房间发言!");
                    } else {
                        Alert.Show("你已经被" + _names + "狠狠的禁言了,30分钟内将无法发言!");
                    }
                } else {
                    if (isSelf) {
                        Alert.Show("已经把'" + sObject.outName + "'T出房间,他30分钟内将无法进入您的房间!");
                    } else {

                        Alert.Show("你已经被" + _names + "T出了房间,30分钟内不能再次进入哦!");
                        NetManager.getInstance().connectionErrorCount = NetManager.SERVERCLOSECLIENT;
                        var playModule:IPlayer = ModuleLoaderManger.getInstance().getModule(ModuleNameType.VIDEOPLAYER) as IPlayer;
                        playModule.closePublish();
                    }
                }
                break;
            case CBProtocol.closeRtmp://断开RTMP流
                playModule = ModuleLoaderManger.getInstance().getModule(ModuleNameType.VIDEOPLAYER) as IPlayer;
                playModule.closePublish();
                break;
            case CBProtocol.featureRoom://跳房间
                ClientManger.getInstance().gotoRoom(sObject.roomid);
                break;
            case CBProtocol.pushFobTime://禁言解封时间
                ClientManger.getInstance().addChatSpanMessage({
                    message: "[系统消息]:" + "您已经被禁言了," + Math.floor(sObject.seconds / 60) + "分" + (sObject.seconds % 60) + "秒后才能发言.",
                    color: "0x00b4dc"
                });
                break;
            case CBProtocol.userInviteVideo://收到玩户申请开房
                Alert.Show(sObject.name + "愿意支付" + sObject.cost + "钻石/分钟,向您申请一对一模式\n您是否愿意接受?", "开房申请", false, 3, true, function (_v:int):void {
                    if (_v == 1) {
                        NetManager.getInstance().sendDataObject({
                            cmd: CBProtocol.roomOptionChange,
                            mode: 2,
                            free: 0,
                            cost: sObject.cost,
                            rest: 0,
                            pass: "",
                            pid: sObject.uid,
                            acc: 1
                        });//acc=1表示是用户发起的邀请
                    } else {
                        NetManager.getInstance().sendDataObject({cmd: 13004, uid: sObject.uid});
                    }
                });
                break;
            case CBProtocol.rejUserInviteVideo://主播拒绝开房
                Alert.Show("主播拒绝了主公您的申请!", "申请失败", true, 3, true);
                break;
            case CBProtocol.listAutor://主播列表
                //KTVUnion.setLoadInfo("更新当前主播信息.",94);//-----------loading信息
                var _vItem:Array = FormatDataTool.playerDataArray(sObject.items);
                view.sides_Module.updateVideoData(_vItem);
                view.playInfo_Module.peopleInfo = sObject;
                view.playInfo_Module.updateVideoData(_vItem);
                break;
            case CBProtocol.onListUserChange://列表人数更新
                // _group = BackGroundLay.list_Module.getitemGroup(0);
                // _group.updataPeoples(sObject.items);
                _vItem = FormatDataTool.peopleArray(sObject.items);
                view.sides_Module.updateVideoInfos(_vItem);
                view.playInfo_Module.peopleInfo = sObject;
                view.playInfo_Module.updateVideoInfos(_vItem);
                break;
        }
    }
}
}
