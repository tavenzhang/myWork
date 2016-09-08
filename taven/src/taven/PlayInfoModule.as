package taven {
import com.adobe.utils.StringUtil;
import com.bit101.components.VBox;
import com.junkbyte.console.Cc;
import com.rover022.CBProtocol;
import com.rover022.ModuleNameType;
import com.rover022.event.CBModuleEvent;
import com.rover022.vo.VideoConfig;

import display.BaseModule;
import display.RslModuleManager;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;

import manger.ClientManger;
import manger.NavigatorManager;
import manger.DataCenterManger;


import taven.enum.EventConst;
import taven.enum.EventUtils;
import taven.playerInfo.PlayerListView;
import taven.playerInfo.RankStartView;
import taven.playerInfo.VideoHomeView;
import taven.utils.HeadIconBuildTool;
import taven.utils.MathUtils;
import taven.utils.StringUtils;
import taven.utils.TweenHelp;

import tool.VideoTool;

public class PlayInfoModule extends BaseModule {
	private var _view:taven_PlayerInfoView;
	//private var _playListView:PlayerListView;
	private var _videoHomeView:VideoHomeView;
	private var _starView:RankStartView;
	/*--------------------------外部接口------------------*/
	private var _headUrl:String;
	private var _userList:Array;
	private var _videoList:Array;
	private var _curHeight:Number;
	private var _maxHeigh:Number = 0;
	public var headFormat:String;
	public var selectItem:Object;
	private var _data:Object;
	public var peopleInfo:Object;
	public var headMc:MovieClip;
	public var gameBox:Sprite    = new Sprite();
	public var view_cj:taven_viewCJ;

	override protected function initView():void {
		_view          = new taven_PlayerInfoView();
		_maxHeigh      = _view.mcBg.height;
		_videoHomeView = new VideoHomeView(_view.mcHome, this);
		this.addChild(_view);
		_view.mcMail.visible     = false;
		_view.bgBtnStart.visible = false;
		_view.mcSelectBg.visible = false;
		initListeners();
		_view.btnSound.visible = false; //点击声音广播
		_view.btnGet.visible   = false;//点击领取
		_view.mcFace.visible   = false;
		_view.mcMail.gotoAndStop(2);
		_view.mcActive.visible = _view.mcAcviteHouse.visible = false;
		headMc = HeadIconBuildTool.makerUserHead(17, 34);
		_view.addChild(headMc);
		headMc.visible = false;
		headMc.addEventListener(MouseEvent.CLICK, headMcClick);
		_view.mcMail.txtPrivate.text = "";
		_view.mcMail.txtSystem.text  = "";
		_view.btnGet.addEventListener(MouseEvent.CLICK, onButtonClickHandle);
		_view.btnDown.addEventListener(MouseEvent.CLICK, onButtonClickHandle);
		_view.mcJuBao.addEventListener(MouseEvent.CLICK, onButtonClickHandle);
		_view.mcCaiQuan.addEventListener(MouseEvent.CLICK, onButtonClickHandle);
		_view.mcCaiQuan.visible = false;
		_view.btnDown.visible = false;
		VideoTool.buildButtonEff(_view.btnDown);
		VideoTool.buildButtonEff(_view.btnGet);
		VideoTool.buildButtonEff(_view.mcJuBao);
		VideoTool.buildButtonEff(_view.mcCaiQuan);
		gameBox = new VBox(_view, 0, 0);
		gameBox.addChild(_view.mcJuBao);
		gameBox.addChild(_view.mcCaiQuan);
		_view.mcInfo.visible =false;
		initNewBtn();
	}


	private function  initNewBtn():void{
		_view.mcBtnIndex.txtBtnName.text = "首页";
		_view.mcBtnRank.txtBtnName.text="排行";
		_view.mcBtnHome.txtBtnName.text="大厅";
		_view.mcBtnShop.txtBtnName.text="商城";
		_view.mcBtnFuni.txtBtnName.text="福利";
		_view.mcBtnCJ.txtBtnName.text="抽奖";
		_view.mcBtnMsg.txtBtnName.text="消息";
		initListnerBtn(_view.mcBtnIndex);
		initListnerBtn(_view.mcBtnRank);
		_view.mcBtnRank.btnView.gotoAndStop(2);
		initListnerBtn(_view.mcBtnHome);
		_view.mcBtnHome.btnView.gotoAndStop(3);
		initListnerBtn(_view.mcBtnShop);
		_view.mcBtnShop.btnView.gotoAndStop(4);
		initListnerBtn(_view.mcBtnFuni);
		_view.mcBtnFuni.btnView.gotoAndStop(5);
		_view.mcBtnFuni.visible=false;
		initListnerBtn(_view.mcBtnCJ);
		_view.mcBtnCJ.btnView.gotoAndStop(6);
		_view.mcBtnCJ.visible=false;
		initListnerBtn(_view.mcBtnMsg);
		_view.mcBtnMsg.btnView.gotoAndStop(7);
	}


	private  function initListnerBtn(mc:MovieClip):void{
		mc.buttonMode = true;
		mc.mouseChildren=false;
		mc.addEventListener(MouseEvent.ROLL_OVER, function (evt:Event) {
			var target:MovieClip = evt.currentTarget as MovieClip;
			target.gotoAndStop(2);
		});
		mc.addEventListener(MouseEvent.ROLL_OUT, function (evt:Event) {
			var target:MovieClip = evt.currentTarget as MovieClip;
			target.gotoAndStop(1);
		});
		mc.addEventListener(MouseEvent.CLICK,onNewBtnClick);
		headMc.addEventListener(MouseEvent.ROLL_OVER,onRollOverHandle);
		headMc.addEventListener(MouseEvent.ROLL_OUT,onRollOverHandle);
	}

	private function onRollOverHandle(evt:Event):void
	{
		if(evt.type == MouseEvent.ROLL_OVER)
		{
			_view.mcInfo.visible = true;
		}
		else
		{
			_view.mcInfo.visible = false;
		}
	}


	private  function  onNewBtnClick(evt:Event):void
	{
		trace("onNewBtnClick ---"+evt.currentTarget.name);
		var videoVisible:Boolean = _view.mcHome.visible;
		var mailVisilbe:Boolean  = _view.mcMail.visible;
		switch (evt.currentTarget)
		{
			case _view.mcBtnIndex: //首页
				NavigatorManager.gotoIndex();
				break;
			case _view.mcBtnRank://排行
				NavigatorManager.gotoRank();
				break;
			case _view.mcBtnHome://大厅
				_view.mcHome.visible = !videoVisible;
				if (_view.mcHome.visible) {
					TweenHelp.fade(_view.mcHome, 0.3, 0.2, 1);
				}
				EventUtils.secndStatusEvent(this, EventConst.PLAYER_HOME);
				break;
			case _view.mcBtnShop://商城
				NavigatorManager.gotoShop();
				break;
			case _view.mcBtnFuni://福利
				break;
			case _view.mcBtnCJ://抽奖
				//ClientManger.getInstance().showCarGame();
					if(!view_cj)
					{
						view_cj = new taven_viewCJ();
						view_cj.x=82;
						view_cj.y=502;
						view_cj.txtNum.maxChars=2;
						view_cj.txtNum.restrict="0-9";
						view_cj.txtDesc.text="";

						_view.addChild(view_cj);
						view_cj.btnClose.addEventListener(MouseEvent.CLICK, function (e:*) {
							view_cj.visible=false;
						});
						view_cj.btnCj.addEventListener(MouseEvent.CLICK,onStarCJClick);
						view_cj.visible=false;
					}
				 view_cj.visible = !view_cj.visible;
					if(view_cj.visible)
					{
						TweenHelp.fade(_view.mcMail, 0.3, 0.2, 1);
					}

				break;
            case _view.mcBtnMsg://消息
				//ClientManger.getInstance().getMsgKeyFromWeb(VideoConfig.testUID, VideoConfig.testPASS, ClientManger.getInstance().view["AirConnectService"]);
				if (!mailVisilbe) {
					_view.mcMail.visible = true;
					changeSelcedBtn(_view.btnMail);
					TweenHelp.fade(_view.mcMail, 0.3, 0.2, 1);
					_view.mcMail.txtPrivate.text = "";
					_view.mcMail.txtSystem.text  = "";
					view_cj.txtTitle.text="";
					if (_view.mcMail.btnPrivate)
						_view.mcMail.btnPrivate.mouseEnabled = false;
					EventUtils.secndNetData(this.videoRoom, CBProtocol.msg_notice_50006, {}, s2cNoticeData);
				}
				else {
					_view.mcMail.visible = false;
				}
				break;
		}
	}
	private function onStarCJClick(evt:Event){
		EventUtils.secndNetDataNew(CBProtocol.activeCj_62001,{"title":view_cj.txtTitle.text,"num":view_cj.txtNum.text,"detail":view_cj.txtDesc.text,"cmd":CBProtocol.activeCj_62001});
		view_cj.visible=false;
	}

	override protected function onAddToStageHandle(event:Event):void {
		trace(stage);
		stage.addEventListener(CBModuleEvent.SHOW_CAR_GAME, function (e:Event):void {
			trace(stage);
			_view.mcJuBao.dispatchEvent(new MouseEvent(MouseEvent.CLICK))
		});
		stage.addEventListener(CBModuleEvent.SHOW_FINGER_GAME, function (e:Event):void {
			trace(stage);
			_view.mcCaiQuan.dispatchEvent(new MouseEvent(MouseEvent.CLICK))

		});
	}



	public function onButtonClickHandle(e:MouseEvent):void {
		switch (e.currentTarget.name) {
			case "btnDown":
				navigateToURL(new URLRequest(VideoConfig.httpFunction + DataCenterManger.userData.downloadUrl));
				break;
			case "btnGet":
				var panel:Sprite = videoRoom.getModule("SignActivityPanel") as Sprite;
				if (panel) {
					if (panel.parent == null) {
						stage.addChild(panel);
					} else {
						panel.parent.removeChild(panel)
					}
				}
				break;
			case "mcJuBao":
				ClientManger.getInstance().showCarGame();
				//EventUtils.secndStatusEvent(this, EventConst.PLAYER_JU_BIAO);
				break;
			case "mcCaiQuan":
				ClientManger.getInstance().showFingerGame();
				break;
			default :
		}
	}

	public function headMcClick(e:MouseEvent):void {
		EventUtils.secndStatusEvent(this, EventConst.PLAYER_HEAD_CLICK);
	}

	override protected function initListeners():void {
		_view.addEventListener(MouseEvent.CLICK, onViewClick);
	}

	private function onViewClick(evt:MouseEvent):void {
		if (evt.target is SimpleButton) {
			_view.mcSelectBg.visible = false;
			//var listVisible:Boolean  = _view.mcPlayList.visible;
			var videoVisible:Boolean = _view.mcHome.visible;
			var mailVisilbe:Boolean  = _view.mcMail.visible;
			if (evt.target == _view.btnHome || evt.target == _view.btnMail || evt.target == _view.mcPerson) //这三个子ui 不要同时存在
			{
				_view.mcHome.visible = _view.mcMail.visible = false;
			}
			switch (evt.target) {
				case _view.btnChonZhi: //点击充值
					EventUtils.secndStatusEvent(this, EventConst.PLAYER_CHONZHI);
					break;
				case _view.btnHome: //点击大厅
					_view.mcHome.visible = !videoVisible;
					if (_view.mcHome.visible) {
						TweenHelp.fade(_view.mcHome, 0.3, 0.2, 1);
					}
					EventUtils.secndStatusEvent(this, EventConst.PLAYER_HOME);
					break;
				case _view.btnShop: //点击商场
					EventUtils.secndStatusEvent(this, EventConst.PLAYER_SHOP);
					break;
				case _view.btnMail: //点击邮件
					if (!mailVisilbe) {
						_view.mcMail.visible = true;
						changeSelcedBtn(_view.btnMail);
						TweenHelp.fade(_view.mcMail, 0.3, 0.2, 1);
						_view.mcMail.txtPrivate.text = "";
						_view.mcMail.txtSystem.text  = "";
						if (_view.mcMail.btnPrivate)
							_view.mcMail.btnPrivate.mouseEnabled = false;
						EventUtils.secndNetData(this.videoRoom, CBProtocol.msg_notice_50006, {}, s2cNoticeData);
					}
					else {
						_view.mcMail.visible = false;
					}
					break;
				case _view.mcPerson: //
					//changeSelcedBtn(_view.mcPerson);
					break;
				case _view.btnSound: //点击声音广播
					EventUtils.secndStatusEvent(this, EventConst.PLAYER_BROADCAST);
					break;
				case _view.mcMail.btnPrivate: //产看私信
					//  EventUtils.secndStatusEvent(this, EventConst.PLAYER_PRIVATE_MAIL);
					break;
				case _view.mcMail.btnSystem: //产看系统信息
					EventUtils.secndStatusEvent(this, EventConst.PLAYER_SYSTEM_MAIL);
					break;
				case _view.btnLogin: //登录
					EventUtils.secndStatusEvent(this, EventConst.PLAYER_LOGIN);
					break;
				case _view.btnRegist: //举报
					EventUtils.secndStatusEvent(this, EventConst.PLAYER_REGIST);
					break;
				case _view.btnServe: //点击客服
					EventUtils.secndStatusEvent(this, EventConst.PLAYER_SERVER);
					break;
				case  _view.mcActive.btnStar: //点击魅力之星
					starView.visible = !starView.visible;
					if (starView.visible) {
						TweenHelp.fade(starView, 0.3, 0.2, 1);
					}
			}
		}
	}

	private function s2cNoticeData(data:Object):void {
		if (data) {
			_view.mcMail.txtPrivate.visible = false;
			_view.mcMail.txtSystem.visible  = true;
			_view.mcMail.txtSystem.text     = "(" + data.news + ")";
			_view.mcMail.txtSystem.visible  = _view.mcMail.currentFrame == 1;
			var news:int                    = data.news + data.letter;
			_view.txtmcmc.visible           = news > 0 ? true : false;
		}
	}

	private function changeSelcedBtn(btn:DisplayObject):void {
		if (btn) {
			_view.mcSelectBg.x       = btn.x - _view.mcSelectBg.width / 4;
			_view.mcSelectBg.y       = btn.y - _view.mcSelectBg.height / 4;
			_view.mcSelectBg.visible = false;
		}
		else {
			_view.mcSelectBg.visible = false;
		}
	}

	/**--------------------------------------------------------------------------公共接口-----------------------------------------------------------------------------------------------------------*/
	/**用户头像的完整url 链接*/
	public function get headUrl():String {
		return _headUrl;
	}

	public function set headUrl(value:String):void {
		if (value != "") {
			_headUrl = value;
			HeadIconBuildTool.loaderUserHead(value, headMc);
		}
	}

	/**设置用户 列表的数据*/
	public function updateUserData(onfo:*, dataArr:Array, isDelete:Boolean = false):void {
		if (onfo != null)
			peopleInfo = onfo;
		updateData(dataArr, _userList, isDelete, true)
	}

	override public function get height():Number {
		return _curHeight;
	}

	override public function set height(value:Number):void {
		value = MathUtils.clamp(value, 600, _maxHeigh);
		if (_curHeight != value) {
			_view.mcBg.height = value;
		//	_playListView.updateMaxHeight(value);
			gameBox.y      = value - 80;
			//_view.mcJuBao.y = value - _view.mcJuBao.height - 30;
			_view.mcHome.y = (value - _view.mcHome.height) / 2
		}
		_curHeight = value;
	}

	/**设置主播数据
	 *  data =【{headUrl:"http://192.168.10.230:8088/gift/gift_icon/100001.png",time:"12:20,name:"走着瞧是错",people:23,type:1}】
	 * */
	public function updateVideoData(dataArr:Array, isDelete:Boolean = false):void {
		updateData(dataArr, _videoList, isDelete, false);
	}

	/**更新用户人数接口*/
	public function updateVideoInfos(data:Array):void {
		_videoHomeView.updateVideoInfos(data);
	}

	/**通过id 获取用户数据*/
	public function getDataByUid(uid:uint):Object {
		var reautlData:Object;
		var dataArr:Array = [];
		if (_userList) {
			dataArr = dataArr.concat(_userList);
		}
		for each(var item:Object in _userList) {
			if (item && (item.uid == uid)) {
				reautlData = item;
				break;
			}
		}
		return reautlData;
	}

	private function updateData(changeArr:Array, srcArr:Array, isDelete:Boolean = false, isUserList:Boolean = false):void {
		if (isUserList) {
			updateUserView(changeArr, srcArr, isDelete);
		}
		else {
			updateVieoHomeView(changeArr, srcArr, isDelete);
		}
	}

	/**更新用户列表显示*/
	private function updateUserView(changeArr:Array, srcArr:Array, isDelete:Boolean = false):void {
		var isChange:Boolean = false;
		changeArr            = changeArr == null ? [] : changeArr;
		if (isDelete) {
			if (srcArr && srcArr.length > 0) {
				for (var i:int = 0; i < changeArr.length; i++) {
					for each(var item:Object in srcArr) {
						if (item.uid == changeArr[i].uid) {
							srcArr.splice(_userList.indexOf(item), 1);
							isChange = true;
							break;
						}
					}
				}
			}
		}
		else {
			if (srcArr == null) {
				srcArr   = changeArr;
				isChange = true;
			}
			else {
				var isNew:Boolean = true;
				for (i = 0; i < changeArr.length; i++) {
					isNew = true;
					for each (var item2:Object in srcArr) {
						if (item2.uid == changeArr[i].uid) {
							isNew                         = false;
							srcArr[srcArr.indexOf(item2)] = changeArr[i];
							isChange                      = true;
							break;
						}
					}
					if (isNew) {
						srcArr.push(changeArr[i]);
						isChange = true;
					}
				}
			}
		}
		if (isChange || (peopleInfo && peopleInfo.flushPerson)) {
			_userList = srcArr;
		//	_playListView.updateView(srcArr);
		}
	}

	/**更新大厅显示*/
	private function updateVieoHomeView(changeArr:Array, srcArr:Array, isDelete:Boolean = false):void {
		changeArr  = changeArr == null ? [] : changeArr;
		_videoList = changeArr;
		_videoHomeView.updataListView(_videoList);
	}

	/**人物角色信息*/
	public function get data():Object {
		return _data;
	}

//延迟初始化
	private function get starView():RankStartView {
		if (!_starView) {
			_starView   = new RankStartView(this, _view.bgBtnStart);
			_starView.x = 80;
			_starView.y = 120;
			addChildAt(_starView, 0);
		}
		return _starView;
	}

	/**
	 * @private
	 */
	public function set data(value:Object):void {
		Cc.log("play data===="+data);
		_data = value;
		if (_data) {
			if (_data.headUrl != null) {
				headUrl = _data.headUrl;
			}
			_view.btnRegist.visible = _view.btnLogin.visible = false;
			headMc.visible = true;
			_view.mcMail.gotoAndStop(1);
			_view.mcInfo.txtName.text=_data.name;
			_view.mcInfo.txtDetail.text=StringUtils.strStitute("等级: {0}级 \n钻石: {1}个",_data.richLv,_data.points);
			trace("_view.mcInfo.txtDetail.text="+_view.mcInfo.txtDetail.text)
		}
		else {
			headMc.visible          = false;
			_view.btnRegist.visible = _view.btnLogin.visible = true;
			_view.mcMail.gotoAndStop(2);
		}
	}

	public function showActiveBtns(activeList:Array):void {
		//每次进入获取一下消息数

		EventUtils.secndNetData(this.videoRoom, CBProtocol.msg_notice_50006, {}, s2cNoticeData);
		for each(var item:Object in activeList) {
			if (item) {
				switch (item.activityType) {
					case 1:  //1表示礼物之星传统活动
						_view.mcActive.visible            = true;
						_view.mcActive.txtActicve.text         = item.activityName;
						_view.mcActive.txtActicve.mouseEnabled = false;
						_view.mcActive.btnStar.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
						break;
					case 2:// 金屋藏娇
						view.mcAcviteHouse.visible                 = true;
						view.mcAcviteHouse.txtActicve.text         = item.activityName;
						view.mcAcviteHouse.txtActicve.mouseEnabled = false;
						view.mcAcviteHouse.btnStar.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
						break;
					case 3:// 魔兽争霸:
						view.mcAcviteHouse.visible                 = true;
						view.mcAcviteHouse.txtActicve.text         = item.activityName;
						view.mcAcviteHouse.txtActicve.mouseEnabled = false;
						view.mcAcviteHouse.addEventListener(MouseEvent.CLICK, function (evt:Event):void {
							RslModuleManager.instance.toggleModule(ModuleNameType.ActiveMsFight);
						});
						view.mcAcviteHouse.btnStar.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
						break;
				}
			}
		}
	}

	public function checkChoujiang(isOpen:Boolean){
		_view.mcBtnCJ.visible=isOpen;
	}

	public function get view():taven_PlayerInfoView {
		return _view;
	}
}
}
