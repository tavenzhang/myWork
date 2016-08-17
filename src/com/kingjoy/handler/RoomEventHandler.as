/**
 * Created by Roger on 2014/11/25.
 */
package com.kingjoy.handler {
import com.kingjoy.view.control.RoomEditViewUI;
import com.rover022.event.CBModuleEvent;
import com.rover022.IChat;
import com.rover022.ModuleNameType;
import com.rover022.vo.ChatState;
import com.rover022.vo.PlayerType;
import com.rover022.vo.UserVo;
import com.rover022.vo.VideoConfig;

import display.ui.Alert;

import flash.events.Event;
import flash.events.StatusEvent;

import ghostcat.ui.CenterMode;
import ghostcat.ui.PopupManager;

import manger.ClientManger;
import manger.ModuleLoaderManger;
import manger.UserVoDataManger;

import net.NetManager;

import tool.FormatDataTool;

/**
 * 最基本的房间处理者
 */
public class RoomEventHandler extends IEventHandler {
    public function RoomEventHandler(_view:VideoRoom) {
        super(_view);
    }

    /**
     * 右键功能菜单
     * @param e
     */
    public function onMenuListSelectEvent(e:Event):void {
        if (ClientManger.getInstance().isGuestAndGuestRegister()) {
            return;
        }
        var _uid:int = int(view.rightSelectObject.uid);
        var _uname:String = view.rightSelectObject.uname;
        var iChat:IChat;
        switch (int(Object(view.rightMenu_Module).selectItem.data)) {
            case 1://发送私聊
//                var s:Object = UserVoDataManger.userData;
//                if (s.ruled != 3 && s.richLv <= 2) {
//                    Alert.Show("财富等级达到二富才能发送私聊哦，请先去给心爱的主播送礼物提升财富等级吧。");
//                    return;
//                }
//                    
//                    
//                var iChat:IChat = ModuleLoaderManger.getInstance().getModule(ModuleNameType.CHAT_MODULE2) as IChat;
//                iChat.addItem({
//                    type: 1,
//                    label: _uname,
//                    data: _uid
//                });
                break;
            case 23://连麦申请
                return;
                NetManager.getInstance().sendDataObject({"cmd": 23001, uid: int(view.rightSelectObject.uid)});//发起连麦
                Alert.Show("已经向'" + view.rightSelectObject.uname + "'发出邀请视频连麦请求.");
                break;
            case 31://设置管理员
                if (UserVoDataManger.roomAdmin) {//主播
                    ClientManger.getInstance().setManger(_uid, _uname);
                }
                break;
            case 32://取消管理员
                if (UserVoDataManger.roomAdmin) {//主播
                    ClientManger.getInstance().disposeManger(_uid, _uname);
                }
                break;
            case 41://T出房间
                ClientManger.getInstance().kickOutPlayer(_uid, _uname, 0);
                break;
            case 42://禁言房间
                ClientManger.getInstance().kickOutPlayer(_uid, _uname, 1);
                break;
            case 80://冲值
                ClientManger.getInstance().userPay();
                break;
            case 91://个人中心
                ClientManger.getInstance().userInfo();
                break;
            case 92://查看玩家资料
                var _url:String = FormatDataTool.formatURL(VideoConfig.httpFunction + VideoConfig.configXML.http.@userInfo.toString(), _uid);
                ClientManger.getInstance().httpProxy.operate(_url, null, view.roomHandler.onVideoStatusEvent);
                break;
            case 93://我的关注
                ClientManger.getInstance().userAttention();
                break;
            case 94://我的道具
                ClientManger.getInstance().userProps();
                break;
            case 95://消费记录
                ClientManger.getInstance().userConsRecords();
                break;
            case 99://退出登陆
                ClientManger.getInstance().userLogout();
                break;
            case ChatState.FACETOFACE:
                iChat = ModuleLoaderManger.getInstance().getModule(ModuleNameType.CHAT_MODULE2) as IChat;
                iChat.inputTextField.text = "@" + _uname + " ";
                break;
            default:
        }
    }

    /**
     * 聊天菜单项
     * @param e
     */
    public function onMenuStatusEvent(e:StatusEvent):void {
        switch (e.level) {
            case "nowlist"://本场贡献
                view.rankGift_Module.visible = false;
                view.rankView_Module.visible = true;
                view.rankWeek_Module.visible = false;
                break;
            case "giftlist"://礼物清单
                view.rankGift_Module.visible = true;
                view.rankView_Module.visible = false;
                view.rankWeek_Module.visible = false;
                break;
            case "weeklist"://周贡献榜
                view.rankGift_Module.visible = false;
                view.rankView_Module.visible = false;
                view.rankWeek_Module.visible = true;
                break;
            case "nowActivity"://当前活动
                if (view.air_Module) {
                    view.air_Module.visible = true;
                }
                break;
            case "startActivity"://发起活动
                if (view.air_Module) {
                    view.air_Module.visible = false;
                }
                break;
            case "activityList"://活动记录
                if (view.air_Module) {
                    view.air_Module.visible = false;
                }
                break;
            case "chat"://公共聊天
                view.divisionContainer.show("chat");
                break;
            case "music"://点歌
                view.divisionContainer.show("song");
                break;
            default:
        }
    }

    /*
     * 点击 右上角头像 事件处理
     */
    public function onUserInfo(e:StatusEvent):void {
        var evt:ktvEvent = new ktvEvent(null, e.level, ktvEvent.KTV_MouseEvent);
        onHeadMapListMouseEvent(evt);
    }

    /**
     *
     * @param e
     */
    public function onHeadMapListMouseEvent(e:ktvEvent):void {
        switch (e.data) {
            case "reg"://注册
                ClientManger.getInstance().guestRegister();
                break;
            case "login"://登陆n
                ClientManger.getInstance().guestLogin();
                break;
            case "logout"://退出登陆
                ClientManger.getInstance().userLogout();
                break;
            case "keep"://收藏夹
                ClientManger.getInstance().keepHttp();
                break;
            case "info"://个人中心
                ClientManger.getInstance().userInfo();
                break;
            case "pay"://在线充值
                ClientManger.getInstance().userPay();
                break;
            case "vip"://办理vip
                ClientManger.getInstance().userVIP();
                break;
            default:
        }
    }

    public function dispatchNameLink(_obj:Object):void {
        var targetEvent:CBModuleEvent = new CBModuleEvent(CBModuleEvent.PLAYNAMELINK, true);
        targetEvent.dataObject = _obj;
        view.dispatchEvent(targetEvent);
    }

    /**
     * 新状态机
     * @param e
     */
    public function onVideoStatusEvent(e:StatusEvent):void {
        var _userObj:Object;
        var _urlPorxy:String;
        switch (e.code) {
            case "RankViewModule":
                var targId:*;
                if (e.target == view.rankView_Module) {//本场
                    targId = view.rankView_Module.selectItem.uid;
                } else if (e.target == view.rankWeek_Module) {//周
                    targId = view.rankWeek_Module.selectItem.uid;
                }
                _urlPorxy = FormatDataTool.formatURL(VideoConfig.httpFunction + VideoConfig.configXML.http.@userInfo.toString(), targId);
                ClientManger.getInstance().httpProxy.operate(_urlPorxy, null, view.roomHandler.onVideoStatusEvent);
                break;
            case "RankGiftModule":
                //this.showPersonInfo=this.rankGift_Module.selectItem;
                _urlPorxy = FormatDataTool.formatURL(VideoConfig.httpFunction + VideoConfig.configXML.http.@userInfo.toString(), view.rankGift_Module.selectItem.uid);
                ClientManger.getInstance().httpProxy.operate(_urlPorxy, null, view.roomHandler.onVideoStatusEvent);
                break;
            case "PlayInfoModule":
                switch (e.level) {
                    case "login"://登陆
                        ClientManger.getInstance().guestLogin();
                        break;
                    case "regist"://注册
                        ClientManger.getInstance().guestRegister();
                        break;
                    case "useHead"://用户头像
                        _userObj = UserVoDataManger.userData;
                        var _userVO:UserVo = new UserVo(_userObj);
                        dispatchNameLink(_userVO);
                        break;
                    case "itemUsrInfo"://点击用户列表
                        _userObj = view.playInfo_Module.selectItem;
                        _userVO = new UserVo(_userObj);
                        dispatchNameLink(_userVO);
                        break;
                    case "chongZhi"://充值
                        ClientManger.getInstance().userPay();
                        break;
                    case "home"://大厅
                        NetManager.getInstance().sendDataObject({"cmd": 50002});//更新人数
                        break;
                    case "shop"://商城
                        ClientManger.getInstance().gotoMarket();
                        break;
                    case "privateMail"://私信
                        ClientManger.getInstance().userMsgList();
                        break;
                    case "systemMail"://系统消息
                        ClientManger.getInstance().systemMsgList();
                        break;
                    case "video"://大厅主播
                        ClientManger.getInstance().gotoRoom(view.playInfo_Module.selectItem.roomid);
                        break;
                    case "serve"://客服
                        ClientManger.getInstance().cservice();//打开客服
                        break;
                     
                    case "moreUser"://获取更多用户数据
                        var startIndex:int = view.playInfo_Module.startIndex;
                        startIndex = startIndex <= -1 ? 1 : startIndex;
                        NetManager.getInstance().sendDataObject({
                            "cmd": 11001,
                            "start": startIndex,
                            "end": startIndex + 20
                        });//拉取用户列表
                        break;
                    default:
                }
                break;
            case"PersonInfoModule":
                switch (e.level) {
                    case "Alert"://警告框
                        Alert.Show(view.personInfo_Module.alertMsg.msg, view.personInfo_Module.alertMsg.title);
                        break;
                    default:
                }
                break;
            case"sides"://房间公告
                switch (e.level) {
                    case "bulletin":
                        if (UserVoDataManger.playerState == PlayerType.ANCHOR) {
                            var _rUi:RoomEditViewUI = new RoomEditViewUI(onRoomPublish);
                            PopupManager.instance.showPopup(_rUi, null, true, CenterMode.RECT);
                            function onRoomPublish(_str:String):void {
                                NetManager.getInstance().sendDataObject({"cmd": 10003, content: _str, url: ""});
                            }

                            return;
                        } else {
                            Alert.Show(ClientManger.getInstance().roomPublic, "房间公告");
                        }
                        break;
                    case "warning":
                        Alert.Show(view.speaker_Module.msg, view.speaker_Module.title);
                        break;
                    case "tranUser":
                        if (UserVoDataManger.getInstance().isVideoPublisher) {
                            NetManager.getInstance().sendDataObject({
                                "cmd": 12006,
                                roomid: int(view.sides_Module.data)
                            });//拉取本场排行
                        }
                        break;
                    case "video":
                        if (int(view.sides_Module.data) > 0) {
                            ClientManger.getInstance().gotoRoom(view.sides_Module.data);
                        }
                        break;
                    default:
                }
                break;
            case "http":
                var _json:Object = JSON.parse(e.level);
                if (_json && !_json.ret)
                    break;
                else {
                    _json = JSON.parse(FormatDataTool.decode(_json.info));
                    _json.letterURL = VideoConfig.httpFunction + VideoConfig.configXML.http.@letter.toString();
                    _json.focusURL = VideoConfig.httpFunction + VideoConfig.configXML.http.@focus.toString();
                    setPersonInfo(_json);
                }
                break;
        }
        if (UserVoDataManger.playerState == PlayerType.GUEST) {//游客
            //ClientManger.getInstance().guestLogin();

        }
    }

    /**
     * 设置个人信息UI
     * @param _infoObj
     */
    public function setPersonInfo(_infoObj:Object):void {
        view.personInfo_Module.data = FormatDataTool.personInfo(_infoObj);
        view.personInfo_Module.data.myUid = UserVoDataManger.userData.uid;
        if (view.personInfo_Module.width + view.mouseX <= view.stage.stageWidth) {
            view.personInfo_Module.x = view.mouseX;
        } else {
            view.personInfo_Module.x = view.mouseX - view.personInfo_Module.width;
        }
        if (view.personInfo_Module.height + view.mouseY <= view.stage.stageHeight) {
            view.personInfo_Module.y = view.mouseY;
        } else {
            view.personInfo_Module.y = view.mouseY - view.personInfo_Module.height;
        }
        view.personInfo_Module.visible = true;
    }
}
}
