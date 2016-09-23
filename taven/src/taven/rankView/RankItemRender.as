package taven.rankView {
import com.rover022.event.CBModuleEvent;
import com.rover022.vo.UserVo;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.StatusEvent;
import flash.text.StyleSheet;
import flash.text.TextField;

import manger.ClientManger;

import taven.common.IListItem;

import tool.FormatDataTool;
import tool.VideoTool;

public class RankItemRender extends tave_rankItemRender implements IListItem {
    public var _txtName:TextField;
    private var _txtRank:TextField;
    private var _txtCost:TextField;
    private var _mcLine:DisplayObject; //底部下划线
    private var _mcMoney:DisplayObject; //金币显示选项
    private var _data:*;
    private static var MIX_WIDTH:Number   = 0;
    private static var CSS_STYPE_SHEET:StyleSheet;
    private var _reWidth:Number;
    private var _select:Boolean;
    public static var FORCRE_WIDTH:Number = 0;
    private var _forceWith:Number         = 0;

    public function RankItemRender() {
        _txtName      = this.txtName;
        _txtRank      = this.txtRanking;
        _txtCost      = this.mcMoney.txtDesc;
        _mcMoney      = this.mcMoney;
        _mcLine       = this.mcLine;
        _mcLine.width = 270;
        if (MIX_WIDTH == 0)
            MIX_WIDTH = _txtName.width + _txtRank.width + _txtCost.width; //显示需要的最小宽度
        if (CSS_STYPE_SHEET == null) {
            CSS_STYPE_SHEET = new StyleSheet();
            CSS_STYPE_SHEET.parseCSS("a:hover{textDecoration:underline}");
        }
        _reWidth            = this.width;
        _txtName.styleSheet = CSS_STYPE_SHEET;
        initUI();
        //<a href="http://en.wikipedia.org/wiki/HTML" target="_blank">
    }

    public function setUserVo(src:UserVo):void {
        _txtName.htmlText = '<a href="com.rover022.event:' + src.rank + '">' + FormatDataTool.getNickeName(src) + '</a>';
        _txtCost.text     = src.money.toString();
        rackBg.gotoAndStop(src.rank + 1);
        _mcMoney.x = 170;
        _data      = src;
    }

    public function setIndex(src:int):void {
        if (src < 9) {
            _txtRank.text = "0" + (src + 1);
        } else {
            _txtRank.text = (src + 1).toString();
        }
    }

    //点击之后通知住程序
    private function onLickEvent(evt:Event):void {
//        evt.stopImmediatePropagation(); //禁止冒泡
//        var com.rover022.event:StatusEvent = new StatusEvent(StatusEvent.STATUS, false, false, _data.name);
//        this.dispatchEvent(com.rover022.event);
        var event:CBModuleEvent = new CBModuleEvent(CBModuleEvent.PLAYNAMELINK, true);
        var usrVo:UserVo = new UserVo(_data);
        event.dataObject        = usrVo;
        VideoTool.sendUserLinkEvent(event);
    }

    private function initUI():void {
        _txtRank.mouseEnabled = _txtCost.mouseEnabled = false;
        _txtName.addEventListener(MouseEvent.CLICK, onLickEvent);
    }

    private function onClick(evt:MouseEvent):void {
    }

    public function get data():* {
        return _data;
    }

    public function set data(value:*):void {
        _data = value;
        _data = data;
        if (_data == null) {
            _txtRank.text = "数据错误null";
        }
        else {
            _txtRank.text = data.rank.toString();
            if (data.score != null)
                _txtCost.text = data.money.toString();
            else
                _txtCost.text = "";
            if (_txtRank.text.length < 2) {
                _txtRank.text = "0" + _txtRank.text;
            }
            _txtName.htmlText = '<a href="com.rover022.event:' + data.rank + '">' + data.name + '</a>';
            switch (_txtRank.text) {
                case "01":
                    rackBg.gotoAndStop(1);
                    _txtName.textColor = 0xF6FF00;
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
        }
        if (_forceWith != FORCRE_WIDTH && FORCRE_WIDTH > 0) {
            adujustSize(FORCRE_WIDTH);
        }
    }

    public function adujustSize(wide:Number = 0):void {
        if (_forceWith != wide && wide > 0) {
            _forceWith = wide;
            if (wide >= MIX_WIDTH) //如果尺寸大于最小尺寸 动态调整位置
            {
                //this.width=wide;
                _mcMoney.x    = wide - 100;
                _txtName.x    = _txtRank.x + _txtRank.width + ((wide - MIX_WIDTH) / 4) * 3 + 20;
                _mcLine.width = wide - 4;
                //_mcMoney.scaleX=_reWidth/wide;
            }
            else  //如果设定尺寸小于最小限定尺寸，等比例缩放
            {
                var scale:Number = wide / this.width;
                this.scaleY      = scale;
            }
        }
    }

    public function dispose():void {
        _txtName.removeEventListener(MouseEvent.CLICK, onLickEvent);
        _mcLine.width = _reWidth;
        if (this.parent)
            this.parent.removeChild(this);
    }

    public function get select():Boolean {
        return _select;
    }

    public function set select(value:Boolean):void {
        _select = value;
    }

    public function  get view():DisplayObject {
        return this;
    }

    override public function get width():Number {
        return _mcLine.width;
    }
}
}
