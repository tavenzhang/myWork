package taven.sideGroup {
import com.greensock.TweenLite;
import com.rover022.CBProtocol;
import com.rover022.ModuleNameType;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import taven.common.TavenScrollList;
import taven.enum.EventUtils;
import taven.sidesGroup;

public class DateListView {
    private const MAXLIST:int = 4;

    public function DateListView(_view:Lib_mcDataView, part:sidesGroup) {
        view = _view;
        view.visible = false;
        _dispatcherObj = part;
        _dataList = new TavenScrollList(DateListItemRender, 4, true);
        DateListItemRender.HTTP_SUFIX = _dispatcherObj.videoRoom.getDataByName(ModuleNameType.HTTPFUNCROOT) + "/member/doReservation?duroomid={0}&flag={1}";
        DateListItemRender.ALERT_FUN = _dispatcherObj.videoRoom.showAlert;
        DateListItemRender.DATE_SUC_FUN = c2sGetListData;
        view.mcSp.addChild(_dataList);
        view.btnClose.addEventListener(MouseEvent.CLICK, onHideHandle);
    }
    private var view:Lib_mcDataView;
    private var _dispatcherObj:sidesGroup;
    private var _dataList:TavenScrollList;
    private var _isAddStage:Boolean = false;

    public function updateList(data:Array):void {
        _dataList.dataList = data;
    }

    public function toggleView():void {
        if (!view.visible) {
            tweenVisible(view, true);
            c2sGetListData();
        }
        else {
            tweenVisible(view, false);
        }
    }

    public function c2sGetListData():void {
        var data:Object = {};
        //cmd:50005,type:4
        EventUtils.secndNetData(_dispatcherObj.videoRoom, CBProtocol.list_dateUsers_50005, data, s2cGetListData);
    }

    public function s2cGetListData(data:Object):void {
        //trace("s2cGetListData=" +data);
        var dataArr:Array = data.items;
        if (dataArr != null) {
            for each(var item:Object in dataArr) {
                if (item) {
                    item.type = data.type;
                }
            }
        }
        updateList(dataArr);
    }

    private function tweenVisible(view:DisplayObject, visibleStatue:Boolean):void {
        if (view.visible != visibleStatue) {
            if (!visibleStatue) {
                view.visible = visibleStatue;
            }
            else {
                if (!_isAddStage && view.stage) {
                    var point:Point = view.parent.localToGlobal(new Point(view.x, view.y));
                    view.stage.addChild(view);
                    view.x = point.x;
                    view.y = point.y;
                    _isAddStage = true;
                } else {
                    if (_isAddStage) {
                        view.stage.addChild(view);
                    }
                }
                view.visible = visibleStatue;
                view.alpha = 0;
                TweenLite.to(view, 0.5, {alpha: 1});
            }
        }
    }

    /*	返回:{cmd:50005,total:2,type:4,items:[{day:"2015-05-18",time:"17:40:",live_time:"25分钟",points:"500",reuid:111111,re_nickname:代收代付}..]}
     注：total表示总过设置预约数
     type:4(预约房间)
     points表示总共需要多少钻石
     reuid:0表示没有用户预约,>0表示预约用户uid号
     re_nickname:预约用户昵称*/

    private function onHideHandle(evt:Event):void {
        tweenVisible(view, false);
    }


}
}