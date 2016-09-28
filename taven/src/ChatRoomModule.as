package {
import com.bit101.components.Style;
import com.rover022.event.CBModuleEvent;
import com.rover022.CBProtocol;
import com.rover022.IChat;
import com.rover022.IVideoModule;
import com.rover022.IVideoRoom;
import com.rover022.ModuleNameType;
import com.rover022.tool.SensitiveWordFilter;
import com.rover022.vo.PlayerType;
import com.rover022.vo.UserVo;
import com.rover022.vo.VideoConfig;

import flash.display.*;
import flash.events.*;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.ui.Keyboard;
import flash.utils.Dictionary;
import flash.utils.getTimer;

import flashx.textLayout.elements.FlowElement;


import flashx.textLayout.elements.InlineGraphicElement;
import flashx.textLayout.elements.LinkElement;
import flashx.textLayout.elements.ParagraphElement;
import flashx.textLayout.elements.SpanElement;

import ghostcat.events.TickEvent;
import ghostcat.text.HTMLUtil;
import ghostcat.text.NumberUtil;
import ghostcat.util.Tick;

import manger.ClientManger;
import manger.DataCenterManger;
import manger.HttpLinkManger;

import taven.chatModule.*;

import tool.FormatDataTool;

[SWF(backgroundColor='0x999999', height=700)]
public class ChatRoomModule extends MovieClip implements IVideoModule,IChat {
	public var _input:InputUI;
	private var _videoRoom:IVideoRoom;
	public var giftOutput:RichText;
	public var publicOutput:RichText;
	public var privateOutput:RichText;
	private var _width:Number            = 280;
	private var _height:Number           = 330;
	//private var beasHeight:Number        = 378 - 48;
	private var view:chatUIMC            = new chatUIMC();
	private var maxChars:uint            = 30;
	private const ERROR_TXT1:String      = "您发送消息过于频繁,请休息一下.";
	private const ERROR_TXT2:String      = "发送消息内容不能为空.";
	private const ERROR_TXT3:String      = "发送消息文字过长.";
	private const ERROR_TXT4:String      = "[系统提示]:请先登录.";
	public var minY:Number               = -5;
	public var maxHeight:Number            = 820;
	public static var faceArr:Dictionary = new Dictionary();
	public var lastSendTime:Number       = -30000;
	public var lastGiftSendTime:Number   = 0;
	public var giftObjectArray:Array     = [];
	//max
	public var VIPColor:Array            = [];

	private var giftHeight:int;


	public function ChatRoomModule():void {
		VIPColor[1101] = 0xfdebeb;
		VIPColor[1102] = 0xc9fbcc;
		VIPColor[1103] = 0xd5f9d3;
		VIPColor[1104] = 0x09E1F9;
		VIPColor[1105] = 0x499cfa;
		VIPColor[1106] = 0xfdebeb;
		VIPColor[1107] = 0xFFED00;
		//
		//addChild(view);
		initChatUI();
		addEventListener(Event.ADDED_TO_STAGE, addStageHandle);
	}

	private function addStageHandle(event:Event):void {
		stage.addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
		stage.addEventListener(Event.RESIZE, onResizeHandle);
		onResizeHandle(null);
		_input.initFaceDic();
		Tick.instance.addEventListener(TickEvent.TICK, onTickHandle);
	}

	public function handle(src:Object, userobject:Object):void {
		//netHandle.chatHandle(src, userobject);
	}

	public function clear():void {
		giftOutput.clear();
		publicOutput.clear();
		privateOutput.clear();
		_input.clear()
	}


	override public function set height(value:Number):void {
		//super.height = value;

		setHeight(value);
	}

	private function onResizeHandle(event:Event):void {
//		var num:Number = stage.stageHeight <= maxHeight ? stage.stageHeight : maxHeight;
//		var chaNum:int = num - 700;
//		chaNum         = chaNum >= minY ? chaNum : minY;
//		//trace(chaNum)
//		setHeight(num);
	}

	public function initChatUI():void {
		Style.setStyle(Style.DARK);
		Style.embedFonts     = false;
		Style.fontSize       = 12;
		//输出wenb
		giftHeight           = 110;
		giftOutput           = new RichText(_width, giftHeight);
		giftOutput.maxLength = 10;
		addChild(giftOutput);

//		var _mc:spileLineMc = new spileLineMc();
//		_mc.y               = giftHeight;
//		_mc.width           = _width;
//		addChild(_mc);
//		publicOutput   = new RichText(_width, _height - giftHeight + 100);
//		publicOutput.y = giftHeight + 10;
		publicOutput   = new RichText(_width, _height+100);
		publicOutput.y =  giftHeight+10;
		addChild(publicOutput);
		privateOutput   = new RichText(_width, 100);
		addChild(privateOutput);
		//输入文本框
		_input = new InputUI(_width, this);
		_input.view.sendNews_bt.addEventListener(MouseEvent.CLICK, sendMessage);
		_input.view.flyNews_bt.addEventListener(MouseEvent.CLICK, sendFlyMessage);
		addChild(_input);
		//横线
		//view.line_mc.width = _width;
		//view.line_mc.y     = _height + 4;
		addEventListener("addItem", onAddItemHandle);
		//
//		setTimeout(function ():void {
//			for (var i:int = 0; i < 4; i++) {
//				var pCustom:ParagraphElement = TextFlowTool.buildParagraphElement();
//				var giftS:SpanElement        = makeSpan("[礼物]", 0xf955ff);
//				pCustom.addChild(giftS)
//				giftOutput.addRichChild(pCustom);
//			}
//		}, 3000)
	}

	private function onAddItemHandle(event:Event):void {
		_input.addItem(event["data"]);
	}

	// end function
	public function onKeyDown(event:KeyboardEvent):void {
		if (event.keyCode == Keyboard.ENTER) {
			if (stage.focus == _input.textField) {
				sendMessage(null);
			}
		}
	}

	//
	public function sendNotice(msg:String, color:int = 0xffffff):void {
		var pCustom:ParagraphElement = TextFlowTool.buildParagraphElement(msg, color);
		publicOutput.addRichChild(pCustom);
	}

	/**
	 * 发送飞屏
	 * @param event
	 */
	public function sendFlyMessage(event:MouseEvent):void {
		var _str:String = inputTextField.text;
		_str            = _str.replace(/\{\/..\}/g, ""); //表情无法显示 如果包含表情 先过滤掉
		if (_str.length == 0) {
			videoRoom.showAlert("请先在聊天框输入你要飞屏的内容", "飞屏");
			return;
		}
		if (_str.length > 60) {
			videoRoom.showAlert("飞屏的内容长度不能大于60个汉字", "飞屏");
			return;
		}
		_str = SensitiveWordFilter.validAndReplaceSensitiveWord(_str);
		if (SensitiveWordFilter.canSend == false) {
			videoRoom.showAlert("您发送的内容包含敏感字符，请仔细检查！", "飞屏");
			return;
		}
		videoRoom.showAlert("确认要花费100钻石发送飞屏吗?", "提示", false, 3, true, callBack);
		function callBack(a:*):void {
			if (a) {
				videoRoom.sendDataObject({"cmd": 30001, "type": 9, "recUid": 0, "content": _str});//发送飞屏a
			}
		}
	}

	public function checkFilterWords(_str:String, rightAway:Boolean = false):Object {
		var new_str:String = SensitiveWordFilter.validAndReplaceSensitiveWord(_str);
		if (SensitiveWordFilter.canSend == false) {
			new_str = "****";
		}
		if (rightAway) {
			return {canSend: SensitiveWordFilter.canSend, data: new_str};
		}
		if (SensitiveWordFilter.canSend == false) {
			//符合1类关键词 不能发送出去
			var timers:String            = NumberUtil.toTimeString(new Date()).substr(0, 5) + "";
			var recObject:UserVo         = new UserVo();
			var sObject:Object           = videoRoom.getDataByName(ModuleNameType.USERDATA);
			sObject.date                 = timers;
			recObject.uid                = sObject.uid;
			recObject.richLv             = sObject.richLv;
			recObject.lv                 = sObject.lv;
			recObject.icon               = sObject.icon;
			recObject.name               = sObject.name;
			recObject.car                = sObject.car;
			//
			var pCustom:ParagraphElement = TextFlowTool.buildParagraphElement("[滤]", 0xffcc00);// new ParagraphElement();
			var _newSpan:SpanElement;
			_newSpan                     = makeSpan(sObject.date + " ", 0xB47BAE);
			pCustom.addChild(_newSpan);
			buildMC(recObject, pCustom);
			_newSpan = makeSpan(": " + new_str, 0xffffff);
			pCustom.addChild(_newSpan);
			if (_input.getType() == 0) {
				publicOutput.addRichChild(pCustom);
			}
			else {
				privateOutput.addRichChild(pCustom);
			}
		}
		return {canSend: SensitiveWordFilter.canSend, data: new_str};
	}

	/**
	 * 发送聊天
	 * @param event
	 */
	public function sendMessage(event:MouseEvent = null):void {
		if (videoRoom.checkState() == PlayerType.GUEST) {
			sendNotice(ERROR_TXT4, 0xffcc00);
			_input.textField.text = "";
			return;
		}
		var message:String  = _input.textField.text;
		//文字长度检查
		var temLegth:String = message.replace(/\{\/..\}/g, "__"); //表情内容占2个字节 以免表情内容占字符过多
		var lenth:int       = temLegth.length;
		//文字长度检查
		if (lenth == 0) {
			sendNotice(ERROR_TXT2, 0xffcc00);
			return;
		}
		//聊天限制检查
		if (videoRoom.checkState() == PlayerType.PLAYER) {
			if (lenth > DataCenterManger.vipInfo.chatlimit) {
				videoRoom.showAlert("您当前的身份，只能输入" + DataCenterManger.vipInfo.chatlimit + "个字符,请努力提高等级吧!", "聊天");
				return;
			}
			if (getTimer() - lastSendTime < DataCenterManger.vipInfo.chatsecond * 1000) {
				var needTime:int = (DataCenterManger.vipInfo.chatsecond * 1000 - (getTimer() - lastSendTime)) * 0.001;
				videoRoom.showAlert("您当前的身份，只能" + DataCenterManger.vipInfo.chatsecond + "秒发送一次,剩余" + needTime + "秒.", "聊天");
				return;
			}
		}
		//过滤字检查
		var mObject:Object = checkFilterWords(inputTextField.text);
		var mString:String = mObject.data;
		if (mObject.canSend == false) {
			_input.textField.text = "";
			return;
		}
		//满足条件开始运行冷确
		if (videoRoom) {
			videoRoom.sendDataObject({
				"cmd":     30001,
				"type":    _input.getType(),
				"recUid":  _input.getUID(),
				"content": mString
			});
			lastSendTime = getTimer();
		}
		_input.textField.text = "";
	}

	public function setHeight(_h:Number):void {
		_height = _h;
		_input.y  = _height - _input.height-30;
		privateOutput.y = _input.y - privateOutput.height-10;
		publicOutput.setHeight(_height-260 -giftOutput.height);
//		publicOutput.graphics.beginFill(0xFFFF00,1);
//		publicOutput.graphics.drawRect(0,0,publicOutput.width,publicOutput.height);
//		publicOutput.graphics.endFill();

//		publicOutput.graphics.beginFill(0xFF00FF,1);
//		publicOutput.graphics.drawRect(0,0,publicOutput.width,publicOutput.height);
//		publicOutput.graphics.endFill();
		trace("_input.y=="+_input.y +"---------privateOutput.y="+privateOutput.y +"--publicOutput.height=="+publicOutput.height);
	}



	public function set videoRoom(src:IVideoRoom):void {
		_videoRoom = src
	}

	public function get videoRoom():IVideoRoom {
		return _videoRoom;
	}

	public function onNameClickHandle(data:UserVo):void {
		var _userVo:UserVo      = data;//p.data as UserVo;
		var event:CBModuleEvent = new CBModuleEvent(CBModuleEvent.PLAYNAMELINK, true);
		event.dataObject        = _userVo;
		dispatchEvent(event);
	}

	//当点击httplink
	public function onHttpClickHandle(httpLink:String):void {
		HttpLinkManger.gotoCommonLinkOther(httpLink);
	}

	public function onChatSystemMessage(src:Object):void {
		var smessage:String = src.message;
		var pCustom:ParagraphElement;
		if(smessage.indexOf("@")==-1)
		{
			pCustom = TextFlowTool.buildParagraphElement(src.message, src.color);
			privateOutput.addRichChild(pCustom);
		}
		else
		{
			var tempStrList:Array = smessage.split("@");
			pCustom = new ParagraphElement();
			privateOutput.addRichChild(pCustom);
			var pSpan:FlowElement;
			for(var i:int=0;i<tempStrList.length;i++)
			{
				var temStr:String =tempStrList[i] as String;
				if(temStr.indexOf("/>")==-1)
				{
					pSpan = TextFlowTool.buildSpanElement(temStr,src.color);
					pCustom.addChild(pSpan);
				}
				else
				{
					try
					{
						var linkXml:XML = new XML(temStr);
						//  trace(data.@text+"-------------link:=="+data.@link);
						pSpan = TextFlowTool.buildSpanElement(linkXml.@text,0xFF00CC,onHttpClickHandle,linkXml.@link);
						pCustom.addChild(pSpan);
					}
					catch (e:*)
					{
						trace("link error");
					}

				}
			}
		}

	}

	public function onPeopleEnter(sObject:Object):void {
		var recObject:UserVo = new UserVo();
		recObject.uid        = sObject.uid;
		recObject.richLv     = sObject.richLv;
		recObject.lv         = sObject.lv;
		recObject.icon       = sObject.icon;
		recObject.name       = sObject.name;
		recObject.car        = sObject.car;
		recObject.hidden     = sObject.hidden;
		var vColor:uint      = 0xEA00EA;//有道具人颜色
		var cColor:uint      = 0xff5400;//没有道具人颜色
		var isAnchor:Boolean = recObject.uid == videoRoom.getDataByName(ModuleNameType.USERROOMDATA).roomid;
		if (!isAnchor && recObject.richLv <= 2) //如果一富以下 且不是主播，不显示欢迎
		{
			return;
		}
		var pCustom:ParagraphElement = TextFlowTool.buildParagraphElement();
		var giftS:SpanElement;
		var giftIcon:InlineGraphicElement;
		if (recObject.hidden == 1) {
			giftS = makeSpan("全体请注意！有一个神秘人悄悄进入房间了！", vColor);
			pCustom.addChild(giftS);
			publicOutput.addRichChild(pCustom);
			return;
		}
		if (recObject.car > 0) {
			giftS = makeSpan("欢迎『", vColor);
			pCustom.addChild(giftS);
			buildMC(recObject, pCustom, false);
			giftS = makeSpan("』开着他的座驾 ", vColor);
			pCustom.addChild(giftS);
			giftIcon               = buildImageIcon(videoRoom.getDataByName(ModuleNameType.HTTPROOT) + "image/gift_material/" + recObject.car + ".png");
			giftIcon.paddingBottom = -6;
			giftIcon.width         = 24;
			giftIcon.height        = 24;
			pCustom.addChild(giftIcon);
			giftS = makeSpan(" 进入房间", vColor);
			pCustom.addChild(giftS);
		} else {
			giftS = makeSpan("欢迎『", cColor);
			pCustom.addChild(giftS);
			buildMC(recObject, pCustom, false);
			giftS = makeSpan("』进入直播间", cColor);
			pCustom.addChild(giftS);
		}
		publicOutput.addRichChild(pCustom)
	}

	/**
	 * 加入数组
	 * @param sObject
	 */
	public function onGiftChat(sObject:Object):void {
		if (DataCenterManger.getInstance().isRoomAdmin) {
			sObject.sendCount = sObject.gnum;
			onPlayGiftInfor(sObject);
		} else {
			sObject.sendCount = 0;
			giftObjectArray.push(sObject)
		}
	}

	/**
	 * 时间管理函数
	 */
	public function onTickHandle(e:TickEvent = null):void {
		if (getTimer() - lastGiftSendTime < 300) {
			return;
		}
		var rNum:int       = Math.random() * giftObjectArray.length;
		var sObject:Object = giftObjectArray[rNum];
		if (sObject) {
			if (sObject.gnum <= 0) {
				giftObjectArray.splice(rNum, 1);
				return;
			}
			var num:int = sObject.gnum < 5 ? sObject.gnum : 5;
			sObject.gnum -= num;
			sObject.sendCount += num;
			onPlayGiftInfor(sObject);
			lastGiftSendTime = getTimer();
		}
	}

	/**
	 * 加入礼物文本框
	 * @param sObject
	 */
	public function onPlayGiftInfor(sObject:Object):void {
		var recObject:UserVo = new UserVo();
		recObject.init(sObject.recUid, sObject.recName, sObject.recRichLv, sObject.recLv, sObject.recIcon);
		recObject.hidden  = sObject.recHidden;
		//
		var sender:UserVo = new UserVo();
		sender.init(sObject.sendUid, sObject.sendName, sObject.richLv, sObject.lv, sObject.icon);
		sender.hidden                = sObject.sendHidden;
		//
		var pCustom:ParagraphElement = TextFlowTool.buildParagraphElement();
		var giftS:SpanElement        = makeSpan("[礼物]", 0xf955ff);
		pCustom.addChild(giftS);
		buildMC(sender, pCustom);
		giftS = makeSpan(" 赠送给 ", 0xFF33CC);
		pCustom.addChild(giftS);
		buildMC(recObject, pCustom);
		var giftIcon:InlineGraphicElement = buildImageIcon(videoRoom.getDataByName(ModuleNameType.HTTPROOT) + "image/gift_material/" + sObject.gid + ".png", 24, 24);
		pCustom.addChild(giftIcon);
		giftS = makeSpan(sObject.sendCount + "个", 0xFF33CC);
		pCustom.addChild(giftS);
		//进入
		giftOutput.addRichChild(pCustom);
	}

	/**
	 * 生成一个可以点击的 人物名字 出来
	 * @param user
	 * @param contion
	 * @param isUseOwerWord
	 */
	private function buildMC(user:UserVo, contion:ParagraphElement, isUseOwerWord:Boolean = true):void {
		var isSelf:Boolean   = videoRoom.getDataByName(ModuleNameType.USERDATA).uid == user.uid;//
		var isAnchor:Boolean = user.uid == DataCenterManger.roomData.roomid;
		if (isUseOwerWord) {
			var _name:String = (isSelf ? "我" : FormatDataTool.getNickeName(user));
		} else {
			_name = FormatDataTool.getNickeName(user);
		}
		if (user.hidden != 1) {
			buildUserNameIcon(user, contion, isAnchor);
		}
		var linkMC:LinkElement     = TextFlowTool.buildLinkElement(_name, 0xFF77A7, onNameClickHandle, user) as LinkElement;
		var _spaceWord:SpanElement = TextFlowTool.buildSpanElement(" ", 0xFF33CC) as SpanElement;
		contion.addChild(_spaceWord);
		contion.addChild(linkMC);
	}

	public var pattern:RegExp = /[a-zA-z]+:\/\/[^\s]*/;

	/**
	 * 收到聊天信息
	 * @param sObject
	 * @param type
	 */
	public function onPublicChat(sObject:Object, type:int):void {
		//var color:String = type == 1 ? "#FF77A7" : "#e0ae97";
		switch (type) {
			case 1://用户收到公聊聊天信息
			case 2://用户收到私聊聊天信息
			{
				if (pattern.test(sObject.content)) {
					sendNotice("聊天窗不允许出现非法网址!");
					return;
				}
				//
				sObject.content              = checkFilterWords(sObject.content, true).data;
				//
				var pCustom:ParagraphElement = TextFlowTool.buildParagraphElement(sObject.date + " ", 0xB47BAE);// new ParagraphElement();
				var _newSpan:SpanElement;// =  makeSpan(sObject.date + " ", 0xB47BAE);
				var newObject:UserVo         = new UserVo();
				newObject.hidden             = sObject.sendHidden;
				newObject.ruled              = sObject.ruled;
				newObject.init(sObject.sendUid, sObject.sendName, sObject.richLv, sObject.lv, sObject.icon);
				var getObject:UserVo = new UserVo();
				getObject.hidden     = sObject.recHidden;
				getObject.ruled      = sObject.recRuled;
				getObject.init(sObject.recUid, sObject.recName, sObject.recRichLv, sObject.recLv, sObject.recIcon);
				buildMC(newObject, pCustom);
				if (getObject.uid > 0) {
					_newSpan = makeSpan(" 对 ", 0xFFFFFF);
					pCustom.addChild(_newSpan);
					buildMC(getObject, pCustom);
				}
				_newSpan = makeSpan(" : ", 0xFFFFFF);
				pCustom.addChild(_newSpan);
				var _textColor:Number = VIPColor[sObject.vip] == null ? 0xffffff : VIPColor[sObject.vip];
				//消息内容与 表情处理
				TextFlowTool.formartMessgaeWords(sObject.content, pCustom, _textColor);
				//进入
				if (type == 1) {
					publicOutput.addRichChild(pCustom);
				} else {
					privateOutput.addRichChild(pCustom);
				}
			}
				break;
			case 6: //个性化通知\
				paraCustomMessage(sObject, publicOutput);
				break;
			case 10://贵族vip到期通知
				paraCustomMessage(sObject, privateOutput);
				break;
		}
	}

	//自定义消息格式处理
	private function paraCustomMessage(sObject, contain:RichText, deaultColor = 0xFFFFFF):void {
		var message:String           = sObject.content;
		var msgArr:Array             = message.split("||");
		var pCustom:ParagraphElement = TextFlowTool.buildParagraphElement(sObject.date + " ", 0xB47BAE);// new ParagraphElement();
		var _newSpan:SpanElement;
		var tempMsg:String           = "";
		var linkMC:LinkElement;
		var usr:UserVo;
		var sendVo:UserVo            = new UserVo();
		sendVo.init(sObject.sendUid, sObject.sendName, sObject.richLv, sObject.lv, sObject.icon);
		for (var i:int = 0; i < msgArr.length; i++) {
			switch (msgArr[i]) {
				case "@sendUid":
					var _spaceWord:SpanElement = TextFlowTool.buildSpanElement(" ", 0xFF33CC) as SpanElement;
					pCustom.addChild(_spaceWord);
					linkMC = TextFlowTool.buildLinkElement(sendVo.name, 0xFF77A7, onNameClickHandle, sendVo) as LinkElement;  // makeLink(_name, "#FF77A7", user, onNameClickHandle);
					pCustom.addChild(linkMC);
					break;
				case "@icon"://显示主播vip等级
					var isAnchor:Boolean = sendVo.uid == videoRoom.getDataByName(ModuleNameType.USERROOMDATA).roomid;
					buildUserNameIcon(sendVo, pCustom, true);
					break;
				case "@recIcon"://显示用户财富等级
					buildUserNameIcon(sendVo, pCustom, false);
					break;
				case "@link"://特殊链接
					var dataArray:Array = sObject.recName.split(",");
					if (dataArray && dataArray.length > 0)
						pCustom.addChild(TextFlowTool.buildLinkElement(dataArray[0], 0xFF77A7, onLinkHandle, dataArray[1]));
					break;
				default:
					_newSpan = makeSpan(msgArr[i].toString(), deaultColor);
					pCustom.addChild(_newSpan);
					break;
			}
		}
		contain.addRichChild(pCustom);
	}

	//联通
	private function onLinkHandle(eventStr:String):void {
		if (eventStr != null && eventStr != "") {
			switch (eventStr) {
				case CBModuleEvent.PLAYNAMELINK:
					this.dispatchEvent(new CBModuleEvent(eventStr, true));
					//Cc.log("用户财富等级link--" + eventStr);
					break;
				case "chongzhi":
					ClientManger.getInstance().userPay();
					break;
				case CBModuleEvent.CHATLINK_GAMRE1:
					ClientManger.getInstance().showCarGame();
					break;
				case CBModuleEvent.CHATLINK_GAMRE2:
					ClientManger.getInstance().showFingerGame();
					break;
			}
		}
	}

	/**
	 * 建立带颜色的字段
	 * @param src
	 * @param color
	 * @return
	 */
	public function makeSpan(src:String, color:int):SpanElement {
		var s:SpanElement = TextFlowTool.buildSpanElement(src, color) as SpanElement;
		return s;
	}

	/**
	 * 建立带 称号 主播等级 用户等级图标的
	 * @param _userVo
	 * @param _c
	 * @param isAnchor
	 */
	public function buildUserNameIcon(_userVo:UserVo, _c:ParagraphElement, isAnchor:Boolean):void {
		if (_userVo.icon > 0) {
			//如果有魅力之星的话
			var _newinlineGraphic:InlineGraphicElement = TextFlowTool.buildInlineGraphicElement(videoRoom.getDataByName(ModuleNameType.HTTPROOT) + "image/signal_icon/" + _userVo.icon + ".png");
			_c.addChild(_newinlineGraphic);
		}
		var imgUrl:String = "";
		if (isAnchor) {
			//是主播的情况
			if (_userVo.lv > 19) {
				_userVo.lv = 15;
			}
			var iconLv:int = _userVo.lv <= 19 ? _userVo.lv : 19;
			imgUrl         = videoRoom.getDataByName(ModuleNameType.HTTPROOT) + "image/lv_icon/r" + iconLv + ".png";
		} else if (_userVo.richLv > 1) {
			//不是当前主播的情况
			imgUrl = videoRoom.getDataByName(ModuleNameType.HTTPROOT) + "image/rlv_icon/" + _userVo.richLv + ".png";
		}
		var inlineGraphic:InlineGraphicElement = TextFlowTool.buildInlineGraphicElement(imgUrl); // new InlineGraphicElement();
		inlineGraphic.paddingBottom            = -4;
		_c.addChild(inlineGraphic);
	}

	public function buildImageIcon(url:String, _width:Number = 0, _height:Number = 0):InlineGraphicElement {
		var inlineGraphic:InlineGraphicElement = TextFlowTool.buildInlineGraphicElement(url);
		if (_width != 0) {
			inlineGraphic.width = _width;
		}
		if (_height != 0) {
			inlineGraphic.height = _height;
		}
		return inlineGraphic;
	}

	public function get inputTextField():TextField {
		return _input.textField;
	}

	public function addItem(obj:Object):void {
		_input.addItem(obj);
	}

	public function listNotificationInterests():Array {
		return [];
	}

	public function handleNotification(src:Object):void {
		switch (src.cmd) {
			case CBProtocol.richGift_40003:
				break;
		}
	}

	/**
	 * 收到礼物连击效果
	 * @param sObject
	 */
	public function onComboGiftChat(sObject:Object):void {
		var imageUrl:String   = VideoConfig.HTTP + "image/gift_material/" + sObject.gid + ".png";
		var skinMc:ComboxPane = new ComboxPane();
		if (sObject.sendHidden == 1) {
			sObject.sendName = "神秘人";
		}
		var fText:String             = HTMLUtil.applyColor(sObject.sendName, 0xFFFF00) + HTMLUtil.applyColor("送", 0xFFFFFF);
		var sText:String             = HTMLUtil.applyColor("      ", 0xFFFF00) + HTMLUtil.applyColor(sObject.gnum, 0xFFFF00) + HTMLUtil.applyColor("个.", 0xFFFFFF);
		skinMc.view.nameTxt.htmlText = fText;
		skinMc.view.nameTxt.autoSize = TextFieldAutoSize.LEFT;
		skinMc.view.nameTxt.wordWrap = false;
		skinMc.giftMc.x              = skinMc.view.nameTxt.width + skinMc.view.nameTxt.x;
		skinMc.view.nameTxt.htmlText = fText + sText;
		skinMc.view.doubleTxt.text   = "x" + sObject.times;
		skinMc.loaderImageIcon(imageUrl);
		addChild(skinMc);

	}
}
}

