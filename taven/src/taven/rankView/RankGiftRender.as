package taven.rankView {
import com.rover022.event.CBModuleEvent;
import com.rover022.vo.UserVo;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.StatusEvent;
import flash.events.TextEvent;
import flash.text.StyleSheet;
import flash.text.TextField;

import taven.common.IListItem;
import taven.enum.StringConst;
import taven.utils.DisplayUtils;
import taven.utils.StringUtils;
import taven.utils.loadHeadElement;

public class RankGiftRender extends taven_giftRender implements IListItem {
    private var _mcLine:DisplayObject; //底部下划线
    private var _mcGiftIco:MovieClip; //金币显示选项
    private var _data:*;
    /**静态共享变量*/
                private static var MIX_WIDTH:Number   = 0;
    /**静态共享变量*/
                public static var FORCRE_WIDTH:Number = 0;
    /**静态共享变量*/
                private static var CSS_STYPE_SHEET:StyleSheet;
    /**物品数量*/
                private var _txtGiftNum:TextField;
    /**原始宽度*/
                private var _reWidth:Number;
    private var _itemIcoMc:loadHeadElement;
    private var _headUrl:String;
    private var _select:Boolean;
    private var _forceWith:Number                     = 0;

    public function RankGiftRender(data:* = null) {
        _mcLine     = this.mcLine;
        _mcGiftIco  = this.mcRight["mcIco"];
        _txtGiftNum = this.mcRight["mcNum"];
        if (MIX_WIDTH <= 0) {
            MIX_WIDTH = txtTime.width + txtName.width + mcRight.width; //显示需要的最小宽度
        }
        if (CSS_STYPE_SHEET == null) {
            CSS_STYPE_SHEET = new StyleSheet();
            CSS_STYPE_SHEET.parseCSS("a:hover{textDecoration:underline}");
        }
        _itemIcoMc = new loadHeadElement();
        DisplayUtils.replaceDisplayer(_mcGiftIco.sp, _itemIcoMc);
        _itemIcoMc.width          = _mcGiftIco.sp.width;
        _itemIcoMc.height         = _mcGiftIco.sp.height;
        _reWidth                  = this.width;
        txtName.styleSheet        = CSS_STYPE_SHEET;
        this.txtTime.mouseEnabled = mcRight.mouseEnabled = false;
        txtName.addEventListener(MouseEvent.CLICK, onClickNameLink);
    }

    private function onClick(evt:MouseEvent):void {
    }

    public function get data():* {
        return _data;
    }

    public function set data(value:*):void {
        _data             = value;
        this.txtTime.text = _data.time.toString();
        this.txtName.text = _data.name;
        if (_data.hidden && _data.hidden == 1) {
            _data.name = "神秘人";
        }
        if (_data.sendHidden && _data.sendHidden == 1) {
            _data.name = "神秘人";
        }
        txtName.htmlText = '<a href="com.rover022.event:namelink">' + _data.name + '</a>';
        _txtGiftNum.text = StringUtils.strStitute(StringConst.GIFT_NUM, data.count);
        if (_headUrl != data.ico) {
            _itemIcoMc.loadHead(data.ico);
            _headUrl = data.ico;
        }
        if (_forceWith != FORCRE_WIDTH && FORCRE_WIDTH > 0) {
            adujustSize(FORCRE_WIDTH);
        }
    }

    private function onClickNameLink(e:MouseEvent):void {
        //e.stopImmediatePropagation();
        var _userVo:UserVo      = new UserVo(_data);
        var event:CBModuleEvent = new CBModuleEvent(CBModuleEvent.PLAYNAMELINK, true);
        event.dataObject        = _userVo;
        dispatchEvent(event);
    }

    public function adujustSize(wide:Number):void {
        //this.width =wide;
        if (_forceWith != wide && wide > 0) {
            _forceWith = wide;
            if (wide >= MIX_WIDTH) {
                //mcRight.scaleX=_reWidth/wide;
                mcRight.x     = wide - mcRight.width - 1;
                txtName.x     = txtTime.x + txtTime.width + ((wide - MIX_WIDTH) / 4) * 3 + 5;
                _mcLine.width = wide - 4;
            }
            else {
                var scale:Number = wide / this.width;
                this.scaleY      = scale;
            }
        }
    }

    public function dispose():void {
        _mcLine.width = _reWidth;
        if (this.parent)
            this.parent.removeChild(this);
    }

    //点击之后通知住程序
    private function onLickEvent(evt:Event):void {
        evt.stopImmediatePropagation(); //禁止冒泡
        var event:StatusEvent = new StatusEvent(StatusEvent.STATUS, false, false, _data.name);
        this.dispatchEvent(event);
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
}
}