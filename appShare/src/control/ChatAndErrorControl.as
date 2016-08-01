/**
 * Created by Taven on 2015/9/9.
 */
package control {
import com.rover022.event.CBModuleEvent;
import com.rover022.CBProtocol;
import com.rover022.IChat;
import com.rover022.ModuleNameType;
import com.rover022.vo.UserVo;

import display.ui.Alert;

import flash.display.MovieClip;
import flash.utils.setTimeout;

import manger.ClientManger;
import manger.ModuleLoaderManger;

import tool.FormatDataTool;
import tool.VideoTool;

public class ChatAndErrorControl extends BaseControl {
	public var errorArray:Array = [];

	override public function regMsg():void {
		super.regMagHanlde(CBProtocol.publicMessage, handleMessgae);
		super.regMagHanlde(CBProtocol.pushErrorMethod, handleMessgae);
		errorArray[1801] = "被踢的玩家不存在";
		errorArray[1802] = "不能踢管理员";
		errorArray[1803] = "该用户已不在当前房间，操作失败!";
		errorArray[1804] = "贵族不能踢高等级用户";
		errorArray[1805] = "贵族最大踢人次数";
		errorArray[1806] = "被踢用户具有防踢人权限，踢人失败！";
		errorArray[1807] = "普通用户没有禁言权限,请充值贵族并提升您的贵族等级!";
		errorArray[1808] = "禁言次数超过最大次数";
		errorArray[1809] = "贵族不能禁言高等级用户";
		errorArray[1810] = "被禁言用户具有防禁言权限，禁言失败！";
		errorArray[1811] = "普通用户不能踢人！";
		errorArray[1812] = "被禁言人还在禁言当中！";
		errorArray[1813] = "不能禁言管理员！";
		errorArray[1814] = "没有权限,请充值升级你的贵族等级！";
		//
		errorArray[2007] = "您的余额不足，请充值！";
		errorArray[2014] = "直播暂未开始，不能抢座！";
		errorArray[2012] = "您的余额不足，不能抢座！";
		errorArray[2015] = "不能在自己房间内抢座位！";
		errorArray[2102] = "不能超过40个管理员！";
		errorArray[2103] = "直播暂未开始，不能飞屏！";
		errorArray[2116] = "直播暂未开始，不能广播！";
		errorArray[1514] = "只有主播和管理员才能踢人！";
		errorArray[1516] = "不是房主不能踢人！";
	}

	override public function handleMessgae(data:*):void {
		var sObject:Object = data;
		var view:MovieClip = ModuleLoaderManger.getInstance().getModule(ModuleNameType.VIDEO_ROOM) as MovieClip;
		switch (data.cmd) {
			case CBProtocol.publicMessage://聊天
				//广告过滤
				switch (sObject.type) {
					case 0://公聊
						onChatHandle(sObject, 1);
						var content:String = sObject.content;
						content            = content.split("{").join("");
						content            = content.split("}").join("");
						view.seats_Module.setParkSpeak({uid: sObject.sendUid, msg: content});
						break;
					case 1://私聊
						onChatHandle(sObject, 2);
						break;
					case 3://系统喇叭
						ClientManger.getInstance().addChatSpanMessage({
							message: "[系统消息]:" + sObject.content,
							color:   "0xFFCC00"
						});
						break;
					case 4://小喇叭
						break;
					case 5://大喇叭
						var _user:UserVo         = new UserVo({name: sObject.sendName, hidden: sObject.sendHidden});
						view.speaker_Module.text = sObject.content + "&name=" + FormatDataTool.getNickeName(_user);
						break;
					case 6://个性化通知
						if (sObject.content && sObject.content.indexOf("跑马会") > -1) {
							setTimeout(function ():void {
								onChatHandle(sObject, 6);
							}, 12000)
						}
						else {
							onChatHandle(sObject, 6);
						}
						break;
					case 9://飞屏
						_user               = new UserVo({name: sObject.sendName, hidden: sObject.sendHidden});
						var obj:Object      = FormatDataTool.getNickeName(_user) + "说:" + sObject.content;
						var e:CBModuleEvent = new CBModuleEvent(CBModuleEvent.FLY_PINGMU);
						e.dataObject        = obj;
						view.dispatchEvent(e);
						break;
					case 7://开通贵族提示
						onChatHandle(sObject, 6);
						break;
					case 10://贵族vip到期通知
						onChatHandle(sObject, 10);
						break;
					default:
				}
				break;
			case CBProtocol.pushErrorMethod://出错
				if (errorArray[sObject.errorCode]) {
					Alert.Show(errorArray[sObject.errorCode]);
					return;
				}
				switch (sObject.errorCode) {
					case 1003://送礼物余额不足
						Alert.Show("您的当前帐户余额不足,请您充值哦!", "通知");
						break;
					case 1008://禁止聊天
						ClientManger.getInstance().addChatSpanMessage({message: "您已经被主播(或管理员)禁言了．", color: "0xFF00FF"});
						break;
					case 1543://禁止进入
						Alert.Show("您被主播(或管理员)踢出该房间，30分钟内不能进入．", "通知", true, 3, true);
						break;
					case 2001://房间密码错误
						Alert.Show("进入失败!\n房间密码输入不正确，请重新输入.", "提醒");
						ClientManger.getInstance().enterRoomVideo();
						break;
					case 2002://房间扣费余额不,无法进入房间
						Alert.Show("进入失败!\n您当前余额不足，请您充值后再观看.", "通知");
						ClientManger.getInstance().enterRoomVideo();
						break;
					case 2003://房间已满员
						Alert.Show("进入失败!\n房间已经满员了！", "提醒");
						ClientManger.getInstance().enterRoomVideo();
						break;
					case 2004://房间免费时间已到
						ClientManger.getInstance().enterRoomVideo(0, "", true);//全T到大厅
						break;
					case 2005://游客不能进入
						Alert.Show("进入失败！\n该房间限制游客进入！", "提醒");
						ClientManger.getInstance().enterRoomVideo();
						break;
					case 2006://非vip不能进入
						Alert.Show("进入失败！\n该房间为VIP专属区,请开通包月VIP会员再进入，谢谢！", "提醒");
						ClientManger.getInstance().enterRoomVideo();
						break;
					case 4001://当前身份不能增送贵族礼物
						Alert.Show("当前身份不能增送贵族礼物,先成为贵族吧!", "提醒", true, 3, false, function ():void {
							VideoTool.jumpToGuiZhuURL();
						});
						break;
					default:
						Alert.Show("出错啦~请刷新页面重新进入~错误码是:" + sObject.errorCode, "出错啦");
				}
				break;
		}
	}

	/**
	 * 处理聊天返回逻辑
	 * @param sObject
	 * @param type
	 */
	public function onChatHandle(sObject:Object, type:int):void {
		var ichat:IChat = ModuleLoaderManger.getInstance().getModule(ModuleNameType.CHAT_MODULE2) as IChat;
		ichat.onPublicChat(sObject, type);
	}
}
}
