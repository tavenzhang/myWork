/**
 * Created by Taven on 2015/9/29.
 */
package taven {
import com.rover022.CBProtocol;

import display.BaseModule;
import display.ui.TTabBar;

import flash.display.MovieClip;
import flash.events.Event;

import manger.DataCenterManger;

import taven.common.TavenScrollList;
import taven.enum.EventUtils;
import taven.playerInfo.ItemUserRender;

import tool.FormatDataTool;

public class RankVipModule extends BaseModule {
    /** 当前点击的item数据*/
    public var selectItem:Object;
    private var _vipList:TavenScrollList;
    private var _mamageArr:Array = [];
    private var _usrArr:Array = [];
    private var _totalArr:Array = [];
    private var _maxWidth:Number = 0;
    private var _maxHeight:Number = 0;

    private var _view:tave_vipSeatView;
    private var _totalVip:int = 0;
    private var _loadIngMc:MovieClip;
    private var _tabBar:TTabBar;
    private var _managList:TavenScrollList;
    private var _usrList:TavenScrollList;
    private  var totalUsrs:int=0;
    private  var totalManage:int=0;
    public function RankVipModule() {
        _usrList = new TavenScrollList(ItemUserRender, 6);
        _managList = new TavenScrollList(ItemUserRender, 6);
        _view = new tave_vipSeatView();
        this.addChild(_view);
        this.addChild(_usrList);
        this.addChild(_managList);
        _managList.x=_usrList.x=20;
        _managList.y=_usrList.y=40;
        _managList.addEventListener(TavenScrollList.SCROLL_END, scrollEndHandle);
        _usrList.addEventListener(TavenScrollList.SCROLL_END, scrollEndHandle);
        _loadIngMc = new taven_dataKLoading();
        _view.addChild(_loadIngMc);
        _loadIngMc.x = _view.btnVipOpen.x + 90;
        _loadIngMc.y = _view.btnVipOpen.y - 30;
        _view.btnVipOpen.visible =false;
        _loadIngMc.width = _loadIngMc.height = 24;
        showLoading(false);
        _view.menuBtn1.txtName.text = "观众";
        _view.menuBtn2.txtName.text = "管理员";
        _tabBar = new TTabBar([_view.menuBtn1, _view.menuBtn2], onTabChange, 0);
        this.addChild(_tabBar);
        dragBg(width, height);
    }



    private function onTabChange(index:int):void {
        if (index == 0) {
            c2sGetUsrList(false, 0);
            _managList.visible = false;
            _usrList.visible = !_managList.visible;
        }
        else {
            c2sGetUsrList(true, 0);
            _managList.visible = true;
            _usrList.visible = !_managList.visible;
        }
    }

    private function c2sGetUsrList(isManage:Boolean, startIndex:int = 0):void {
        if (isManage) {
            EventUtils.secndNetDataNew(11008, {}, handMessage);
        }
        else {
            var data:Object = {};
            data.start = startIndex;
            data.end = startIndex + 20;
            EventUtils.secndNetDataNew(11001, data, handMessage);
        }
    }


    override protected function initListeners():void {
      //  onTabChange(0);
    }


    //ui 消息处理
    override public function handMessage(data:*):void {
        trace("handMessage===" + handMessage);
        switch (data.cmd) {
            case CBProtocol.onEnterRoom://玩家进入
                updataDataList([FormatDataTool.userData(data)]);
                break;
            case CBProtocol.listUser://玩家列表
                updataDataList(FormatDataTool.userDataArray(data.items));
                break;
            case CBProtocol.onOutRoom://玩家退出;
                updataDataList([FormatDataTool.userData(data)],true);
                break;
            case CBProtocol.addManger://添加管理员
                updataDataList([FormatDataTool.userData(data)]);
                break;
            case CBProtocol.removeManger://删除 管理员
                updataDataList([FormatDataTool.userData(data)],false);
                break;
            case CBProtocol.listManger:////列表 管理员
                updataDataList(FormatDataTool.userDataArray(data.items));
                break;
            case CBProtocol.onGetMoreUserInfor://查询获取更多用户
                updataDataList(FormatDataTool.userDataArray(data.items));
                break;
            case CBProtocol.login:
                onTabChange(1);
                onTabChange(0);
                break;
            case CBProtocol.userListNum_50007:
                totalUsrs = (data.guests+data.players);
                totalManage = data.managers;
               // <--50007 {"total":11,"cmd":50007,"users":11,"managers":2,"guests":0,"players":9}  貌似感觉可以
                _view.menuBtn1.txtName.text = "观众" + "(" + (totalUsrs*DataCenterManger.vipInfo.userTimes).toString() + ")";
                _view.menuBtn2.txtName.text = "管理员" + "(" + totalManage.toString() + ")";
                break;
            case CBProtocol.onEnterRoom_VIP_10013:
                _view.menuBtn1.txtName.text = " 观众" + "(" + (totalUsrs*DataCenterManger.vipInfo.userTimes).toString() + ")";
                _view.menuBtn2.txtName.text =  "管理员" + "(" + totalManage.toString() + ")";
                break;

        }
    }



    private function showLoading(visible:Boolean) {
        _loadIngMc.visible = visible;
        if (visible) {
            _loadIngMc.stop();
        }
        else {
            _loadIngMc.play();
        }
    }

    private function dragBg(width:Number, heigh:Number):void {
        this.graphics.clear();
        this.graphics.beginFill(0x000000, 0.7);
        var h:Number = _tabBar.height;
        this.graphics.drawRoundRectComplex(-4, -4, _tabBar.width + 16, (heigh + h), 0, 0, 5, 5);
        this.graphics.endFill();
    }

    /**向服务器请求更多 用户信息*/
    private function scrollEndHandle(evt:Event):void {

        if (evt.currentTarget == _usrList) {
            c2sGetUsrList(false, _usrArr.length);
        }
        else {
            c2sGetUsrList(true, _mamageArr.length);
        }
    }


    private var _totalList:Array;

    /**更新用户列表显示*/
    private function updataDataList(changeArr:Array, isDelete:Boolean = false):void {
        var isChange:Boolean = false;

        if (isDelete) {
            if (_totalArr && _totalArr.length > 0) {
                for (var i:int = 0; i < changeArr.length; i++) {
                    for each(var item:Object in _totalArr) {
                        if (item.uid == changeArr[i].uid) {
                            _totalArr.splice(_totalArr.indexOf(item), 1);
                            isChange = true;
                            break;
                        }
                    }
                }
            }
        }
        else {
            var dataList:Array=[];
            for each(var item:* in changeArr)
            {
                if(item&&item.ruled>-1)
                {
                    dataList.push(item);
                }
                else
                {
                   // trace("--item.ruled<=-1--"+item.name);
                }
            }
            if(dataList.length<=0)
                return;
            if (_totalArr.length==0) {
                _totalArr   = dataList ;
                isChange = true;
            }
            else {
                var isNew:Boolean = true;
                for (i = 0; i < dataList.length; i++) {
                    isNew = true;
                    for each (var item2:Object in _totalArr) {
                        if (item2.uid == dataList[i].uid) {
                            isNew                         = false;
                            _totalArr[_totalArr.indexOf(item2)] = dataList[i];
                            isChange                      = true;
                            break;
                        }
                    }
                    if (isNew) {
                        _totalArr.push(dataList[i]);
                        isChange = true;
                    }
                }
            }
        }
        if (isChange) {
              updateView(_totalArr);
        }
    }

    public function updateView(playList:Array):void {
        _usrArr.length = 0;
        _mamageArr.length = 0;
//        var itemHeight:Number = 0;
//        var itemWidth:Number = 0;
        if (playList && playList.length > 0) {
            var tempArr:Array;
            for each (var item:Object in playList) {
                if (item.hidden == 0 ) {
                    tempArr = item.power == 0 ? _usrArr : _mamageArr;
                    tempArr.push(item);
                }
            }
        }
        _usrArr.sortOn("level", Array.NUMERIC | Array.DESCENDING);
        _mamageArr.sort(sortFuc);
        _usrArr.sort(sortUserFuc);
        _usrList.dataList = _usrArr;
        _managList.dataList = _mamageArr;
    }

    private function sortUserFuc(a:Object, b:Object):int {
        var resutlt:int = 0;
        if(a.vip>b.vip)
        {
            resutlt=-1;
        }
        else if(a.vip<b.vip){
            resutlt=1;
        }
        else{
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

    private var _curSelectItem:ItemUserRender;

    private function onClickHandle(evt:Event):void {
        var list:TavenScrollList = evt.currentTarget as TavenScrollList;
        if (_curSelectItem)
            _curSelectItem.select = false;
        _curSelectItem = list.seclecItem as ItemUserRender;
        //   _dispatcherObj.selectItem = _curSelectItem.data;
        //  TavenHttpService.addHttpService(StringUtils.strStitute(_dispatcherObj.headFormat, _curSelectItem.data.uid), onGetHeandImg);
    }

    /**--------------------------------------------------------------------------公共接口-----------------------------------------------------------------------------------------------------------*/
    override public function get width():Number {
        return _maxWidth;
    }

    override public function set width(value:Number):void {
        if (_maxWidth != value) {
            _maxWidth = value;
            dragBg(width, height);
        }

    }

    override public function get height():Number {
        return _maxHeight;
    }

    override public function set height(value:Number):void {
        if (_maxHeight != value) {
            // var h:Number = value - _view.height - 10;
            _maxHeight = value;
            _usrList.updateMaxCountByHeight(_maxHeight);
            _managList.updateMaxCountByHeight(_maxHeight);
            dragBg(width, height);
        }
        //  _tabBar.y=_view.y    = _maxHeight - _view.height - 5;
        // _view.mcLine.width = _maxWidth;

    }


}
}
