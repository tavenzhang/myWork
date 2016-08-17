package taven {
import display.BaseModule;

import flash.display.Sprite;
import flash.events.StatusEvent;

import taven.common.TavenScrollList;
import taven.enum.EventUtils;
import taven.rankView.RankGiftRender;
import taven.rankView.RankItemRender;

public class RankGiftModule extends BaseModule {
    /**点击时 数据*/
    public var selectItem:Object;
    /**list 容器 */
    private var _rankListContainer:Sprite;
    private var _scrollBar:TavenScrollList;
    /**list 数据源  {time:"19:23",name:"走路闷骚会闪耀",count:169536,ico:"1.jpg"} */
    private var _data:Array;
    private var _maxWidth:Number = 0;
    private var _maxHeight:Number = 0;
    private var _count:int = 0;

    public function RankGiftModule() {
        _rankListContainer = new Sprite();
        _rankListContainer.removeChildren();
        _scrollBar = new TavenScrollList(RankGiftRender);
        _rankListContainer.addChild(_scrollBar);
        this.addChild(_rankListContainer);
    }

    public function selectItemChange(evt:StatusEvent):void {
        for each (var item:RankGiftRender in _scrollBar.itemList) {
            if (item.data && item.data.name == evt.code) {
                selectItem = item.data;
                EventUtils.secndStatusEvent(this, evt.code);
                break;
            }
        }
    }

    override public function get width():Number {
        return _maxWidth;
    }

    override public function set width(value:Number):void {
        if (_maxWidth != value) {
            if (_scrollBar.itemList.length > 0) {
                for each (var item:RankItemRender in _scrollBar.itemList) {
                    if (item) {
                        item.adujustSize(value);
                    }
                }
            }
        }
        _maxWidth = value;
    }

    override public function get height():Number {
        return _maxHeight;
    }

    override public function set height(value:Number):void {
        if (_maxHeight != value) {

            //if (_scrollBar.itemList.length > 0)
            //{
            _scrollBar.updateMaxCountByHeight(value);
            //}
        }
        _maxHeight = value;
    }

    /**整体刷新 ui*/
    private function updateView(maxWidth:Number, maxHeight:Number):void {
        if (_data && _data.length > 0) {
            //{time:123342,name:"走路闷骚会闪耀",count:169536,ico:"1.jpg"} 数据demo
            var tempRender:RankGiftRender;
            if (maxWidth > 0 && maxWidth != RankGiftRender.FORCRE_WIDTH) {
                RankGiftRender.FORCRE_WIDTH = maxWidth;
            }
            _scrollBar.dataList = _data;
            maxHeight           = (maxHeight == 0) ? 150 : maxHeight;
            _scrollBar.updateMaxCountByHeight(maxHeight);
            for (var i:int = 0; i < _scrollBar.itemList.length; i++) {
                _data[i].rank = i + 1;
                tempRender    = _scrollBar.itemList[i] as RankGiftRender;
                if (!tempRender.hasEventListener(StatusEvent.STATUS)) {
                    tempRender.addEventListener(StatusEvent.STATUS, selectItemChange);
                }
            }
            if (maxWidth > 0 && _scrollBar.itemList.length > 0) {
                _scrollBar.flushListView(_scrollBar.itemList[0].width);
            }
        }
    }

    /**设置数据接口*/
    public function updateData(dataArr:Array, isDelete:Boolean = false):void {
        dataArr              = ( dataArr == null) ? [] : dataArr;
        var isChange:Boolean = false;
        if (isDelete) //删除元素
        {
            for (var i:int = 0; i < dataArr.length; i++) {
                for each (var item:Object in _data) {
                    if (item.uid == dataArr[i].uid) {
                        _data.splice(_data.indexOf(item), 1);
                        isChange = true;
                        break;
                    }
                }
            }
        } else {
            if (!_data) {
                _data    = dataArr;
                isChange = true;
            } else {
                for (i = 0; i < dataArr.length; i++) {
                    if (_data.length >= 30) {
                        _data.pop();
                    }
                    _data.unshift(dataArr[i]); //新加入到礼物信息 放在最前面 显示
                    isChange = true;
                }
            }
        }
        if (isChange) {
            updateView(_maxWidth, _maxHeight);
        }
    }
}
}
