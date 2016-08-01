/**
 * Created by Taven on 2015/8/22.
 */
package taven.sideGroup {
import com.greensock.TweenLite;
import com.greensock.easing.Expo;
import com.rover022.IVideoRoom;
import com.rover022.ModuleNameType;

import flash.events.Event;

import flash.events.MouseEvent;
import flash.events.StatusEvent;

import taven.utils.ObjectPool;

import tool.JsHelp;


public class GiftCircleView {
    private var  _view:taven_mcCurcle;
    private var _videoRomm:IVideoRoom ;
    private var _waitList:Array;
    private var _firstItem:ItemGiftCircle;
    private var _secondItem:ItemGiftCircle
    private var itemPool:ObjectPool;
    private var _isMoving:Boolean=false;
    public function GiftCircleView(view:taven_mcCurcle,roomI:IVideoRoom) {
        _view = view;
        _videoRomm = roomI;
        _waitList =[];
        _view.visible =false;
        itemPool= new ObjectPool(ItemGiftCircle);
        _isMoving =false;
        _view.mcGiftInfo.buttonMode=true;
        _view.btnUpCircele.addEventListener(MouseEvent.CLICK, onClick);
        _view.addEventListener(MouseEvent.ROLL_OVER,onRollHanle);
        _view.addEventListener(MouseEvent.ROLL_OUT,onRollHanle);
        _view.btnUpCircele.visible = false;
    }


    private  function  onClick(evt:Event):void
    {
        try {
            _videoRomm["gift_Module"].selectIndex = 4;
        } catch (e:Error) {
        }
    }


    private function onRollHanle(evt:MouseEvent):void
    {
        if(evt.type ==MouseEvent.ROLL_OVER)
        {
            _view.btnUpCircele.visible = true;
        }
        else
        {
            _view.btnUpCircele.visible = false;
        }
    }
    private function onStatueHanlde():void
    {
        trace("onStatueHanlde");
        if(_firstItem)
        {
            var roomid:int =_firstItem.date.roomid;
            var hostId:int= _videoRomm.getDataByName(ModuleNameType.USERROOMDATA).roomid;
            if(roomid!=hostId)
            {
                JsHelp.gotoRoom(roomid);
            }
            else
            {
                _videoRomm.showAlert("您当前正在此房间！");
            }
        }
    }

    public function onMessAdd(data:Object):void
    {
        _waitList.push(data);
        nextMsg();
    }
    public function nextMsg():void
    {
        if( _isMoving )
        {
            return;
        }
            if(!_firstItem)
            {
                if(_waitList.length>0)
                {
                    _view.visible =true;
                    _firstItem =itemPool.fetch() as ItemGiftCircle;
                    _firstItem.addCallBack(onStatueHanlde);
                    _firstItem.date =_waitList.shift();
                    _firstItem.y=0;
                    _view.mcGiftInfo.addChild(_firstItem);
                    _view.mcGiftInfo.x = (_view.width - _view.mcGiftInfo.width)/2;
                 //   _view.btnUpCircele.x =  _view.mcGiftInfo.x+  _view.mcGiftInfo.width+5;
                }
                else
                    _view.visible =false;
            }
            else
            {
                if(_waitList.length>0)
                {
                    _secondItem = itemPool.fetch() as ItemGiftCircle;
                    _secondItem.date=_waitList.shift();
                    _view.mcGiftInfo.addChild(_secondItem);
                    _secondItem.addCallBack(onStatueHanlde);
                    _secondItem.y =_firstItem.y+_firstItem.height;
                    _isMoving =true;
                    TweenLite.to(_firstItem, 1, {y:-_firstItem.height, ease: Expo.easeInOut, onUpdate: function():void {
                        _secondItem.y =_firstItem.y+_firstItem.height;
                    },onComplete: function():void
                    {
                        itemPool.recycle(_firstItem);
                        _firstItem =_secondItem;
                        _secondItem=null;
                        _firstItem.y=0;
                        _isMoving =false;
                        _view.mcGiftInfo.x = (_view.width - _view.mcGiftInfo.width)/2;
                        //_view.btnUpCircele.x =  _view.mcGiftInfo.x+  _view.mcGiftInfo.width+20;
                        if(_waitList.length>0)
                        {
                            nextMsg();
                        }
                    }})
                }
            }
        }

}
}
