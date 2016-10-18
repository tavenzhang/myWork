/**
 * Created by ws on 2015/6/17.
 */
package taven.playerInfo {
import com.rover022.CBProtocol;
import display.BaseModule;

import flash.display.DisplayObject;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.clearInterval;
import flash.utils.setInterval;
import flash.utils.setTimeout;


import taven.enum.EventUtils;
import taven.utils.StringUtils;
import taven.utils.TimeUtils;

public class RankStartView extends taven_starViewRank{
    private var _baseModule:BaseModule;
    private var _timeId:uint;
    private var _timeCount:int;
    private  var _isSending:Boolean=false;
    private var _oneDataSecond:int =24*60*60;
    private var _btnBg:DisplayObject;

    public function RankStartView(baseModue:BaseModule, bgbtn:DisplayObject) {
        this.btnClose.addEventListener(MouseEvent.CLICK, onCloseClick);
        _baseModule = baseModue;
        _btnBg =bgbtn;
        _btnBg.visible=false;
        resetView();
        this.visible =false;
    }

    private  function  onCloseClick(evt:Event):void
    {
        visible = false;
    }

    private function  resetView():void
    {
        for (var i:int=1;i<=5;i++)
        {
            var itemView:Taven_startItem;
            itemView = this["itemStar"+i];
            setItemData(itemView,null);
            itemView = this["itemZun"+i];
            setItemData(itemView,null);
        }
        this.txtTime.text = StringUtils.strStitute("距离结束时间:{0}","");
    }

    private  function setItemData(view:Taven_startItem,data:*,rank:int=1):void
    {
        //返回：{"cmd":15004,"time":"1天两小时30分钟","items":[{"nickname":"aaa","score":888,type:1},{"nickname":"aaa","score":888,type:2}]}
        // 其中type=1代表魅力排行 type=2代表至尊排行
        if(data==null)
        {
            view.visible =false;
            view.txtRanking.text = "0";
            view.txtMoney.text="0";
            view.txtName.text ="";
            view.rackBg.gotoAndStop(1);
        }
        else
        {
            view.visible =true;
            view.txtRanking.text = "0"+rank;
            view.txtMoney.text=data.score.toString();
            view.txtName.text =data.nickname;
            view.txtName.textColor = rank==1 ? 0xf6ff00:0xffffff;
            view.rackBg.gotoAndStop(rank>=4 ? 4:rank);
        }
    }
    override public function set visible(value:Boolean):void
    {
        super.visible = value;
        if(this.parent&&visible)
        {
            this.parent.addChildAt(this,this.parent.numChildren-1);
            if(!_isSending)
                c2sGetListData();
        }
        _btnBg.visible= super.visible;
    }



    public function c2sGetListData():void {
        var data:Object = {};
        /**获取魅力之星排行 */
            //  public static const list_start_15004:int = 15004;
        EventUtils.secndNetData(_baseModule.videoRoom, CBProtocol.list_start_15004, data, s2cGetListData);
        _isSending =true;
        setTimeout(function():void{ _isSending =false;},3000);
        //var tt:*=JSON.parse({"cmd":15004,"time":111,"items":[{"心中试试啊啊":"aaa","score":888,type:1},{"nickname":"aaa","score":888,type:2}]});
        //var data2:Object = new Object();
        // data2.time =_oneDataSecond*12;
        //  s2cGetListData(data2);
    }

    public function s2cGetListData(data:Object):void {
        //trace("s2cGetListData=" +data);
        _isSending =false;
        var startArr:Array =[];
        var zunArr:Array =[];
        if(data.items)
        {
            for (var i:int=0;i<data.items.length;i++)
            {
                if(data.items[i].type==1)
                {
                    startArr.push(data.items[i]);
                }
                else
                {
                    zunArr.push(data.items[i]);
                }
            }
        }

        for ( i=1;i<=5;i++)
        {
            var itemView:Taven_startItem;
            itemView = this["itemStar"+i];
            setItemData(itemView,startArr[i-1],i);
            itemView = this["itemZun"+i];
            setItemData(itemView,zunArr[i-1],i);
        }
        _timeCount =  data.time;
        // if(_timeCount>=0)
        // {
        clearInterval(_timeId);
        _timeId =setInterval(flushTime,1000);
        flushTime();
        // }
        // updateList(dataArr);
    }

    private function  flushTime():void
    {
        if(_timeCount>0)
        {
            if(_timeCount>_oneDataSecond)
            {
                var day:int = _timeCount/_oneDataSecond;
                var second:int = _timeCount - _oneDataSecond*day;
                this.txtTime.text = StringUtils.strStitute("距离结束时间:{0}天 {1}",day, TimeUtils.getTimeString(second));
            }
            else
            {
                this.txtTime.text = StringUtils.strStitute("距离结束时间:{0}", TimeUtils.getTimeString(_timeCount));
            }
            _timeCount--;
        }
        else
        {
            this.txtTime.text = "结束时间已到！";
        }

    }
}
}
