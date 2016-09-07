package taven {
import com.greensock.TweenLite;
import com.rover022.CBProtocol;
import com.rover022.ModuleNameType;
import com.rover022.vo.PlayerType;

import display.BaseModule;

import flash.desktop.Clipboard;
import flash.desktop.ClipboardFormats;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.StatusEvent;
import flash.external.ExternalInterface;
import flash.geom.PerspectiveProjection;
import flash.ui.Keyboard;
import flash.utils.Dictionary;

import ghostcat.util.display.DisplayUtil;

import manger.ClientManger;

import manger.DataCenterManger;

import taven.enum.EventConst;
import taven.enum.EventUtils;
import taven.seatView.LoadMaterial;
import taven.sideGroup.ChangeLineView;
import taven.sideGroup.DateListView;
import taven.sideGroup.GiftCircleView;
import taven.utils.DisplayUtils;

import tool.VideoTool;

public class sidesGroup extends BaseModule {
    private var _view:taven_sidesGroup;
    /**公用数据储存*/
    public var data:*;
    /** 当前点击的item数据*/
    private var selectItem:Object;
    /**建立主播对应表*/
    private var _dataMap:Dictionary;
    /**主播数据*/
    private var _videoList:Array;
    /**当前数据*/
    private var _curvideoPage:int;
    private var _dateView:DateListView;
    public var _shareMC:shareMC;
    //当前房间是否是主播
    private var _isAnchor:Boolean;
    //延迟初始化
    private var _changeLineView:ChangeLineView;
    private var _gitCircle:GiftCircleView;
    //礼物跑道
    public function get gitCircle():GiftCircleView {
        if (!_gitCircle) {
            _gitCircle = new GiftCircleView(this._view.mcCircie, this.$videoroom);
        }
        return _gitCircle;
    }

    public function onRichMessage(data:*):void {
        var obj:Object = {};
        obj.created = data.created;
        obj.roomid = data.roomid;
        obj.sendName = data.sendName;
        obj.recName = data.recName;
        obj.gnum = data.gnum;
        obj.sendHidden = data.sendHidden;
        obj.resAdd = data.resAdd;
        obj.gid = data.gid;
        gitCircle.onMessAdd(obj);
    }

    override protected function initView():void {
        _view = new taven_sidesGroup();
        VideoTool.buildButtonEff(_view.btnDate);
        VideoTool.buildButtonEff(_view.bulletin_bt);
        VideoTool.buildButtonEff(_view.btnShare);
        //VideoTool.buildButtonEff(_view.btnTransUser);
        VideoTool.buildButtonEff(_view.btnChange);
        VideoTool.buildButtonEff(_view.btnClearGit);
        $view = _view;
        _view.mvVideo.x = 68;
        _view.mvVideo.y = 223;
        initHotVideo();
        this.addChild(_view);
        _view.mcDateView.visible = false;
        _view.btnLimit.visible = false;
        _view.btnLimit.stop();
        _view.btnLimit.buttonMode = true;
        this._view.mcCircie.visible = false;
        _view.btnClearGit.mouseChildren=false;
        _view.btnClearGit.y-=5;
        _view.btnClearGit.stop();
        //_view.visible=false;
    }

    override protected function initListeners():void {
        this.mouseEnabled = false;
        _view.mouseEnabled = false;
        this.addEventListener(MouseEvent.CLICK, _sidesMouseEvent);
     //   _view.btnTransUser.visible = false;
        _view.viewTransUser.visible = false;
        _view.viewTransUser.txtHouse.restrict = "0-9";
        _view.viewTransUser.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        _view.btnLimit.addEventListener(MouseEvent.CLICK, onClickLimit);
    }

    private function initHotVideo():void {
        _dataMap = new Dictionary(true);
        var item:tean_middle_itemRender;
        for (var i:int = 1; i <= 3; i++) {
            item = _view.mvVideo["itemDown" + i];
            item.visible = false;
            item.mouseChildren = false;
            item.buttonMode = true;
            item.addEventListener(MouseEvent.CLICK, onItemVideoClickHandle);
            //
            var _headFace:LoadMaterial = new LoadMaterial();
            _headFace.logo_mc.removeChildren();
            _headFace.logo_mc.addChild(item.mcHead.mcBg);
            item.mcHead.addChild(_headFace);
            _dataMap[item] = _headFace;
            _headFace.width = 180;
            _headFace.height = 135;
            _headFace.loading_mc.x = 10;
            _headFace.loading_mc.y = 10;
            _headFace.x = _headFace.width / 2;
            _headFace.y = int(_headFace.height / 2);
        }
        showHotVideo(false)
    }

    private function showTranUser(visible:Boolean):void {
        if (visible) {
            if (this.stage) {
                this.stage.focus = _view.viewTransUser.txtHouse;
            }
            _view.viewTransUser.txtHouse.text = "";
            tweenVisible(_view.viewTransUser, true)
        }
        else {
            tweenVisible(_view.viewTransUser, false)
        }
    }

    private function onKeyDown(evt:KeyboardEvent):void {
        if (evt.keyCode == Keyboard.ENTER) {
            _view.viewTransUser.btnOk.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
        }
    }
    private function dispatchModuleEvent(_data:String):void {
        this.dispatchEvent(new StatusEvent(StatusEvent.STATUS, false, false, "sides", _data));

    }
    private function _sidesMouseEvent(e:MouseEvent):void {
        if (e.target) {
            switch (e.target) {
                case _view.bulletin_bt:
                    this.dispatchModuleEvent("bulletin");
                    break;
                case _view.viewTransUser.btnClose://
                    _view.viewTransUser.visible = false;
                    break;
                case _view.viewTransUser.btnOk:/**操作用户转移*/
                    if (_view.viewTransUser.txtHouse.text != "") {
                        data = _view.viewTransUser.txtHouse.text;
                        dispatchModuleEvent("tranUser");
                        _view.viewTransUser.visible = false;
                    }
                    break;
//                case _view.btnTransUser:
//                    showTranUser(!_view.viewTransUser.visible);
//                    break;
                case _view.mvVideo.btnNexPage:
                    updateVideoData(_videoList, _curvideoPage + 1);
                    break;
                case _view.btnShare: //分享
                    if (_shareMC == null) {
                        _shareMC = new shareMC();
                        _shareMC.btnClose.addEventListener(MouseEvent.CLICK, function (e:MouseEvent):void {
                            DisplayUtils.removeFromParent(_shareMC);
                        });
                        _shareMC.btnOk.addEventListener(MouseEvent.CLICK, function (e:MouseEvent):void {
                            DisplayUtils.removeFromParent(_shareMC);
                        })
                    }
                    _shareMC.x = (stage.stageWidth -_shareMC.width)/2;
                    _shareMC.y =  (stage.stageHeight -_shareMC.height)/2-30;
                    _shareMC.alpha = 0;
                    TweenLite.to(_shareMC, 0.5, {alpha: 1});
                    stage.addChild(_shareMC);
                    if (ExternalInterface.available) {
                        var textToCopy:String = ExternalInterface.call('function(){return document.location.href.toString()}');
                        Clipboard.generalClipboard.clear();
                        Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, textToCopy, false);
                    }
                    break;
                case _view.btnDate://点击查看预约
                    dateView.toggleView();
                    break;
                case  _view.btnChange://点击切线
                    if (!_changeLineView)//延迟初始化
                    {
                        _changeLineView = new ChangeLineView(_view.btnChange, this);
//                        _view.btnChange.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
                    }
                    stage.addChild(_changeLineView);
                    break;
                case _view.btnClearGit:
                {
                    if(_view.btnClearGit.currentFrame==1)
                    {
                        _view.btnClearGit.gotoAndStop(2);
                        DataCenterManger.isShowGiftEffect=false;
                    }
                    else
                    {
                        _view.btnClearGit.gotoAndStop(1);
                        DataCenterManger.isShowGiftEffect=true;
                    }
                }
                case _view.btnMoney://在线充值
                    ClientManger.getInstance().userPay();
                    break;
                case _view.btnVip://办理vip
                    VideoTool.jumpToGuiZhuURL();
                    break;
                default:
            }
        }
    }

    /**
     * 可以在一个元件上方显示一个提示小箭头;
     * @param srcMc
     */
    public function showTishiMc(srcMc:MovieClip):void {
        if (srcMc.tixing) {
            return;
        }
        var mc:tixingMc = new tixingMc();
        mc.name = "tixingMc";
        mc.mouseEnabled = false;
        mc.mouseChildren = false;
        mc.x = srcMc.x + srcMc.width;
        mc.y = srcMc.y;
        srcMc.tixing = mc;
        srcMc.parent.addChild(mc);
        srcMc.addEventListener(MouseEvent.CLICK, _click);
        function _click(e:MouseEvent):void {
            srcMc.removeEventListener(MouseEvent.CLICK, _click);
            mc.parent.removeChild(mc);
            srcMc.tixing = null;
        }
    }

    private function tweenVisible(view:DisplayObject, visibleStatue:Boolean):void {
        if (view.visible != visibleStatue) {
            if (visibleStatue == false) {
                view.visible = visibleStatue;
            }
            else {
                view.visible = visibleStatue;
                view.alpha = 0;
                TweenLite.to(view, 0.5, {alpha: 1});
            }
        }
    }

    private function onItemVideoClickHandle(evt:Event):void {
        var item:MovieClip = evt.currentTarget as MovieClip;
        selectItem = _dataMap[item.name];
        data = selectItem.roomid;
        dispatchModuleEvent(EventConst.PLAYER_VIDEO_ITEM);
    }

    private function onClickLimit(evt:MouseEvent):void {
        var data:Object = {};
        data.open = _view.btnLimit.currentFrame == 1 ? 1 : 0;
        data.roomid = videoRoom.getDataByName(ModuleNameType.USERROOMDATA).roomid;
        EventUtils.secndNetData(videoRoom, CBProtocol.enterRoomLimit_10012, data, s2cRoomLimita);
    }

    /**---------------------------------------------------------------外部接口------------------------------------------------------------*/
    private function s2cRoomLimita(data:*):void {
        if (data.open == 1) {
            videoRoom.showAlert("开启限制成功!");
        }
        else {
            videoRoom.showAlert("关闭限制成功!");
        }
    }

    public function showLimitVisible(visible:Boolean, isopen:Boolean):void {
        _view.btnLimit.visible = visible;
        _view.btnLimit.gotoAndStop(isopen ? 2 : 1);
    }

    /**是否显示正在直播 并更新ui 显示*/
    public function showHotVideo(visible:Boolean):void {
        if (_videoList == null || _videoList.length <= 0) {
            visible = false;
        }
        tweenVisible(_view.mvVideo, visible);
        //如果这个用户不是主播 显示一个换线动画元件;
        if (visible && DataCenterManger.playerState != PlayerType.ANCHOR) {
            showTishiMc(_view.btnChange);
        }
    }

    public function updateVideoData(resutArr:Array = null, page:int = 1):void {
        _videoList = resutArr;
        if (resutArr == null || resutArr.length <= 0) {
            _view.mvVideo.visible = false;
        }
        else {
            _curvideoPage = page;
            var maxPage:int = resutArr.length % 3 == 0 ? resutArr.length / 3 : (int(resutArr.length / 3) + 1);
            maxPage = maxPage == 0 ? 1 : maxPage;
            _curvideoPage = _curvideoPage < 1 ? 1 : _curvideoPage;
            _curvideoPage = _curvideoPage > maxPage ? 1 : _curvideoPage;
            var endIndex:int = _curvideoPage;
            if (_curvideoPage < maxPage) {
                endIndex = 3 * (_curvideoPage - 1 + 1)
            }
            else if (_curvideoPage == maxPage) {
                if (maxPage * 3 > resutArr.length) {
                    endIndex = 3 * (_curvideoPage - 1) + (resutArr.length - 3 * (_curvideoPage - 1));
                }
                else {
                    endIndex = maxPage * 3;
                }
            }
            //trace("strartInedx="+((_curvideoPage-1)*3)+"--end="+endIndex);
            var dataList:Array = resutArr.slice((_curvideoPage - 1) * 3, endIndex);
            for (var i:int = 1; i <= 3; i++) {
                var item:tean_middle_itemRender = _view.mvVideo["itemDown" + i] as tean_middle_itemRender;
                //todo 临时屏蔽
                _view.mvVideo["itemDown" + i].mcPlayer.visible = false;
                _view.mvVideo["itemDown" + i].txtPeopleNum.visible = false;
                if (dataList[i - 1]) {
                    item.visible = true;
                    item.txtName.text = dataList[i - 1].name;
                    item.txtPeopleNum.text = dataList[i - 1].people.toString();
                    if ((item as MovieClip).url != dataList[i - 1].headUrl) {
                        (_dataMap[item] as LoadMaterial).load(dataList[i - 1].headUrl);
                        (item as MovieClip).url = dataList[i - 1].headUrl;
                    }
                    _dataMap[item.name] = dataList[i - 1];
                }
                else {
                    item.visible = false;
                    _dataMap[item.name] = null;
                }
            }
        }
    }

    /**是否显示转移按钮*/
    public function showTranUsers(visible:Boolean):void {
      //  _view.btnTransUser.visible = visible;
    }

    /**是否显示切换线路。 只有用户才显示*/
    public function showChangeLine(visible:Boolean):void {
    }

    /**更新人数 单独的接口*/
    public function updateVideoInfos(data:Array):void {
        if (data && data.length > 0) {
            for each(var item:* in data) {
                for each(var obj:Object in _videoList) {
                    if (item.roomid == obj.roomid) {
                        obj.people = item.people;
                    }
                }
            }
            updateVideoData(_videoList, _curvideoPage);
        }
    }

    /**预约ui*/
    public function get dateView():DateListView {
        if (_dateView == null) {
            _dateView = new DateListView(_view.mcDateView, this);
            // _view.mcDateView.x -= 60;
        }
        return _dateView;
    }

    public function get isAnchor():Boolean {
        return _isAnchor;
    }

    //是否是主播
    public function set isAnchor(value:Boolean):void {
        _isAnchor = value;
        _view.btnChange.visible = !_isAnchor;
    }
}
}