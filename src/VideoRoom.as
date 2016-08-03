/**
 * Created by roger on 2014/11/17.
 */
package {
import com.greensock.loading.LoaderMax;
import com.junkbyte.console.Cc;
import com.kingjoy.handler.RoomEventHandler;
import com.kingjoy.view.BackGroundLay;
import com.kingjoy.view.BaseResRoom;
import com.kingjoy.view.DivisionContainer;
import com.kingjoy.view.GiftPool;
import com.kingjoy.view.LoadUI;
import com.kingjoy.view.control.FlyMessgaeModule;
import com.kingjoy.view.control.ScrollStageControl;
import com.rover022.event.CBModuleEvent;
import com.rover022.IChat;
import com.rover022.IPlayer;
import com.rover022.IVideoRoom;
import com.rover022.ModuleNameType;
import com.rover022.tool.SensitiveWordFilter;
import com.rover022.vo.ChatState;
import com.rover022.vo.PlayerType;
import com.rover022.vo.UserVo;
import com.rover022.vo.VideoConfig;

import control.ControlsManger;

import display.RslModuleManager;
import display.ui.Alert;
import display.ui.SignActivityPanel;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.StatusEvent;
import flash.external.ExternalInterface;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.system.Security;
import flash.utils.setTimeout;

import ghostcat.display.other.GContextMenu;
import ghostcat.manager.RootManager;

import manger.ClientManger;
import manger.ModuleLoaderManger;
import manger.UserVoDataManger;

import net.NetManager;

import tool.FormatDataTool;
import tool.VideoTool;

import videoRoom.bulletin;

[SWF(width=1500, height=900, backgroundColor="#00000")]
public class VideoRoom extends BaseResRoom implements IVideoRoom {
    public var appLay:Sprite;
    public var backGround:Sprite;
    public var rootSpr:Sprite;
    public var adornSpr:Sprite;//装饰
    public var giftSpr:Sprite;
    public var divisionContainer:DivisionContainer;//一个TapPane
    public var logo_Module:MovieClip;
    public var body:Sprite;
    public var backGroundSprite:MovieClip;
    public var rankMenu_Moudle:MovieClip;
    public var roomPlayInfor:MovieClip;
    public var video_Module:IPlayer;
    public var videoUIView:Sprite;
    public var roomWestUIView:Sprite;
    public var roomEastUIView:Sprite;
    public var userInfo_Module:MovieClip;
    public var gift_Module:MovieClip;
    public var rightMenu_Module:Sprite;
    public var seats_Module:MovieClip;
    public var speaker_Module:MovieClip;//喇叭
    public var sides_Module:MovieClip;
    public var air_Module:MovieClip;
    //
    public var vipModule:MovieClip;
    public var rankView_Module:MovieClip;
    public var rankWeek_Module:MovieClip;
    public var rankGift_Module:MovieClip;
    public var playInfo_Module:MovieClip;
    public var personInfo_Module:MovieClip;
    public var parking_Module:MovieClip;
    public var rslModuleContainer:Sprite;
    //进入限制模块
    public var enterLimit_Module:MovieClip;
    public var rightSelectObject:Object;//右键选择对象
    //右边菜单
    public var rightMenuBar:MovieClip;//右键选择对象
    public var chatRoomModule:MovieClip;

    /**http://www.1room.my/
     * 事件处理者 看做保姆.. 做所有的功能
     */
    public var roomHandler:RoomEventHandler;
    public var giftPool:GiftPool;

    public function VideoRoom():void {
        Security.allowInsecureDomain("*");
        Security.allowDomain("*");
        LoaderMax.defaultContext = new LoaderContext(false, ApplicationDomain.currentDomain);
        roomHandler = new RoomEventHandler(this);
        if (stage) {
            init();
        } else {
            addEventListener(Event.ADDED_TO_STAGE, init);
        }
    }

    /**
     * 初始化UI界面
     * 获取页面参数
     * 添加回调函数
     * @param event
     */
    public function init(event:Event = null):void {
        RootManager.register(this);
        ControlsManger.regCotrolls();
        ClientManger.getInstance().initCCdebug();
        ClientManger.getInstance().register(this);
        ModuleLoaderManger.getInstance().register(ModuleNameType.VIDEO_ROOM, this);
        this.appLay = new Sprite();
        this.addChild(this.appLay);
        //背景
        this.backGround = new Sprite();
        this.appLay.addChild(this.backGround);
        //主场景
        this.rootSpr = new Sprite;
        this.appLay.addChild(this.rootSpr);
        this.body = new Sprite;
        this.rootSpr.addChild(this.body);
        roomWestUIView = new Sprite();
        body.addChild(roomWestUIView);
        roomEastUIView = new Sprite();
        body.addChild(roomEastUIView);
        videoUIView = new Sprite();
        body.addChild(videoUIView);
        //装饰
        this.adornSpr = new Sprite;
        this.appLay.addChild(this.adornSpr);
        //礼物
        this.giftSpr = new Sprite;
        this.giftSpr.mouseChildren = false;
        this.giftSpr.mouseEnabled = false;
        this.appLay.addChild(this.giftSpr);
        giftPool = new GiftPool();
        //顶层
        this.stageSpr = new Sprite;
        this.appLay.addChild(this.stageSpr);
        //警告层
        this.alertVE = new Sprite;
        this.alertVE.mouseEnabled = false;
        this.appLay.addChild(this.alertVE);
        this.getParameters();//获取参数
        //
        this.stage.stageFocusRect = false;
        this.stage.addEventListener("videoRoomChangeEvent", onVideoRoomChangeHandle);
        if (ExternalInterface.available) {
            ExternalInterface.addCallback("userFlashLogin", connectService);
        }
        //右键菜单
        var gcontextMenu:GContextMenu = new GContextMenu();
        gcontextMenu.addMenu("NUM1.co 开发");
        gcontextMenu.addMenu("版本:" + VideoConfig.VERSION);
        gcontextMenu.addMenu("编译时间:" + VideoConfig.BUILDTIME);
        this.contextMenu = gcontextMenu.contextMenu;
        //注册各个模块的冒泡事件
        addEventListener("rechargeEvent", onGiftRechargeEvent);//充值
        addEventListener(CBModuleEvent.FLY_PINGMU, onFlyPing);
    }

    private function onFlyPing(e:CBModuleEvent):void {
        FlyMessgaeModule.getInstance().addMessage(e.dataObject as String);
    }

    public function checkIsLoginAndPopPane():void {
        if (UserVoDataManger.playerState == PlayerType.GUEST) {
            ClientManger.getInstance().addChatSpanMessage({message: "你已经观看5分钟请注册以后再来观看...", color: "0xFF00FF"});
            ClientManger.getInstance().addChatSpanMessage({message: "后台小弟已经把RTMP视频流中断...", color: "0xFF00FF"});
            NetManager.getInstance().closeSocket();
            var videoMoule:IPlayer = ModuleLoaderManger.getInstance().getModule(ModuleNameType.VIDEOPLAYER) as IPlayer;
            videoMoule.closePublish();
        }
    }


    public function netAppInit():void {
        NetManager.getInstance().appInit = true;
        NetManager.getInstance().connectRoom();
        setTimeout(checkIsLoginAndPopPane, 1000 * 60 * 10);
    }

    /**
     * 尺寸变化
     * @param e
     */
    private function onViewLayoutStageHandle(e:ktvStageEvent):void {
        var _layout:Object = e.data;
        if (this.rightMenu_Module) {


            vipModule.x =this.rankMenu_Moudle.x = _layout.leftBase.x +40;
            this.rankMenu_Moudle.y = _layout.leftBase.y ;
            rankMenu_Moudle.adjustHeiht(200);
            vipModule.y = rankMenu_Moudle.y + rankMenu_Moudle.height + 5;
            vipModule.height = _layout.leftBase.h - (rankMenu_Moudle.height+40);


           // vipModule.y = rankMenu_Moudle.y + rankMenu_Moudle.height + 10;
            videoUIView.x = _layout.centerBase.x;
            videoUIView.y = _layout.centerBase.y -4 ;
            this.gift_Module.y = 550;
            this.gift_Module.y =  seats_Module.y+seats_Module.height -40;

//            if(this.stage.stageHeight> _layout.leftBase.h)
//            {
//                this.gift_Module.y =  _layout.leftBase.y+ _layout.leftBase.h -  this.gift_Module.height+40;
//            }
//            this.gift_Module.y= this.gift_Module.y<=550? 550:this.gift_Module.y;

//            var dh=_layout.leftBase.h- this.gift_Module.height+_layout.leftBase.y;
//            if(this.gift_Module.y>dh)
//            {
//                this.gift_Module.y = dh;
//            }

            roomEastUIView.x =_layout.rightBase.x+4;
            this.userInfo_Module.x = _layout.rightBase.x;
            chatRoomModule.height = _layout.rightBase.h;
//            video_Module["width"]=  720 ;
//            video_Module["height"]=  540 ;
            this.rootSpr.x = _layout.view.x;
            this.rootSpr.y = _layout.view.y;
        }
        if (this.rootSpr.x >= 0) {
            this.logo_Module.x = 10;
            this.playInfo_Module.x = 0;
        } else {
            this.logo_Module.x = this.rootSpr.x;
            this.playInfo_Module.x = this.rootSpr.x;
        }
        //this.playInfo_Module.height = _layout.leftBase.h ;
        this.speaker_Module.y = _layout.view.h - this.speaker_Module.getSpeakHeight();
        this.speaker_Module.width = this.stage.stageWidth;

        speaker_Module.visible =false;
        //车
        this.parking_Module.visible = true;
        this.parking_Module.x = this.stage.stageWidth;
        this.parking_Module.y = this.speaker_Module.y + this.speaker_Module.getInPutHeight() - this.parking_Module.height;
        this.parking_Module.visible =false;
        //飞屏
    }

    private function initWestUI():void {
        //6左侧
        this.rankMenu_Moudle = VideoTool.getMCTaven("common.LeftMenu");

        this.roomWestUIView.addChild(this.rankMenu_Moudle);
        ModuleLoaderManger.getInstance().register(ModuleNameType.LEFTMENU, rankMenu_Moudle);

        //24贡献榜
        this.rankView_Module = VideoTool.getMCTaven("RankViewModule");
       // this.rankView_Module.width = 270;
        this.rankMenu_Moudle.addSubView(this.rankView_Module);
        ModuleLoaderManger.getInstance().register(ModuleNameType.RANKVIEWMODULE, rankView_Module);
        //25礼物排行模块
        this.rankGift_Module = VideoTool.getMCTaven("RankGiftModule");
        this.rankMenu_Moudle.addSubView(this.rankGift_Module);
        VideoTool.loadXMLRes(VideoConfig.configXML.top.@gift.toString(), "giftTop", rankGift);
        function rankGift(obj:Object):void {
            rankGift_Module.updateData(FormatDataTool.rankGiftArray(obj as Array));
        }

        ModuleLoaderManger.getInstance().register(ModuleNameType.RANKGIFTMODULE, rankGift_Module);
        //26周贡榜
        this.rankWeek_Module = VideoTool.getMCTaven("RankViewModule", true);
        this.rankWeek_Module.visible = false;
      //  this.rankWeek_Module.width = 270;
        this.rankMenu_Moudle.addSubView(this.rankWeek_Module);
        var weekString:String = VideoConfig.configXML.top.@week.toString() + "?uid=" + VideoConfig.roomID + "&psize=30" + "&time=" + Math.random();
        VideoTool.loadXMLRes(weekString, "weekTop", rankWeek);
        function rankWeek(obj:Object):void {
            rankWeek_Module.updateData(FormatDataTool.rankViewArray(obj as Array));
        }

        //27左用户栏
        //28用户信息面板 弹出式
        this.personInfo_Module = VideoTool.getMCTaven("PersonInfoModule");
        this.personInfo_Module.visible = false;
        this.stageSpr.addChild(this.personInfo_Module);
        ModuleLoaderManger.getInstance().register(ModuleNameType.PERSONINFOMODULE, personInfo_Module);
        //最新加入贵宾席
        vipModule = VideoTool.getMCTaven("RankVipModule") as MovieClip;
        ModuleLoaderManger.getInstance().register(ModuleNameType.RANK_VIP, vipModule);
        roomWestUIView.addChild(vipModule);
    }

    private function initVideoUI():void {

        //12 中间视频设置
        sides_Module = VideoTool.getMCTaven("sidesGroup");
        videoUIView.addChild(sides_Module);
        sides_Module.showTranUsers(false);
        ModuleLoaderManger.getInstance().register(ModuleNameType.SIDESGROUP, sides_Module);
        //14 多少人 多少关注;
        this.roomPlayInfor = VideoTool.getMCTaven("leftMap");
        this.roomPlayInfor.addEventListener(StatusEvent.STATUS, onLeftMapMouseEvent);
        ModuleLoaderManger.getInstance().register(ModuleNameType.VIDEO_PLAY_INFO, this.roomPlayInfor);
        this.videoUIView.addChild(this.roomPlayInfor);
        this.roomPlayInfor.x = -148;
        this.roomPlayInfor.y = 340;
        //18座位
        this.seats_Module = VideoTool.getMCTaven("seatView.Userpark");
        seats_Module.x = 16;
        this.seats_Module.y = 470;
        this.seats_Module.addEventListener(ktvEvent.KTV_TypeEvent, onSeatsKTVEvent);
        videoUIView.addChild(this.seats_Module);
        ModuleLoaderManger.getInstance().register(ModuleNameType.SEATS_MODULE, seats_Module);
        //15******礼物面板 //roger 重构
        this.gift_Module = VideoTool.getMovieClipInstance("giftModule.GiftUI");
        //Cc.log("==========================================================")
        //Cc.log(VideoConfig.httpTomcat + VideoConfig.configXML.head.@gifturl + "?time=" + Math.random())
        this.gift_Module.configURLS(VideoConfig.httpTomcat + VideoConfig.configXML.head.@gifturl + "?time=" + Math.random(), VideoConfig.httpTomcat + VideoConfig.configXML.head.@depoturl, VideoConfig.HTTP);
        this.gift_Module.y = 470;
        this.gift_Module.x =-20;

        this.gift_Module.addEventListener("sendGift", onGiftMouseEvent);
        videoUIView.addChild(this.gift_Module);
        ModuleLoaderManger.getInstance().register(ModuleNameType.GIFT_MODULE, gift_Module);
        //进入限制模块
        enterLimit_Module = VideoTool.getMCTaven("LimitEnterModule");
        enterLimit_Module.hide();
        videoUIView.addChild(enterLimit_Module);
        ModuleLoaderManger.getInstance().register(ModuleNameType.LIMIT_EnterModule, enterLimit_Module);
        //10********视频
        this.video_Module = VideoTool.getClassByModule("video.VideoPlayerView", "videoModule") as IPlayer;
        this.video_Module.addEventListener("reGOHallEvent", onBackHallEvent);//回到大厅
        videoUIView.addChild(video_Module as DisplayObject);
        ModuleLoaderManger.getInstance().register(ModuleNameType.VIDEOPLAYER, video_Module as DisplayObject);
    }

    private function initEastUI():void {

        //聊天框
        var mc:MovieClip = new bulletin();
      //  mc.x = 920;
        //mc.y = 95;
       // roomEastUIView.addChild(mc);
        ModuleLoaderManger.getInstance().register(ModuleNameType.ROOMMESS, mc);
        chatRoomModule = VideoTool.getMovieClipInstance("ChatRoomModule");
        //chat2.x = 920;
        chatRoomModule.y = 50;
        chatRoomModule.x = 5;
        roomEastUIView.addChild(chatRoomModule);
        addEventListener(CBModuleEvent.PLAYNAMELINK, onChatLinkEvent);
        ModuleLoaderManger.getInstance().register(ModuleNameType.CHAT_MODULE2, chatRoomModule);
        //***********
        userInfo_Module = VideoTool.getMCTaven("UserInfo");
        userInfo_Module.y = 10;
        userInfo_Module.addEventListener(StatusEvent.STATUS, roomHandler.onUserInfo);
        roomEastUIView.addChild(this.userInfo_Module);
        ModuleLoaderManger.getInstance().register(ModuleNameType.USERINFOUI, userInfo_Module);
        //6左侧
        this.rightMenuBar = VideoTool.getMCTaven("common.RightMenuBar");
        roomEastUIView.addChild(rightMenuBar);
        this.rightMenuBar.y = 15;
        this.rightMenuBar.x = -5;
    }

    /**
     * 初始化模块
     */
    override public function initModules():void {
        this.logo_Module = VideoTool.getMovieClipInstance("shareElement.logo");
        this.logo_Module.y = 10;
        this.logo_Module.num_txt.visible = false;
        this.logo_Module.buttonMode = true;
        this.logo_Module.visible =false;

        this.logo_Module.addEventListener(MouseEvent.CLICK, VideoTool.jumpToMainURL);
        this.stageSpr.addChild(this.logo_Module);
        this.playInfo_Module = VideoTool.getMCTaven("PlayInfoModule");
        this.playInfo_Module.y = 10;
        this.stageSpr.addChild(this.playInfo_Module);
        this.playInfo_Module.headFormat = VideoTool.getAudienceHeadImg(
        );
        ModuleLoaderManger.getInstance().register(ModuleNameType.PLAYINFOMODULE, playInfo_Module);
        //右键菜单
        this.rightMenu_Module = VideoTool.getMCTaven("rightView.MenuList");
        this.rightMenu_Module.addEventListener("menuListSelectEvent", roomHandler.onMenuListSelectEvent);
        stageSpr.addChild(this.rightMenu_Module);
        ModuleLoaderManger.getInstance().register(ModuleNameType.RIGHT_MENULIST, rightMenu_Module);
        //29停车位
        this.parking_Module = VideoTool.getMCTaven("ParkingModule");
        this.parking_Module.pageSize = 0;
        this.parking_Module.visible = false;
        stageSpr.addChild(parking_Module);
        ModuleLoaderManger.getInstance().register(ModuleNameType.PARKINGMODULE, parking_Module);
        //31喇叭
        this.speaker_Module = VideoTool.getMCTaven("SpeakerModule");
        this.speaker_Module.addEventListener("speakerCompleteEvent", onSpeakerCompleteEvent);
        this.speaker_Module.addEventListener("speakerClickEvent", onSpeakerClickEvent);//-------新增
        this.stageSpr.addChild(this.speaker_Module);
        ModuleLoaderManger.getInstance().register(ModuleNameType.SPEAKERMODULE, speaker_Module);
        initWestUI();
        initEastUI();
        initVideoUI();
        backGroundSprite = new BackGroundLay();
        backGroundSprite.addEventListener(ktvStageEvent.KTV_StageEvent, onViewLayoutStageHandle);
        backGround.addChild(backGroundSprite);
        //屏蔽关键字
        SensitiveWordFilter.init(VideoConfig.httpTomcat);
        //全屏滚动器
        new ScrollStageControl(this);
        //很多模块都用这个侦听器
        addEventListener(StatusEvent.STATUS, roomHandler.onVideoStatusEvent, true);
        netAppInit();
        LoadUI.setLoadInfo("开始进入视频大厅...", 100);
        //
        //showCarGame();
        //showFingerGame();
        this.rslModuleContainer = RslModuleManager.instance.rslContainer;
        this.rslModuleContainer.mouseEnabled = false;
        RslModuleManager.instance.$videoroom = this;
        this.stageSpr.addChild(this.rslModuleContainer);
    }

    /**
     * 重置模块
     */
    override public function resetModule():void {
        if (video_Module) {
            var iChat:IChat = ModuleLoaderManger.getInstance().getModule(ModuleNameType.CHAT_MODULE2) as IChat;
            iChat.clear();
            //
            Object(this.roomPlayInfor).resetModule();
        }
    }

    /**
     *  js 调用 关闭rtmp 连接
     */
    override public function closeRtmpHandle():void {
        if (video_Module) {
            video_Module["closeRtmpNoResetConnect"]();
            //   Alert.Show("浏览器已经被刷新", "刷新浏览器了！");
        }
    }

    /**
     * 连接socket服务器
     */
    override public function connectService():void {
        VideoConfig.loginKey = ClientManger.getInstance().getUserKey();
        UserVoDataManger.getInstance().register(this);
        NetManager.getInstance().connectSocket(VideoConfig.HOST, VideoConfig.PORT, VideoConfig.roomID, VideoConfig.loginKey)
    }

    /**
     * 连接socket服务器
     */
    public function AirConnectService(_key:String):void {
        VideoConfig.loginKey = _key;
        connectService();
    }

    /**
     * 回到大厅事件
     * @param e
     */
    private function onBackHallEvent(e:Event):void {
        ClientManger.getInstance().gotoHall();
    }

    /**
     * 主播信息栏事件
     * @param e
     */
    private function onLeftMapMouseEvent(e:StatusEvent):void {
        switch (e.level) {
            case "roomConfigPanel"://打开房间设置面板
                break;
            case "atten"://关注
                //e.dataObject:用户信息
                //例:取当前主播id:e.dataObject.uid
                //例:取当前主播name:e.dataObject.name
                break;
            case "hasAtten"://已关注
                            //e.dataObject:用户信息
                break;
            case "space"://访问空间
                //e.dataObject:用户信息
                break;
            case "Alert":
                Alert.Show(this.roomPlayInfor.alertMsg.msg, this.roomPlayInfor.alertMsg.title);
                break;
            case "login":
                ClientManger.getInstance().guestLogin();
                break;
            default:
                break;
        }
        //访问三个按钮对象
        //this.roomPlayInfor.atten_bt //关注按钮
        //this.roomPlayInfor.hasAtten_bt //已关注按钮
        //this.roomPlayInfor.space_bt //访问空间按钮
    }

    /**
     * 抢座
     * @param e
     */
    private function onSeatsKTVEvent(e:ktvEvent):void {
        if (ClientManger.getInstance().isGuestAndGuestRegister()) {
            return;
        }
        if (UserVoDataManger.userData.uid == e.dataObject.uid) {
            Alert.Show("该座位已经被您所占,无须再占！", "占位失败");
        } else {
            var _num:int = int(e.dataObject.value);
            NetManager.getInstance().sendDataObject({"cmd": 14002, seatid: e.dataObject.seatid, num: _num});
        }
    }

    /**
     * 礼物模块gift_Module
     * 礼物事件...
     * @param e
     */
    private function onGiftMouseEvent(e:Event):void {
        trace("onGiftMouseEvent...");
        if (ClientManger.getInstance().isGuestAndGuestRegister()) {
            Cc.debug("没有登录....");
            return;
        }
        if (gift_Module.gnum <= 0) {
            Alert.Show("输入有误！", "提醒");
            return;
        }
        //贵族检测
        var guizu:Array = [66, 168, 366, 666];
        if (guizu.indexOf(gift_Module.gnum) != -1) {
            if (UserVoDataManger.getInstance().isGuiZhu == false) {
                Alert.Show("您必须成为贵族才能赠送贵族专属礼物轨迹！点击开启贵族!", "提醒", true, 3, false, function ():void {
                    VideoTool.jumpToGuiZhuURL();
                });
                return;
            }
        }
        if (!UserVoDataManger.videoOwner) {
            Alert.Show("当前房间没有主播，无法赠送礼物！", "提醒");
            return;
        } else if (UserVoDataManger.userData.uid == UserVoDataManger.videoOwner.uid) {
            Alert.Show("您是当前主播,不能自己给自己送礼！", "提醒");
            return;
        }
        //Cc.log("礼物事件 ", gift_Module.gid, gift_Module.gnum, UserVoDataManger.videoOwner.uid);
        NetManager.getInstance().sendDataObject({
            "cmd": 40001,
            "gid": gift_Module.gid,
            "uid": UserVoDataManger.videoOwner.uid,
            "gnum": gift_Module.gnum
        });//
    }

    /**
     * 通用
     * 充值事件
     * @param e
     */
    private function onGiftRechargeEvent(e:Event):void {
        Cc.log("通用 充值事件");
        ClientManger.getInstance().userPay();
    }

    /**
     * 超链接点击
     * @param e
     */
    private function onChatLinkEvent(e:*):void {
        if (UserVoDataManger.playerState == PlayerType.GUEST) {//游客
            return;
        }
        var _userObj:UserVo = e.dataObject;
        //如果是神秘人不可以点  但是是自己的话可以点
        if (UserVoDataManger.getInstance().isSelf(_userObj.uid) == false) {
            if (_userObj.hidden == 1) {
                return;
            }
        }
        var _ar:Array = [{label: "查看资料", data: 92}, {label: "@他", data: ChatState.FACETOFACE}];
        if (UserVoDataManger.getInstance().isSelf(_userObj.uid) == false) {
            //_ar.push({label: "发送私聊", data: 1});
            if (UserVoDataManger.getInstance().canGetMangerCompetence) {
                if (_userObj.ruled < 1 && _userObj.lv < 2) {
                    _ar.push({label: "禁止聊天", data: 42});
                    _ar.push({label: "T出房间", data: 41});
                }
            }
            if (UserVoDataManger.roomAdmin) {
                if (_userObj.ruled < 1) {
                    _ar.push({label: "设为管理员", data: 31});
                } else {
                    _ar.push({label: "取消管理员", data: 32});
                }
            }
        } else {
            _ar.push({label: "我的关注", data: 93});
            _ar.push({label: "我的道具", data: 94});
            _ar.push({label: "消费记录", data: 95});
            _ar.push({label: "马上充值", data: 80});
            _ar.push({label: "个人中心", data: 91});
            _ar.push({label: "退出登陆", data: 99});
        }
        Object(this.rightMenu_Module).initMenus(_ar);
        this.rightSelectObject = e.dataObject;
        if (this.rightMenu_Module.width + this.mouseX <= this.stage.stageWidth) {
            this.rightMenu_Module.x = this.mouseX;
        } else {
            this.rightMenu_Module.x = this.mouseX - this.rightMenu_Module.width;
        }
        if (this.rightMenu_Module.height + this.mouseY <= this.stage.stageHeight) {
            this.rightMenu_Module.y = this.mouseY;
        } else {
            this.rightMenu_Module.y = this.mouseY - this.rightMenu_Module.height;
        }
    }

    /**
     * 主播关注接口
     * @param e
     */
    public function onPlayerStatusEvent(e:StatusEvent):void {
        try {
            if (e.code == "http") {
                var _json:Object = JSON.parse(e.level);
                _json = JSON.parse(FormatDataTool.decode(_json.info));
                _json.letterURL = VideoConfig.httpFunction + VideoConfig.configXML.http.@letter.toString();
                _json.focusURL = VideoConfig.httpFunction + VideoConfig.configXML.http.@focus.toString();
                this.roomPlayInfor.dataFocus = FormatDataTool.personInfo(_json);
                this.roomPlayInfor.isPlayer = UserVoDataManger.getInstance().isVideoPublisher;
            }
        } catch (e:*) {
        }
    }

    /**
     * 喇叭模块
     * @param e
     */
    private function onSpeakerCompleteEvent(e:Event):void {
        NetManager.getInstance().sendDataObject({
            "cmd": 30001,
            "type": 5,
            "recUid": 0,
            "content": this.speaker_Module.text + "?rname=" + UserVoDataManger.roomData.name + "&rid=" + UserVoDataManger.roomData.roomid
        });//拉取用户列表
    }

    //---------新增
    private function onSpeakerClickEvent(e:Event):void {
        if (ClientManger.getInstance().isGuestAndGuestRegister()) {
            return;
        }
        this.speaker_Module.openAndCloseInput();
    }

    /**
     * 切换房间
     * @param e
     */
    private function onVideoRoomChangeHandle(e:ktvStageEvent):void {
        if (UserVoDataManger.roomData.roomid == e.data.data.roomid) {
            Alert.Show("您当前正在该房间内!", "提示");
            return;
        }
        if (UserVoDataManger.getInstance().isVideoPublisher) {//主播
            Alert.Show("亲,如果您去别的主播房间就会中断自己的直播,您确定还要切换房间吗?", "房间切换",
                    false,
                    3,
                    true,
                    function (_v:*):void {
                        if (_v == 1) {
                            UserVoDataManger.cutoData = e.data.data;
                            //UserVoDataManger.roomFactorFilter(e.data.data);//开始进入进房流程
                        }
                    });
        } else {//普通人
            //UserVoDataManger.cutoData = e.data.data;
            //UserVoDataManger.roomFactorFilter(e.data.data);//开始进入进房流程
        }
    }

    /**
     * 显示第几次签到信息
     * @param sObject
     */
    public function showetSignActivity(sObject:Object):void {
        var module:MovieClip = ModuleLoaderManger.getInstance().getModule(ModuleNameType.PLAYINFOMODULE) as MovieClip;
        module.view.btnGet.visible = sObject.sign == 1 ? true : false;
        if (module.view.btnGet.visible == false) {
            return;
        }
        //否则显示签到面板
        var panel:SignActivityPanel = stage.getChildByName("SignActivityPanel") as SignActivityPanel;
        if (panel == null) {
            panel = new SignActivityPanel();
            panel.name = "SignActivityPanel";
            ModuleLoaderManger.getInstance().register("SignActivityPanel", panel);
        }
        panel.init(sObject, module.view.btnGet);
    }

    /**
     * #####实现了IVideoRoom#####给每个模块用的####不要随意删除######
     */
    /**
     * 给每个模块用的
     * 获取到登录状态
     *
     */
    public function checkState():int {
//        Cc.log(UserVoDataManger.playerState)
        return UserVoDataManger.playerState;
    }

    /**
     * 给每个模块用的
     * 发送数据函数
     * @param src
     */
    public function sendDataObject(src:Object):void {
        if (src.callBack != null) {
            var callBack:Function = src.callBack;
            src.callBack = null;
            ControlsManger.sendOneTimesMsg(src, callBack);
        }
        else {
            NetManager.getInstance().sendDataObject(src);
        }
    }

    /**
     * 给每个模块用的
     * 显示弹出窗口函数
     * @param a
     * @param a2
     * @param a3
     * @param a4
     * @param a5
     * @param a6
     * @param a7
     */
    public function showAlert(a:String = "", a2:String = "消息", a3:Boolean = true, a4:int = 3, a5:Boolean = false, a6:Function = null, a7:Object = null):void {
        Alert.Show.call(null, a, a2, a3, a4, a5, a6, a7);
    }

    /**
     * 给每个模块用的
     * 获取到别的其他模块
     * @param _name
     * @return
     */
    public function getModule(_name:String):Object {
        return ModuleLoaderManger.getInstance().getModule(_name);
    }

    /**
     * 给每个模块拿数据用
     * @param _name
     * @return
     */
    public function getDataByName(_name:String):Object {
        switch (_name) {
            case ModuleNameType.USERDATA:
                return UserVoDataManger.userData;
                break;
            case ModuleNameType.USERROOMDATA:
                return UserVoDataManger.roomData;
                break;
            case ModuleNameType.HTTPROOT:
                return VideoConfig.HTTP;
                break;
            case ModuleNameType.HTTPFUNCROOT:
                return VideoConfig.httpFunction;
                break;
            case ModuleNameType.TOMCATROOT:
                return VideoConfig.httpTomcat;
                break;
            case ModuleNameType.CONFIGXML:
                return VideoConfig.configXML;
                break;
            case ModuleNameType.SOCKETADDRESS:
                return VideoConfig.HOST;
                break;
            case ModuleNameType.RTMPADDRESS:
                return VideoConfig.connectRTMP;
                break;
            case ModuleNameType.MAINRTMPADDRESSLIST:
                return UserVoDataManger.adminPingManger;
                break;
            case ModuleNameType.SOCKETISCONNECT:
                return NetManager.getInstance().socketClient.connected;
                break;
        }
        return null;
    }
}
}
