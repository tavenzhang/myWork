/**
 * Created by Taven on 2015/9/9.
 */
package control {
import com.junkbyte.console.Cc;
import com.rover022.CBProtocol;
import com.rover022.IPlayer;
import com.rover022.ModuleNameType;
import com.rover022.event.CBModuleEvent;
import com.rover022.vo.VideoConfig;

import display.BaseModule;
import display.ModuleRSLManager;

import display.ui.Alert;

import flash.display.MovieClip;


import ghostcat.manager.RootManager;

import manger.ClientManger;
import manger.ModuleLoaderManger;
import manger.DataCenterManger;

import mx.modules.ModuleManager;

import mx.utils.StringUtil;

import net.NetManager;

import tool.FormatDataTool;
import tool.VideoTool;

public class GlobalControl extends BaseControl {

	//全局消息控制器 用于入口等信息 处理
	override public function regMsg():void {
		super.regMagHanlde(CBProtocol.getKey, handleMessgae);
		super.regMagHanlde(CBProtocol.getSignActivity_24001, handleMessgae);
		super.regMagHanlde(CBProtocol.connectSuccess, handleMessgae);
		super.regMagHanlde(CBProtocol.errorTwoLogon, handleMessgae);
		super.regMagHanlde(CBProtocol.login, handleMessgae);
		super.regMagHanlde(CBProtocol.roomInfo, handleMessgae);
		super.regMagHanlde(CBProtocol.enterRoomLimit_10011, handleMessgae);
		super.regMagHanlde(CBProtocol.enterRoomLimit_10014, handleMessgae);
		super.regMagHanlde(CBProtocol.onEnterRoom_VIP_10013, handleMessgae);
		super.regMagHanlde(CBProtocol.VIP_OPEN_18001, handleMessgae);

	}

	override public function handleMessgae(data:*):void {
		var sObject:Object = data;
		var view:MovieClip = ModuleLoaderManger.getInstance().getModule(ModuleNameType.VIDEO_ROOM) as MovieClip;
		var vipModule:BaseModule = ModuleLoaderManger.getInstance().getModule(ModuleNameType.RANK_VIP) as BaseModule;
		switch (data.cmd) {
			case CBProtocol.getKey://拿到服务器的验证钥匙 生成ase;
				NetManager.getInstance().createKey(sObject.limit);
				break;
			case CBProtocol.getSignActivity_24001://获取签到任务
				view.showetSignActivity(sObject);
				break;
			case CBProtocol.connectSuccess://socket连接成功
				Cc.log("socket连接成功");
				break;
			case CBProtocol.errorTwoLogon://连接断开
				//服务器强制断开 不需要重连了
				NetManager.getInstance().connectionErrorCount = NetManager.SERVERCLOSECLIENT;
				Alert.Show(sObject.msg, " 本房间自动断开。");
				//VideoTool.jumpToMainURL(null);
				break;
			case CBProtocol.login://10001用户信息
				var videoModule:IPlayer = ModuleLoaderManger.getInstance().getModule(ModuleNameType.VIDEOPLAYER) as IPlayer;
				if(videoModule)
				{
					videoModule.hideVideo(false);
				}
				vipModule.handMessage(data);
				//KTVUnion.setLoadInfo("",92);//-----------loading信息
				//UserVoDataManger.userData = JSON.parse('{"icon":1104,"vip":1104,"port":0,"car":120104,"cmd":10001,"ruled":0,"sex":0,"uid":1626669,"hidden":0,"roomid":0,"headimg":"","activityName":"","lv":1,"expTotal":10000,"gid":0,"points":0,"name":"ronnie","gamepop":"1","exp":0,"downloadUrl":"http://pan.baidu.com/s/1pJV9S9t","ret":0,"emailValid":0,"host":"","richLv":13}')
				DataCenterManger.userData  = sObject;//用户信息
				VideoConfig.isShowGameHelp = sObject.introduced;
//				var _gameEvent:CBModuleEvent;
//				if (sObject.gamepop == 1) {
//					_gameEvent = new CBModuleEvent(CBModuleEvent.SHOW_CAR_GAME);
//					RootManager.stage.dispatchEvent(_gameEvent);
//				}
				var _arr:Object = JSON.parse(sObject.gamepop);
				var _gameEvent:CBModuleEvent;
//				if (_arr["1"] == 1) {
//					_gameEvent = new CBModuleEvent(CBModuleEvent.SHOW_CAR_GAME);
//					RootManager.stage.dispatchEvent(_gameEvent);
//				}
//				if (_arr["2"] == 1) {
//					_gameEvent = new CBModuleEvent(CBModuleEvent.SHOW_FINGER_GAME);
//					RootManager.stage.dispatchEvent(_gameEvent);
//				}
					if(_arr["3"]==1){
						ModuleRSLManager.instance.showModule(ModuleNameType.GameTurnPlate);
					}
				//
				RootManager.stage.dispatchEvent(new CBModuleEvent(CBModuleEvent.RECONNECT_SOCKET));
				view.playInfo_Module.showActiveBtns(DataCenterManger.userData.items);

				if (int(DataCenterManger.userData.ruled) != -1) {//已登祟
					view.playInfo_Module.data = FormatDataTool.personInfo(DataCenterManger.userData);//新版左侧
				}
				DataCenterManger.userData.headimg = VideoTool.formatHeadURL(DataCenterManger.userData.headimg);
				view.userInfo_Module.userObject   = DataCenterManger.userData;//右下角用户信息

				DataCenterManger.userDataFirst    = false;
				//收到信息之后发送 签到任务
				var iPlay:IPlayer                 = ModuleLoaderManger.getInstance().getModule(ModuleNameType.VIDEOPLAYER) as IPlayer;
				if (iPlay && iPlay.isGetMic) {
					return;
				}
				NetManager.getInstance().sendDataObject({"cmd": 50001});
				NetManager.getInstance().sendDataObject({"cmd": 24001});
				NetManager.getInstance().sendDataObject({"cmd": CBProtocol.VIP_LIST_18002, "start": 0, "end": 20});//获取vip贵族列表
				break;
			case CBProtocol.roomInfo:// 房间信息 10002进入房间
				//KTVUnion.setLoadInfo("获取房间信息..",96);//-----------loading信息
				DataCenterManger.roomData   = sObject;//房间信息
				DataCenterManger.videoOwner = null;//当前视频对象
				view.roomPlayInfor.isPlayer = false;//不是房主
				view.resetModule();
				var isHost:Boolean         = false;
				DataCenterManger.roomAdmin = false;//是否房间拥有者
				if (int(DataCenterManger.userData.ruled) == 3) {//是主播号
					if (DataCenterManger.userData.roomid == sObject.roomid) {//主播的情况下,在自己房间
						DataCenterManger.roomAdmin = true;//房间拥有者
						ClientManger.getInstance().formatPurview(3);//是主播
						//如果是主播 直接获取到rtml 列表
						isHost = true;
						//videoRoom._owner.roomPlayInfor.isPlayer=true;//不是房主
					} else {//是主播,但不在自己房间
						ClientManger.getInstance().formatPurview(0);//用户
						isHost = false;
					}
				} else {//用户与游客
					ClientManger.getInstance().formatPurview(int(DataCenterManger.userData.ruled));
				}
				view.playInfo_Module.checkChoujiang(DataCenterManger.roomAdmin);//检查是否显示抽奖按钮
				//为中间 切线 提示提供依据
				view.sides_Module.isAnchor          = DataCenterManger.roomAdmin;
				view.video_Module.isAnchor          = DataCenterManger.roomAdmin;
				DataCenterManger.roomData.pingMange = DataCenterManger.userPingManger;
				if (DataCenterManger.roomData && DataCenterManger.roomData.rtmp != "") {//不是在大厅时
					if (DataCenterManger.roomAdmin) {
						NetManager.getInstance().sendDataObject({"cmd": CBProtocol.listRtmpRoom_80001});//获取rtmp列表
						//  TavenHttpService.addHttpService(TavenHttpService.rtmp_SERVICE_U, onRtmpListResult);
					}
					else {
						NetManager.getInstance().sendDataObject({"cmd": CBProtocol.rtmp_client_80002});
						//   TavenHttpService.addHttpService(TavenHttpService.rtmp_SERVICE_D, onRtmpListResult);
					}
				}
				//NetManager.sendDataObject({"cmd": 11008});//拉取管理员列表
				NetManager.getInstance().sendDataObject({"cmd": CBProtocol.listSeat});//拉取贡献排行
				NetManager.getInstance().sendDataObject({"cmd": CBProtocol.getKtvOrder});//拉取本场排行
				NetManager.getInstance().sendDataObject({"cmd": CBProtocol.listCar});//拉取车位
				ModuleLoaderManger.getInstance().getModule(ModuleNameType.SIDESGROUP)["updateViewCheck"]();
				break;
			case  CBProtocol.enterRoomLimit_10011://房间进入限制验证
				trace("房间进入限制验证", JSON.stringify(sObject));
				//{"open":1,"mailCheckedLimit":0,"roomid":101152823,"richLimit":2000,"show":1,"cmd":10011,"richLvLimit":0}
				var sides_Module:MovieClip           = ModuleLoaderManger.getInstance().getModule(ModuleNameType.SIDESGROUP) as MovieClip;
				DataCenterManger.userData.limitEnter = sObject;
				var limitModule:MovieClip            = ModuleLoaderManger.getInstance().getModule(ModuleNameType.LIMIT_EnterModule) as MovieClip;
				if ((int(DataCenterManger.userData.ruled) == 3) && (sObject.roomid == DataCenterManger.userData.uid))  //如果是主播 显示限制按钮
				{
					sides_Module.showLimitVisible(sObject.show, sObject.open);
					limitModule.hide();
				}
				else  //如果不是主播 并且打开了验证
				{
					sides_Module.showLimitVisible(false, sObject.open);
					if (!DataCenterManger.vipInfo.allowvisitroom) //如果贵族开通了 不限制条件 不用判断
					{
						limitModule.dispatchEvent(new CBModuleEvent(CBModuleEvent.LIMIT_ROOM, false, sObject));
					} else {
						limitModule.visible = false;
					}
				}
				break;
			case CBProtocol.enterRoomLimit_10014:
				limitModule = ModuleLoaderManger.getInstance().getModule(ModuleNameType.LIMIT_EnterModule) as MovieClip;
				limitModule.dispatchEvent(new CBModuleEvent(CBModuleEvent.LIMIT_ROOM_QAINGENTER, false, sObject));
				break;
			case CBProtocol.onEnterRoom_VIP_10013://初始化VIP信息
				DataCenterManger.vipInfo.initInfo(sObject);
				vipModule.handMessage(sObject);
				break;
			case CBProtocol.VIP_OPEN_18001:// 开通提示框
				var hint:String    = "恭喜您!【{0}】在你房间内开通{1}，您获得{2}钻石返现!请到个人中心，佣金提成中查看记录.";
				var vip:int        = sObject.vip;
				var icoName:String = "";
				switch (vip) {
					case 1101:
						icoName = "七品白尊";
						break;
					case 1102:
						icoName = "六品翠尊";
						break;
					case 1103:
						icoName = "五品绿尊";
						break;
					case 1104:
						icoName = "四品青尊";
						break;
					case 1105:
						icoName = "三品蓝尊";
						break;
					case 1106:
						icoName = "二品红尊";
						break;
					case 1107:
						icoName = "一品近尊";
						break;
				}
				Alert.Show(StringUtil.substitute(hint, sObject.name, icoName, sObject.cashback), "提示");
				break;
		}
	}
}
}

