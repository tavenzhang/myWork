package taven {
import com.rover022.vo.UserVo;

import display.BaseModule;
import display.ui.CBScrollPanel;

import flash.display.Bitmap;

import taven.common.TavenScrollList;
import taven.playerInfo.ItemRenerManage;

import taven.rankView.RankItemRender;
import taven.utils.ObjectPool;

public class RankViewModule extends BaseModule {
    /** 当前点击的item数据*/
    public var selectItem:Object;
    /**list 数据源  {rank:2,name:"走路闷骚会闪耀",money:169536},{rank:3,name:"累无爱",money:120588} */
    private var _dataArr:Array;
    private var _maxWidth:Number              = 0;
    private var _maxHeight:Number             = 0;
    private var _totalView:taven_item_total;
    private var _rankList:TavenScrollList  = new TavenScrollList(RankItemRender, 4);
    public function RankViewModule() {
        _totalView = new taven_item_total();
        this.addChild(_totalView);
        _totalView.visible = false;
        this.addChild(_rankList);
        _rankList.x=30;
        _rankList.adjustScrollPost(10);
        _totalView.x =35;
    }


    /**--------------------------------------------------------------------------公共接口-----------------------------------------------------------------------------------------------------------*/
    override public function get width():Number {
        return _maxWidth;
    }

    override public function set width(value:Number):void {
        _maxWidth = value;
    }

    override public function get height():Number {
        return _maxHeight;
    }

    override public function set height(value:Number):void {
        _maxHeight              = value;
        _totalView.y            = _maxHeight - _totalView.height -10;
        _totalView.mcLine.width = _maxWidth-10;
        _totalView.mcLine.visible = false;
        _rankList.updateMaxCountByHeight(_maxHeight);
        //
    }

    /**整体刷新 ui*/


    public function updateTotal(num:int, isWeek:Boolean):void {
        //_totalView.txtName.text=isWeek ? "周贡献统计":"共计礼物";
        _totalView.txtName.text = "共计礼物: ";
        _totalView.txtNum.text  = num.toString() + " 钻";
        _totalView.visible      = num > 0;
        // _totalView.visible = false;
    }

    /**设置数据接口*/
    public function updateData(dataArr:Array, isDelete:Boolean = false, flushAll:Boolean = false):void {
        if (dataArr == null) {
            return;
        }
        if (_dataArr) {
            for (var i:uint = 0; i < dataArr.length; i++) {
                var _object:Object   = dataArr[i];
                var _canPush:Boolean = true;
                for (var j:int = 0; j < _dataArr.length; j++) {
                    if ( _dataArr[j].uid == _object.uid) {
                        _dataArr[j] = _object;
                        _canPush = false;
                        break;
                    }
                }
                if (_canPush) {
                    _dataArr.push(_object);
                }
            }
        } else {
            _dataArr = dataArr;
        }
        if (_dataArr) {
            _dataArr.sortOn("money", Array.NUMERIC | Array.DESCENDING); //排序一下  根据贡献值

            for (i = 0; i < _dataArr.length; i++) {
                _dataArr[i].rank = i + 1;
                _rankList.dataList = _dataArr;
            }

        }
    }
}
}
