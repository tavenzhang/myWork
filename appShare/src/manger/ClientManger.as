/**
 * Created by Roger on 2014/11/24.
 */
package manger {
import com.junkbyte.console.Cc;
import com.junkbyte.console.KeyBind;
import com.rover022.CBProtocol;
import com.rover022.IChat;
import com.rover022.IPlayer;
import com.rover022.IVideoRoom;
import com.rover022.ModuleNameType;
import com.rover022.event.CBModuleEvent;
import com.rover022.vo.GiftVo;
import com.rover022.vo.PlayerType;
import com.rover022.vo.VideoConfig;

import control.ControlsManger;

import display.ui.Alert;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.external.ExternalInterface;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.ui.Keyboard;
import flash.utils.setInterval;

import ghostcat.manager.RootManager;

import net.CBHttpServiceProxy;
import net.NetManager;

import tool.FormatDataTool;
import tool.JsHelp;
import tool.VideoTool;

/**
 * 房间功能管理者
 * 负责房间里面一切功能的实现
 */
public class ClientManger {
	private static var _instance:ClientManger;
	public var view:IVideoRoom;
	public var roomPublic:String;//房间公告
	/**
	 * http请求代理员
	 */
					   public var httpProxy:CBHttpServiceProxy = new CBHttpServiceProxy("");

	/**
	 * 注册被管理的客户端对象
	 * @param src
	 */
	public function register(src:IVideoRoom):void {
		view                = src;
		VideoTool.videoRomm = view;
	}

	public function ClientManger() {
	}

	public static function getInstance():ClientManger {
		if (_instance == null) {
			_instance = new ClientManger();
			setInterval(_instance.checkisGuestFun, 120000);
		}
		//每隔30秒调用注册js行数 roger
		return _instance;
	}

	private function checkisGuestFun():void {
		if (NetManager.getInstance().appInit) {
			ClientManger.getInstance().isGuestAndGuestRegister();
		}
	}

	/**
	 * 添加一条聊天记录
	 * @param msg
	 * @param _type
	 * @param _index
	 */
	public function addChatSpanMessage(src:Object):void {
		var iChat:IChat = ModuleLoaderManger.getInstance().getModule(ModuleNameType.CHAT_MODULE2) as IChat;
		if (iChat) {
			iChat.onChatSystemMessage(src);
		}
	}

	/**
	 * 从页面吧key 拉下来
	 * @param username
	 * @param userpassword
	 * @param onCompleteFun
	 */

	public function getMsgKeyFromWeb(username:String, userpassword:String, onCompleteFun:Function):void {
		var url:String = VideoConfig.httpFunction + "/login?uname=" + username + "&password=" + userpassword + "&_m=test";
		trace("web:", url);
		var urlRequest:URLRequest = new URLRequest(url);
		var urlLoader:URLLoader   = new URLLoader();
		urlLoader.load(urlRequest);
		urlLoader.addEventListener(Event.COMPLETE, onUrlLoadComplete);
		urlLoader.addEventListener(IOErrorEvent.IO_ERROR, function (evt:IOErrorEvent):void {
			trace("getMsgKeyFromWeb error: " + url)
		});
		function onUrlLoadComplete(e:Event):void {
			var _date:String = (e.currentTarget as URLLoader)["data"];
			var _obj:Object  = JSON.parse(_date);
			if (_obj.status == 1) {
				Cc.log("_obj.msg", _obj.msg);
				onCompleteFun.call(null, _obj.msg)
			} else {
				Cc.log("web login fail!", _obj.msg);
			}
		}
	}

	/**
	 * 格式化用户权限
	 * @param _v
	 */
	public function formatPurview(_v:int):void {//格式化权限
		var uiRoom:IVideoRoom        = view;
		UserVoDataManger.playerState = _v;
		var sides_Module:MovieClip   = ModuleLoaderManger.getInstance().getModule(ModuleNameType.SIDESGROUP) as MovieClip;
		sides_Module.showTranUsers(false);//转移观众按钮
		var video_Module:IPlayer = ModuleLoaderManger.getInstance().getModule(ModuleNameType.VIDEOPLAYER) as IPlayer;
		video_Module.dispatchEvent(new CBModuleEvent(CBModuleEvent.PLAYER_UPDATE));
	}

	/**
	 * 移除
	 * @param _obj
	 */
	public function removeUserVideo(_obj:Object):void {
		var uiRoom:IVideoRoom = view;
		if (UserVoDataManger.userData.uid == _obj.uid) {
			var video_Module:IPlayer = ModuleLoaderManger.getInstance().getModule(ModuleNameType.VIDEOPLAYER) as IPlayer;
			video_Module.playRTMP(UserVoDataManger.videoOwner.sid, UserVoDataManger.roomData.rtmp);
		}
	}

	/**
	 * 进入视频房间
	 */
	public function enterRoomVideo(_roomid:int = 0, _pass:String = "", _bool:Boolean = false):void {
		if (_pass != null && _pass != "") {//有密码
			Alert.Show("密码房", "警告");
			return;
		} else if (UserVoDataManger.roomData.roomid != _roomid || _bool) {//无密码
			if (_roomid != 0 && UserVoDataManger.cutoData && UserVoDataManger.cutoData.host) {
				NetManager.getInstance().connectSocket(UserVoDataManger.cutoData.host, UserVoDataManger.cutoData.port, _roomid, VideoConfig.loginKey);
			} else {
				NetManager.getInstance().sendDataObject({"cmd": 10010, roomid: _roomid});//切换房间
			}
		}
		UserVoDataManger.cutoData = null;
	}

	/**
	 * 是否是房间视频流的发布者
	 */
	public function get isRoomPublisher():Boolean {
		return UserVoDataManger.userData.uid == UserVoDataManger.roomData.roomid;
	}

	/**
	 * 是否是房间视频流的发布者
	 */
	public function get isRoomPublishing():Boolean {
		return false
	}

	/**
	 * 播放视频
	 * rtmp格式视频文件
	 * @param _obj
	 */
	public function playRtmpVideo(_obj:Object):void {
		var videoIfo:MovieClip;
		videoIfo                 = ModuleLoaderManger.getInstance().getModule(ModuleNameType.VIDEO_PLAY_INFO) as MovieClip;
		var video_Module:IPlayer = ModuleLoaderManger.getInstance().getModule(ModuleNameType.VIDEOPLAYER) as IPlayer;
		videoIfo.formatData(_obj, isRoomPublisher);
		if (isRoomPublisher) {//如果是主播,则断开流
			//uiRoom.video_Module.closePublish();/
		}
		if (_obj == null) {
			return;
		}
		// var video_Module:MovieClip =  ModuleLoaderManger.getInstance().getModule(ModuleNameType.VIDEOPLAYER) as MovieClip;
		if (UserVoDataManger.getInstance().isSelf(_obj.uid)) {
			UserVoDataManger.getInstance().isVideoPublisher = true;
			Cc.log("主播发布模式：", "sid:" + _obj.sid, "rtmp地址:", _obj.rtmp);
			video_Module.publish(_obj.sid, _obj.rtmp);
			VideoConfig.connectRTMP = _obj.rtmp;
		} else {
			Cc.log("正常播放模式", _obj.sid, _obj.rtmp);
			video_Module.playRTMP(_obj.sid, _obj.rtmp);
			VideoConfig.connectRTMP = _obj.rtmp;
		}
		var _urlPorxy:String = FormatDataTool.formatURL(VideoConfig.httpFunction + VideoConfig.configXML.http.@userInfo.toString(), _obj.uid);
		ClientManger.getInstance().httpProxy.operate(_urlPorxy, null, view["onPlayerStatusEvent"]);
		Cc.log("_urlPorxy-------------------------------------------=" + _urlPorxy);
	}

	//########################## call js #################################################
	/**
	 * 获取房间ID
	 */
	public function getRoomID():String {
		if (ExternalInterface.available) {
			var funcName:String = VideoConfig.configXML.js.@roomid;
			return ExternalInterface.call(funcName)
		} else {
			return "";
		}
	}

	/**
	 * 登陆
	 */
	public function guestLogin():void {
		( view as MovieClip).stage.dispatchEvent(new Event("loginEvent"));
		try {
			if (ExternalInterface.available) {
				var funcName:String = VideoConfig.configXML.js.@login;
				var timeOver:int    = VideoTool.isOverTime();
				ExternalInterface.call(funcName, timeOver);
			}
		} catch (e:*) {
		}
	}

	/**
	 * 游客注册
	 */
	public function guestRegister():void {
		NavigatorManager.guestRegister();
	}

	/**
	 * 检查然后弹出登录窗口
	 */
	public function isGuestAndGuestRegister():Boolean {
		if (UserVoDataManger.playerState == PlayerType.GUEST) {
			guestRegister();
			return true;
		} else {
			return false;
		}
	}

	/**
	 * 登出
	 */
	public function userLogout():void {
		Alert.Show("亲,不要走,主播们没有你的陪伴会伤心的！\n您还是需要退出吗?", "登出确认", false, 3, true, function (_v:*):void {
			if (_v == 1) {
				try {
					if (ExternalInterface.available) {
						var funcName:String = VideoConfig.configXML.js.@logout;
						ExternalInterface.call(funcName);
					}
				} catch (e:*) {
				}
			}
		});
	}

	/**
	 * 客服
	 */
	public function cservice():void {
		try {
			if (ExternalInterface.available) {
				var funcName:String = VideoConfig.configXML.js.@cservice;
				ExternalInterface.call(funcName);
			}
		} catch (e:*) {
		}
	}

	/**
	 * 用户充值
	 */
	public function userPay():void {
		if (ClientManger.getInstance().isGuestAndGuestRegister()) {
			return;
		}
		if (ExternalInterface.available) {
			var funcName:String = VideoConfig.configXML.js.@upay;
			ExternalInterface.call(funcName);
		}
	}

	/**
	 * 用户VIP
	 */

	public function userVIP():void {
		try {
			if (ExternalInterface.available) {
				var funcName:String = VideoConfig.configXML.js.@uvip;
				ExternalInterface.call(funcName);
			}
		} catch (e:*) {
		}
	}

	/**
	 * 个人中心
	 * 用户信息
	 */
	public function userInfo():void {
		try {
			if (ExternalInterface.available) {
				var funcName:String = VideoConfig.configXML.js.@uinfo;
				ExternalInterface.call(funcName);
			}
		} catch (e:*) {
		}
	}

	/**
	 * 我的关注
	 */
	public function userAttention():void {
		try {
			if (ExternalInterface.available) {
				var funcName:String = VideoConfig.configXML.js.@attention;
				ExternalInterface.call(funcName);
			}
		} catch (e:*) {
		}
	}

	/**
	 * 我的道具
	 */
	public function userProps():void {
		try {
			if (ExternalInterface.available) {
				var funcName:String = VideoConfig.configXML.js.@props;
				ExternalInterface.call(funcName);
			}
		} catch (e:*) {
		}
	}

	/**
	 * 消费记录
	 */
	public function userConsRecords():void {
		try {
			if (ExternalInterface.available) {
				var funcName:String = VideoConfig.configXML.js.@consRecords;
				ExternalInterface.call(funcName);
			}
		} catch (e:*) {
		}
	}

	/**
	 * 私信
	 */
	public function userMsgList():void {
		try {
			if (ExternalInterface.available) {
				var funcName:String = VideoConfig.configXML.js.@userMsg;
				ExternalInterface.call(funcName);
			}
		} catch (e:*) {
		}
	}

	/**
	 * 系统消息
	 */
	public function systemMsgList():void {
		try {
			if (ExternalInterface.available) {
				var funcName:String = VideoConfig.configXML.js.@systemMsg;
				ExternalInterface.call(funcName);
			}
		} catch (e:*) {
		}
	}

	/**
	 * 收藏
	 */
	public function keepHttp():void {
		try {
			if (ExternalInterface.available) {
				var funcName:String = VideoConfig.configXML.js.@keep;
				ExternalInterface.call(funcName);
			}
		} catch (e:*) {
		}
	}

	/**
	 * 商城
	 */
	public function gotoMarket():void {
		try {
			if (ExternalInterface.available) {
				var funcName:String = VideoConfig.configXML.js.@market;
				ExternalInterface.call(funcName);
			}
		} catch (e:*) {
		}
	}

	/**
	 * 回到大厅
	 */
	public function gotoHall():void {
		try {
			if (ExternalInterface.available) {
				var funcName:String = VideoConfig.configXML.js.@hall;
				ExternalInterface.call(funcName);
			}
		} catch (e:*) {
		}
	}

	/**
	 * 获取用户的key
	 */
	public function getUserKey():String {
		var _str:String = VideoConfig.loginKey;
		try {
			if (ExternalInterface.available) {
				var funcName:String = VideoConfig.configXML.js.@ukey;
				_str                = ExternalInterface.call(funcName);
			}
		} catch (e:*) {
		}
		return _str;
	}

	/**
	 * 用户开通贵族状态改变 //roomid,uid,name,vip,cashback<
	 */
	public function openVipNotice(obj:String):void {
		var dataStr:Array = obj.split(",");
		NetManager.getInstance().sendDataObject({
			"cmd":      CBProtocol.VIP_OPEN_18001,
			"roomid":   int(dataStr[0]),
			"uid":      int(dataStr[1]),
			"name":     dataStr[2],
			"vip":      int(dataStr[3]),
			"cashback": int(dataStr[4])
		});//通知java 更改贵族状态
	}

	/**
	 * 播放礼物动画
	 * @param _giftObj
	 */
	public function playGiftAnimation(_giftObj:Object):void {
		if (!UserVoDataManger.isShowGiftEffect)//全局设置是否显示礼物特效
			return;
		var vo:GiftVo = ClientManger.getInstance().getGiftVoByID(_giftObj.gid);
		vo.sendName   = _giftObj.sendName;
		vo.recName    = _giftObj.recName;
		if (vo.id == "") {
			//Alert.Show("没有这种礼物", "提醒");
			Cc.log(_giftObj.gid + "没有这种礼物");
			return
		}
		vo.num = _giftObj.gnum;
		view["giftPool"].quickShowEff(vo);
	}

	/**
	 *
	 * @param id
	 * @return
	 */
	public function getGiftVoByID(id:String):GiftVo {
		var _xml:*        = VideoConfig.giftConfig.item.(@id == id);
		var giftVo:GiftVo = new GiftVo();
		giftVo.id         = _xml.@id;
		giftVo.name       = _xml.@name;
		giftVo.num        = _xml.@num;
		giftVo.url        = _xml.@url;
		giftVo.type       = _xml.@type;
		giftVo.x          = _xml.@x;
		giftVo.y          = _xml.@y;
		giftVo.time       = _xml.@time;
		giftVo.scaleX     = _xml.@xScale;
		giftVo.scaleY     = _xml.@yScale;
		giftVo.playType   = _xml.@playType;
		return giftVo;
	}

	/**
	 * 回到房间
	 * @param _id
	 */
	public function gotoRoom(_id:int):void {
		try {
			var hostId:int = view.getDataByName(ModuleNameType.USERROOMDATA).roomid;
			if (_id != hostId) {
				JsHelp.gotoRoom(_id);
			}
			else {
				view.showAlert("您当前正在此房间！");
			}
		} catch (e:*) {
		}

	}

	/**
	 * 设置管理员
	 */
	public function setManger(uid:int, uname:String):void {
		Alert.Show("您是否要提升'" + uname + "'为您的管理员?", "设置管理员",
				false, 3,
				true,
				function (_v:*):void {
					if (_v == 1) {
						NetManager.getInstance().sendDataObject({cmd: 11006, uid: uid});
					}
				});
	}

	/**
	 * 取消管理员
	 */
	public function disposeManger(uid:int, uname:String):void {
		Alert.Show("您是否要取消'" + uname + "'的管理员身份?", "取消管理员",
				false,
				3,
				true,
				function (_v:*):void {
					if (_v == 1) {
						NetManager.getInstance().sendDataObject({cmd: 11007, uid: uid});
					}
				});
	}

	/**
	 * 踢人
	 * 禁言
	 */
	public function kickOutPlayer(uid:int, uname:String, _type:int):void {
		if (_type == 0) {
			Alert.Show("您确定要把 " + uname + " T出房间吗?他将30分钟内不能再次进入您的房间!", "T出房间",
					false,
					3,
					true,
					function (_v:*):void {
						if (_v == 1) {
							NetManager.getInstance().sendDataObject({
								"cmd": CBProtocol.kickOut,
								uid:   uid,
								type:  _type
							});
						}
					});
		} else {
			Alert.Show("您确定要把 " + uname + " 禁言吗?他将30分钟内不能在房间内发送聊天信息!",
					"禁止聊天",
					false,
					3,
					true,
					function (_v:*):void {
						if (_v == 1) {
							NetManager.getInstance().sendDataObject({
								"cmd": CBProtocol.kickOut,
								uid:   uid,
								type:  _type
							});
						}
					});
		}
	}

	/**
	 * 显示小游戏
	 *  功能关闭中 8.1
	 * @param e
	 */
	public function showCarGame(e:Event = null):void {
		var clip:MovieClip = ModuleLoaderManger.getInstance().getModule("cargame") as MovieClip;
		if (clip) {
			if (clip.parent) {
				clip.parent.removeChild(clip);
			} else {
				(view as Sprite).addChild(clip);
			}
		} else {
			ModuleLoaderManger.getInstance().loadModule(view, 80, 240, VideoConfig.HTTP + "Modules/CarGame.swf?version=" + VideoConfig.VERSION, "CarGame", "cargame");
		}
	}

	/**
	 * 显示小游戏
	 *  功能关闭中 8.1
	 * @param e
	 */
	public function showFingerGame(e:Event = null):void {
		var clip:MovieClip = ModuleLoaderManger.getInstance().getModule("FingerGame") as MovieClip;
		if (clip) {
			if (clip.parent) {
				clip.parent.removeChild(clip);
			} else {
				(view as Sprite).addChild(clip);
			}
		} else {
			ModuleLoaderManger.getInstance().loadModule(view, 80 + 480, 240, VideoConfig.HTTP + "Modules/FingerGuessingGame.swf?version=" + VideoConfig.VERSION, "FingerGuessingGame", "FingerGame");
		}
	}

	//===============   debug相关    ==================tryConnect
	public function initCCdebug():void {
		Cc.startOnStage(RootManager.stage, "5193063"); // "`" - change for password. This will start hidden
		Cc.visible                   = false; // Show console, because having password hides console.
		Cc.config.commandLineAllowed = true; // enable advanced (but security risk) features.
		Cc.config.tracing            = true; // Also trace on flash's normal trace
		Cc.config.remotingPassword   = ""; // Just so that remote don't ask for password
		Cc.remoting                  = true; // Start sending logs to remote (using LocalConnection)
		Cc.commandLine               = true; // Show command line
		Cc.height                    = 220; // change height. You can set x y width height to position/size the main panel
		Cc.addSlashCommand("closeSocket", function ():void {
			NetManager.getInstance().closeSocket();
		});
		Cc.addSlashCommand("closePublish", function ():void {
			var iplay:IPlayer = ModuleLoaderManger.getInstance().getModule(ModuleNameType.VIDEOPLAYER) as IPlayer;
			iplay.closePublish();
		});
		Cc.addSlashCommand("onCloseHandler", function ():void {
			NetManager.getInstance().onCloseHandler();
		});
		Cc.addSlashCommand("showGift", function (num:int):void {
			//Cc.log("rover023@qq.com[虚拟发礼物]");
			ClientManger.getInstance().playGiftAnimation({
				gid:  "310016",
				gnum: num
			});//把数据传入到礼物模块
		}, "送礼物");
		Cc.bindKey(new KeyBind(Keyboard.NUMBER_1, false, true), function ():void {
			ClientManger.getInstance().getMsgKeyFromWeb(VideoConfig.testUID, VideoConfig.testPASS, view["AirConnectService"]);
		});
		//DisplayMapAddon.registerCommand();
		Cc.bindKey(new KeyBind(Keyboard.NUMBER_2, false, true), function ():void {
			//Cc.log("rover023@qq.com[虚拟发礼物]");
			ClientManger.getInstance().playGiftAnimation({
				gid:  "310032",
				gnum: "521"
			});//把数据传入到礼物模块
		});
		var c_roomid:int = 101239384//101116443//;
		Cc.bindKey(new KeyBind(Keyboard.NUMBER_3, false, true), function ():void {
//			VideoConfig.roomID = c_roomid;
			ClientManger.getInstance().getMsgKeyFromWeb("raby84@qq.com", "123456", view["AirConnectService"]);
		});
		Cc.bindKey(new KeyBind(Keyboard.NUMBER_4, false, true), function ():void {
//			VideoConfig.roomID = c_roomid;
			ClientManger.getInstance().getMsgKeyFromWeb("raby99@qq.com", "123456", view["AirConnectService"]);
		});
		//
		Cc.bindKey(new KeyBind(Keyboard.NUMBER_5, false, true), function ():void {
			ClientManger.getInstance().getMsgKeyFromWeb("zxhua@qq.com", "shallay ", view["AirConnectService"]);
		});
		//测试礼物轮播
		Cc.bindKey(new KeyBind(Keyboard.NUMBER_7, false, true), function ():void {
			var _str:String = '{"outName":"ronnie3","uid":100003,"hidden":1,"name":"test20","outId":1011200281,"cmd":18005,"outHidden":0,"mark":1}';
//            var _str:String = '{"outId":101120028,"mark":1,"hidden":1,"uid":1011200281,"outHidden":0,"outName":"ronnie2","name":"test20","cmd":18005}';
			var obj:Object  = JSON.parse(_str);
			trace("测试新的数据");
			ControlsManger.handleMessgae(obj.cmd, obj);
			return;
			var sObject:Object = JSON.parse('{"times":4,"gnum":1,"created":"16:03","recIcon":0,"recRuled":3,"sendUid":101120028,"cmd":40003,"recUid":101116395,"sendName":"flash小猪","recName":"ever","roomid":101116395,"richLv":1,"lv":1,"icon":0,"ruled":0,"recLv":1,"price":1,"recRichLv":10,"gid":310006}');
			var ichat:IChat    = ModuleLoaderManger.getInstance().getModule(ModuleNameType.CHAT_MODULE2) as IChat;
			ichat.onComboGiftChat(sObject);
		});
		//
		Cc.bindKey(new KeyBind(Keyboard.NUMBER_6, false, true), function ():void {
			var sObject:Object = JSON.parse('{"ruled":0,"roomid":101116395,"recRichLv":10,"lv":1,"gnum":1,"created":"18:11","recIcon":0,"cmd":501,"sendUid":101120028,"gid":310022,"icon":0,"recUid":101116395,"price":5,"sendName":"flash小猪","richLv":8,"recName":"ever","recLv":4,"recRuled":3}');
			NetManager.getInstance().client.socketApp(sObject);
		});
		//添加一些指令
		Cc.addSlashCommand("addCommond", function (_cmd:int):void {
			//trace("删除指令", _cmd);
			if (UserVoDataManger.filterCMDArray.indexOf(_cmd) != -1) {
				var _index:int = UserVoDataManger.filterCMDArray.indexOf(_cmd);
				UserVoDataManger.filterCMDArray.splice(_index, 1);
				Cc.error("添加指令成功")
			}
		});
		Cc.addSlashCommand("deleteCommond", function (_cmd:int):void {
			//trace("删除指令", _cmd);
			if (UserVoDataManger.filterCMDArray.indexOf(_cmd) == -1) {
				UserVoDataManger.filterCMDArray.push(_cmd);
				Cc.error("删除指令成功")
			}
		});
		Cc.addSlashCommand("pushCMDJSON", function (_str:String):void {
			var obj:Object = JSON.parse(_str);
			trace("测试新的数据");
			ControlsManger.handleMessgae(obj.cmd, obj);
		});
		if (ExternalInterface.available) {
			ExternalInterface.addCallback("testYoung", function (src:* = null):void {
				Cc.log("后台小弟欢迎你,后面可以接一个参数", src);
			});
		}
	};
}
}
