/**
 * Created by taven on 2016/3/30.
 */
package display.ui {


import flash.display.Sprite;
import flash.events.MouseEvent;

public class TTabBar extends  Sprite {

    private var data:Array;
    private var itemList:Array;
    private var _lastSelectTab:TTab;
    private var _itemClickHandle:Function;
    private var _selectIndex:int;


    public function TTabBar(dataItems:Array, _clickHanlde=null, defaultIndex:int=-1) {
        data = dataItems;
        itemList =[];
        _itemClickHandle = _clickHanlde;
        addTab(dataItems)
        if(defaultIndex>-1)
        {
            selectIndex =defaultIndex;
        }
    }

    public function addTab(_arr:Array):void {
        for (var i:int = 0; i < _arr.length; i++) {
            var tab:TTab = new TTab(_arr[i]);
            tab.addEventListener(MouseEvent.CLICK, onClickHandle);
            this.addChild(tab);
            tab.index = i;
            itemList.push(tab);
        }
    }


    private function onClickHandle(event:MouseEvent):void {
        var tab:TTab = event.currentTarget as TTab;
        if(_lastSelectTab)
            _lastSelectTab.selected = false;
        _lastSelectTab = tab;
        _lastSelectTab.selected = true;
        if(_itemClickHandle!=null)
        {
            _itemClickHandle(tab.index);
        }
    }

    public function get selectIndex():int {
        return _selectIndex;
    }

    public function set selectIndex(value:int):void {
        if(!data||data.length<value)
        {
            return;
        }
        _selectIndex = value;
        if(_lastSelectTab)
            _lastSelectTab.selected = false;
        for each (var item:TTab in itemList)
        {
            if(item.index == value)
            {
                _lastSelectTab = item;
                _lastSelectTab.selected = true;
                break;
            }
        }
    }
}
}
