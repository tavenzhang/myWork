/**
 * Created by Taven on 2015/9/29.
 */
package taven.rankView {
import com.rover022.display.UserIconMovieClip;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.StatusEvent;
import flash.text.StyleSheet;
import flash.text.TextField;

import taven.common.IListItem;


public class RankVipRender extends taven_vipItemRender  implements IListItem{

    public var _txtName:TextField;
    private var _txtRank:TextField;
    private var icoMc:UserIconMovieClip;


    private var _mcLine:DisplayObject; //底部下划线


    private var _data:*;
    /**静态共享变量*/
    private static var MIX_WIDTH:Number=0;
    /**静态共享变量*/
    private static var CSS_STYPE_SHEET:StyleSheet;

    /**原始宽度*/
    private var _reWidth:Number;

    private var _select:Boolean;

    /**静态共享变量*/
    public static var FORCRE_WIDTH:Number=0;

    private var _forceWith:Number=0;

    public function RankVipRender() {
        _txtName=this.txtName;
        _txtRank=this.txtRanking;
        _mcLine=this.mcLine;
        mcIco.removeChildren();
        icoMc = new UserIconMovieClip(this.mcIco, 0, 18);
        icoMc.scaleX = icoMc.scaleY = 1.1;

        if (MIX_WIDTH == 0)
            MIX_WIDTH=_txtName.width + _txtRank.width + mcIco.width; //显示需要的最小宽度
        if (CSS_STYPE_SHEET == null)
        {
            CSS_STYPE_SHEET=new StyleSheet();
            CSS_STYPE_SHEET.parseCSS("a:hover{textDecoration:underline}");
        }
        _reWidth = this.width;
        _txtName.styleSheet=CSS_STYPE_SHEET;
        _txtName.addEventListener(MouseEvent.CLICK, onLickEvent);
    }

    //点击之后通知住程序
    private function onLickEvent(evt:Event):void
    {
        evt.stopImmediatePropagation(); //禁止冒泡
        var event:StatusEvent = new StatusEvent(StatusEvent.STATUS,false,false,_data.name);
        this.dispatchEvent(event);
    }

    public function set data(value:*):void
    {
        _data = value;
        if (_data == null)
        {
            _txtName.text="数据错误null";
        }
        else
        {
            _txtRank.text=_data.rank.toString();
            if (_txtRank.text.length < 2)
            {
                _txtRank.text="0" + _txtRank.text;
            }
            _txtName.htmlText='<a href="com.rover022.event:' + _data.rank + '">' + _data.name + '</a>';
            switch (_txtRank.text)
            {
                case "01":
                    rackBg.gotoAndStop(1);
                    _txtName.textColor=0xF6FF00;
                    break;
                case "02":
                    rackBg.gotoAndStop(2);
                    break;
                case "03":
                    rackBg.gotoAndStop(3);
                    break;
                default:
                    rackBg.gotoAndStop(4);
                    break;
            }
            icoMc.showVipIconByVipID(_data.vip);
        }
        if(_forceWith!=FORCRE_WIDTH&&FORCRE_WIDTH>0)
        {
            adujustSize(FORCRE_WIDTH);
        }
    }


    public function adujustSize(wide:Number=0):void
    {
        if(_forceWith!=wide&&wide>0)
        {
            _forceWith =wide;
            if (wide >= MIX_WIDTH) //如果尺寸大于最小尺寸 动态调整位置
            {
                //this.width=wide;
                _txtName.x=_txtRank.x + _txtRank.width +  ((wide - MIX_WIDTH)/3)*3 +20;
                _mcLine.width=wide-4;
                //_mcMoney.scaleX=_reWidth/wide;
            }
            else  //如果设定尺寸小于最小限定尺寸，等比例缩放
            {
                var scale:Number=wide/this.width;
                this.scaleY=scale;
            }
        }
    }

    public function get data():* {
        return _data;
    }

    public function get view():DisplayObject {
        return this;
    }

    public function get select():Boolean {
        return _select;
    }

    public function set select(value:Boolean):void {
        _select = value;
    }

    override public function get width():Number
    {
        return _mcLine.width;
    }
}
}
