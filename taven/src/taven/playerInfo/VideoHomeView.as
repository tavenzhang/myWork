package taven.playerInfo {
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.Dictionary;


import taven.PlayInfoModule;
import taven.enum.EventConst;
import taven.enum.EventUtils;
import taven.seatView.LoadMaterial;
import taven.utils.DisplayUtils;
import taven.utils.MathUtils;
import taven.utils.TweenHelp;

public class VideoHomeView {
    private var _view:tavn_videoHome;
    /**小编推荐*/
    private var _tjList:Array;
    /**热播*/
    private var _hotList:Array;

    private var _curPageTJ:int;

    private var _curPageHot:int;

    private const PAGE_SIZE:int = 8;

    private var _dataMap:Dictionary;

    private var _dispatcherObj:PlayInfoModule;


    public function VideoHomeView(view:tavn_videoHome, dispatcherObj:PlayInfoModule) {
        _view = view;
        _view.visible = false;
        _tjList = [];
        _hotList = [];
        _dataMap = new Dictionary(true);
        var item:tean_videoHome_itemRender;
        _dispatcherObj = dispatcherObj;
        for (var i:int = 1; i <= 8; i++) {
            item = _view["itemUp" + i];
            item.visible = false;
            item.mouseChildren = false;
            item.buttonMode = true;
            item.addEventListener(MouseEvent.CLICK, onItemClickHandle);
            //添加头像容器
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
        initUI();
        _view.addEventListener(MouseEvent.CLICK, onViewClick);
    }

    private function onViewClick(evt:MouseEvent):void {
        evt.stopImmediatePropagation();
        switch (evt.target) {
            case _view.btnClose:
                hideView();
                break;
            case _view.btnLeftUp:
                updataPage(_curPageTJ - 1, false);
                break;
            case _view.btnRightUp:
                updataPage(_curPageTJ + 1, false);
                break;
        }
    }

    private function onItemClickHandle(evt:Event):void {
        var item:MovieClip = evt.currentTarget as MovieClip;
        _dispatcherObj.selectItem = _dataMap[item.name];
        EventUtils.secndStatusEvent(_dispatcherObj, EventConst.PLAYER_VIDEO_ITEM);
        hideView();
    }

    private function hideView():void {
        TweenHelp.fade(_view, 0.1, 1, 0, function ():void {
            _view.visible = false
        });
    }

    /**
     * data ={headUrl:"http://192.168.10.230:8088/gift/gift_icon/100001.png",time:"12:20,name:"走着瞧是错",people:23,type:1}
     *headUrl人物头像,  time 精确到分 , name:主播名字 , people房间人数 ,type : 1表示小编推荐, 2:热播,3.即是小编推荐也是热播
     * */
    public function updataListView(dataList:Array):void {
        initUI();
        for (var i:int = 0; i < dataList.length; i++) {
            var item:Object = dataList[i];
            if (item.type == 1 || item.type == 3 || item.type==2 ) {
                _tjList.push(dataList[i]);
            }
//            if (item.type == 1 || item.type == 3 ) {
//                _tjList.push(dataList[i]);
//            }
//            else if (item.type == 2 || item.type == 3) {
//                _hotList.push(dataList[i]);
//            }
        }
        _curPageHot = 1;
        _curPageTJ = 1;
        updataPage(_curPageTJ, false);
       // updataPage(_curPageHot, true);
    }

    /**更新人数 单独的接口*/
    public function updateVideoInfos(data:Array):void {
        if (data && data.length > 0) {
            var arr:Array = _tjList.concat(_hotList);
            for each(var item:* in data) {
                for each(var obj:Object in arr) {
                    if (item.roomid == obj.roomid) {
                        obj.people = item.people;
                    }
                }
            }
            updataPage(_curPageTJ, false);
          //  updataPage(_curPageHot, true);
        }
    }

    private function updataPage(pageId:int, isHot:Boolean):void {
        var length:int = 0;
        var resutArr:Array;
        var data:Array = isHot ? _hotList : _tjList;
        var maxPage:int = Math.ceil(data.length / PAGE_SIZE);
        var item:tean_videoHome_itemRender;
        pageId = MathUtils.clamp(pageId, 1, maxPage);

        length = data.length - (pageId - 1) * PAGE_SIZE;
        length = length > PAGE_SIZE ? PAGE_SIZE : length;
        _curPageHot = pageId;
        resutArr = data.slice((pageId - 1) * PAGE_SIZE, ((pageId - 1) * PAGE_SIZE) + length);
        // data =[{headUrl:"http://192.168.10.230:8088/gift/gift_icon/100001.png",time:"12:20,name:"走着瞧是错",people:23,type:1}]
        //headUrl人物头像,  time 精确到分 , name:主播名字 , people房间人数 ,type : 1表示小编推荐, 2:热播,3.即是小编推荐也是热播
        if (isHot) {
//            _curPageHot = pageId;
//            DisplayUtils.enableButton(_view.btnLeftDown, _curPageHot > 1);
//            DisplayUtils.enableButton(_view.btnRightDown, _curPageHot < maxPage);
//            for (var i:int = 1; i <= 4; i++) {
//                item = _view["itemDown" + i] as tean_videoHome_itemRender;
//                item.mcPlayer.visible =  item.txtPeopleNum.visible=false;
//                if (resutArr[i - 1]) {
//                    item.visible = true;
//                    item.txtName.text = resutArr[i - 1].name;
//                    item.txtPeopleNum.text = resutArr[i - 1].people.toString();
//                    item.txtTime.text = String(resutArr[i - 1].time);
//                    if ((item as MovieClip).url != resutArr[i - 1].headUrl) {
//                        (_dataMap[item] as LoadMaterial).load(resutArr[i - 1].headUrl);
//                        (item as MovieClip).url = resutArr[i - 1].headUrl;
//                        //trace("videoHome LoadMaterial =" + resutArr[i - 1].headUrl);
//                    }
//
//                    _dataMap[item.name] = resutArr[i - 1];
//
//                }
//                else {
//                    item.visible = false;
//                    _dataMap[item.name] = null;
//                }
//            }
        }
        else {
            _curPageTJ = pageId;
            DisplayUtils.enableButton(_view.btnLeftUp, _curPageTJ > 1);
            DisplayUtils.enableButton(_view.btnRightUp, _curPageTJ < maxPage);
            for (var i:int = 1; i <= 8; i++) {
                item = _view["itemUp" + i] as tean_videoHome_itemRender;
                item.mcPlayer.visible =  item.txtPeopleNum.visible=false;
                if (resutArr[i - 1]) {
                    item.visible = true;
                    item.txtName.text = resutArr[i - 1].name;
                    item.txtPeopleNum.text = resutArr[i - 1].people.toString();
                    item.txtTime.text = String(resutArr[i - 1].time);

                    if ((item as MovieClip) != resutArr[i - 1].headUrl) {
                        (_dataMap[item] as LoadMaterial).load(resutArr[i - 1].headUrl, true);
                        (item as MovieClip).url = resutArr[i - 1].headUrl;
                        //trace("videoHome LoadMaterial =" + resutArr[i - 1].headUrl);
                    }


                    _dataMap[item.name] = resutArr[i - 1];
                }
                else {
                    item.visible = false;
                    _dataMap[item.name] = null;
                }
            }
        }
    }



    private function initUI():void {
        _tjList.length = 0;
        _hotList.length = 0;
        DisplayUtils.enableButton(_view.btnLeftUp, false);
        DisplayUtils.enableButton(_view.btnRightUp,false);
    }
}
}
