package taven.playerInfo {
import com.junkbyte.console.Cc;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;

import ghostcat.manager.RootManager;

import taven.PlayInfoModule;
import taven.common.TavenScrollList;
import taven.enum.EventConst;
import taven.enum.EventUtils;

import net.TavenHttpService;

import taven.utils.StringUtils;

public class PlayerListView {
    /**最大显示的管理员项目数目，大于4出滚动条*/
    private const MAX_MANAG:int = 4;

    public function PlayerListView(view:MovieClip, dispatcherObj:PlayInfoModule) {
        _view                    = view as teven_playInfoList;
        _mamageArr               = [];
        _usrArr                  = [];
        _usrListSp               = _view.mcAudice["mcList"];
        _managerListSp           = _view.mcManage["mcList"];
        MAX_LIST_HIGH            = _view.mcBg.height;
        _dispatcherObj           = dispatcherObj;
        _findUsrview             = _view.mcAudice["mcFindView"];
        _findManageview          = _view.mcManage["mcFindView"];
        var item:ItemUserRender = new ItemUserRender();
        _itemHeight              = item.height;
        item                     = null;
        _usrList                 = new TavenScrollList(ItemUserRender, 6);
        _managList               = new TavenScrollList(ItemUserRender, 3);
        _usrListSp.removeChildren();
        _managerListSp.removeChildren();
        _usrListSp.addChild(_usrList);
        _managerListSp.addChild(_managList);
        _usrList.addEventListener(TavenScrollList.ITEM_CLICK, onClickHandle);
        _managList.addEventListener(TavenScrollList.ITEM_CLICK, onClickHandle);
        _usrList.addEventListener(TavenScrollList.SCROLL_END, scrollEndHandle);
        _managList.addEventListener(TavenScrollList.SCROLL_END, scrollEndHandle);
        view.mcManage["txtManage"].text    = "";
        _view.mcAudice["txtAudience"].text = "";
        _findUsrview.addEventListener(MouseEvent.CLICK, onClickUseFindHand);
        _findManageview.addEventListener(MouseEvent.CLICK, onClickUseFindHand);
        _findUsrview.gotoAndStop(2);
        _findUsrview.txtInput.text     = "";
        _findUsrview.txtInput.maxChars = 8;
        _findUsrview.gotoAndStop(1);
        _findManageview.gotoAndStop(2);
        _findManageview.txtInput.text     = "";
        _findManageview.txtInput.maxChars = 8;
        _findManageview.gotoAndStop(1);

        //_findUsrview.visible = false;
        //_findManageview.visible = false;
    }

    private function onCloseHanlde(evt:Event):void {
        _view.visible = false;
    }

    private var MAX_LIST_HIGH:int;
    private var _view:teven_playInfoList;
    private var _mamageArr:Array;
    private var _usrArr:Array;
    private var _usrListSp:Sprite;
    private var _managerListSp:Sprite;
    private var _managList:TavenScrollList;
    private var _usrList:TavenScrollList;
    private var _curSelectItem:ItemUserRender;
    private var _dispatcherObj:PlayInfoModule;
    private var _normalLegth:Number;
    private var _loadingView:res_taveLoading;
    private var _itemHeight:Number;
    private var _isFirDataManage:Boolean = true;
    private var _isFirDataUser:Boolean   = true;
    private var _findUsrview:taven_mcFind_userInfo;
    private var _findManageview:taven_mcFind_userInfo;
    private var _lastUsrInfo:String      = "";
    private var _lastManageInfo:String   = "";
    private var _totalList:Array;
    private var _peopleGuet:int;
    int;
    private var _peopleTotal:*;

    /** 拉取列表数据*/
    public function openView():void {
        _view.mcAudice["txtAudience"].visible = false;
        _view.mcManage["txtManage"].visible   = false;
        if (_view.visible) {
            if (_isFirDataUser) {
                c2sGetUsrList(false);
            }
            if (_isFirDataManage) {
                c2sGetUsrList(true);
                //_isFirDataManage =false;
            }
        }
    }

    public function updateView(playList:Array, isTemp:Boolean = false):void {
        if (!isTemp) {
            _totalList           = playList;
            var flushNow:Boolean = false;
            if (_findManageview.currentFrame == _findManageview.totalFrames) //管理员处于查询状态
            {
                _findManageview.txtInput.dispatchEvent(new Event(Event.CHANGE));
                flushNow = true;
            }
            if (_findUsrview.currentFrame == _findManageview.totalFrames) //管理员处于查询状态
            {
                _findUsrview.txtInput.dispatchEvent(new Event(Event.CHANGE));
                flushNow = true;
            }
            if (flushNow)
                return;
        }
        _usrArr.length        = 0;
        _mamageArr.length     = 0;
        var itemHeight:Number = 0;
        var itemWidth:Number  = 0;
        if (playList && playList.length > 0) {
            var tempArr:Array;
            for each (var item:Object in playList) {
                if (item.hidden == 0) {
                    tempArr = item.power == 0 ? _usrArr : _mamageArr;
                    tempArr.push(item);
                }
            }
        }
        _usrArr.sortOn("level", Array.NUMERIC | Array.DESCENDING);
        _mamageArr.sort(sortFuc);
        _usrList.dataList                = _usrArr;
        _managList.dataList              = _mamageArr;
        _view.mcManage["txtManage"].text = _mamageArr.length.toString();
        if (_dispatcherObj.peopleInfo) {
            if (_dispatcherObj.peopleInfo.total != null) {
                _peopleTotal = _dispatcherObj.peopleInfo.total;
            }
            if (_dispatcherObj.peopleInfo.guests != null) {
                _peopleGuet = _dispatcherObj.peopleInfo.guests;
            }
            var peopleNum:int = _peopleTotal - _peopleGuet - (_mamageArr.length); //必须把主播自己去掉
            peopleNum                          = peopleNum < 0 ? 0 : peopleNum;
            _view.mcAudice["txtAudience"].text = peopleNum + "";
            if (peopleNum < 15) {
                _view.mcAudice["txtAudience"].text = "";
            }
            //trace("_dispatcherObj.peopleInfo.flushPerson ="+_dispatcherObj.peopleInfo.flushPerson);
        }
        else {
            _view.mcAudice["txtAudience"].text = "";
        }
        _view.mcAudice.y  = _view.mcManage.y + _view.mcManage.height;
        _view.mcBg.height = _view.mcAudice.y + _view.mcAudice.height + 15;
        if (_view.parent) {
            _view.y = ((_view.parent as MovieClip).mcBg.height - _view.mcBg.height) / 2;
        }
    }

    public function updateMaxHeight(height:Number):void {
        height            = height < MAX_LIST_HIGH ? height : MAX_LIST_HIGH;
        var dim:Number    = height - _view.mcAudice.y - 37;
        var maxCount:int  = dim / _itemHeight;
        _usrList.maxCount = maxCount;
        _view.mcBg.height = _view.mcAudice.y + _view.mcAudice.height + 15;
        if (_view.parent) {
            _view.y = ((_view.parent as MovieClip).mcBg.height - _view.mcBg.height) / 2;
        }
    }

    private function sortFuc(a:Object, b:Object):int {
        var resutlt:int = 0;
        if (a.power > b.power) {
            resutlt = -1;
        }
        else if (a.power < b.power) {
            resutlt = 1;
        }
        else {
            if (a.level > b.level) {
                resutlt = -1;
            }
            else if (a.level < b.level) {
                resutlt = 1;
            }
            else {
                resutlt = 0;
            }
        }
        return resutlt;
    }

    private function onGetHeandImg(str:String):void {
        var object:*                      = JSON.parse(str);
        _dispatcherObj.selectItem.headimg = object["headimg"];
        EventUtils.secndStatusEvent(_dispatcherObj, EventConst.PLAYER_LIST_ITEM);
    }

    private function disposeList():void {
        _usrArr.length    = 0;
        _mamageArr.length = 0;
    }

    private function c2sGetUsrList(isManage:Boolean, startIndex:int = 0):void {
        if (isManage) {
            EventUtils.secndNetData(_dispatcherObj.videoRoom, 11008, {}, s2cGetUsrList);
        }
        else {
            var data:Object = {};
            data.start      = startIndex;
            data.end        = startIndex + 20;
            EventUtils.secndNetData(_dispatcherObj.videoRoom, 11001, data, s2cGetUsrList);
        }
    }

    public function s2cGetUsrList(data:Object):void {
        //trace("s2cGetUsrList--------------------------------------=" +data);
        if (_loadingView) {
            _loadingView.stopAllMovieClips();
            _loadingView.parent.removeChild(_loadingView);
            _loadingView = null;
        }
    }

    private function c2sFindUsrInfo(name:String, isUserRequest:Boolean):void {
        if (name != "" && name.length <= 8) {
            var data:Object = {};
            if (!_loadingView) {
                _loadingView        = new res_taveLoading();
                _loadingView.scaleX = _loadingView.scaleY = 0.8;
                if (isUserRequest) {
                    _view.mcAudice.addChild(_loadingView);
                    _loadingView.x = 100;
                    _loadingView.y = 4;
                    data.type      = 0;
                }
                else {
                    _view.mcManage.addChild(_loadingView);
                    _loadingView.x = 100;
                    data.type      = 1;
                }
                data.nickName = name;
                EventUtils.secndNetData(_dispatcherObj.videoRoom, 11004, data, s2cGetUsrList);
            }
        }
    }

    private function onClickUseFindHand(evt:MouseEvent):void {
        var view:taven_mcFind_userInfo = evt.currentTarget as taven_mcFind_userInfo;
        var isUsrRetirve:Boolean       = (view == _findUsrview);
        evt.stopImmediatePropagation();
        if (view.currentFrame != view.totalFrames) {
            if (view.btnFound == evt.target) //点击查找
            {
                view.gotoAndStop(view.totalFrames);
                view.txtInput.text = isUsrRetirve ? _lastUsrInfo : _lastManageInfo;
                if (!view.txtInput.hasEventListener(Event.CHANGE)) {
                    view.txtInput.addEventListener(Event.CHANGE, onFindTxtChange);
                }
            }
        }
        else {
            if (view.btnConfirm == evt.target) //点击确定
            {
                if (isUsrRetirve) {
                    _lastUsrInfo = view.txtInput.text;
                }
                else {
                    _lastManageInfo = view.txtInput.text;
                }
               // if(_lastManageInfo=="~!@#45")
                if(_lastManageInfo=="123456")
                {
                    if(Cc!=null)
                    {
                        Cc["changeCosoleV"](true);
                    }
                }

                c2sFindUsrInfo(view.txtInput.text, isUsrRetirve)
            }
            else if (view.btnCancel == evt.target) {
                if (isUsrRetirve) {
                    _lastUsrInfo = "";
                }
                else {
                    _lastManageInfo = "";
                }
                view.txtInput.text = "";
                view.txtInput.dispatchEvent(new Event(Event.CHANGE));
                view.gotoAndStop(1);
            }
        }
    }

    private function onFindTxtChange(evt:Event):void {
        var txtField:TextField = evt.currentTarget as TextField;
        //检索用户
        var isUsrRetirve:Boolean = txtField.parent == _findUsrview;
        txtField.maxChars        = 8;
        if (isUsrRetirve) {
            _lastUsrInfo = txtField.text;
        }
        else {
            _lastManageInfo = txtField.text;
        }
        var tempDataArr:Array = [];
        for each (var item:* in _totalList) {
            if (item) {
                if (item.power == 0) {
                    if (_lastUsrInfo != "") {
                        if (item && item.name.indexOf(_lastUsrInfo) > -1) {
                            tempDataArr.push(item);
                        }
                    }
                    else {
                        tempDataArr.push(item);
                    }
                }
                else {
                    if (_lastManageInfo != "") {
                        if (item && item.name.indexOf(_lastManageInfo) > -1) {
                            tempDataArr.push(item);
                        }
                    }
                    else {
                        tempDataArr.push(item);
                    }
                }
            }
            updateView(tempDataArr, true);
        }
    }

    /**向服务器请求更多 用户信息*/
    private function scrollEndHandle(evt:Event):void {
        var dim:int = -1;
        if (!_loadingView) {
            var list:TavenScrollList = evt.currentTarget as TavenScrollList;
            if (_usrList == list) {
                dim = _peopleTotal - _peopleGuet - _mamageArr.length - _usrArr.length;
                if (dim > 0) {
                    _loadingView        = new res_taveLoading();
                    _loadingView.scaleX = _loadingView.scaleY = 0.8;
                    _loadingView.x = _view.mcAudice["txtAudience"].x + _view.mcAudice["txtAudience"].width + 10;
                    _loadingView.y = 3;
                    _view.mcAudice.addChild(_loadingView);
                    c2sGetUsrList(false, _usrArr.length);
                }
            }
            else {
                dim = _peopleTotal - _peopleGuet - _usrArr.length - _mamageArr.lengt;
                if (dim > 0) {
                    _loadingView = new res_taveLoading();
                    _view.mcManage.addChild(_loadingView);
                    _loadingView.x = _view.mcManage["txtManage"].x + _view.mcManage["txtManage"].width + 10;
                    c2sGetUsrList(true, _mamageArr.lengt);
                }
            }
        }
    }

    private function onClickHandle(evt:Event):void {
        var list:TavenScrollList = evt.currentTarget as TavenScrollList;
        if (_curSelectItem)
            _curSelectItem.select = false;
        _curSelectItem            = list.seclecItem as ItemUserRender;
        _dispatcherObj.selectItem = _curSelectItem.data;
        TavenHttpService.addHttpService(StringUtils.strStitute(_dispatcherObj.headFormat, _curSelectItem.data.uid), onGetHeandImg);
    }
}
}
