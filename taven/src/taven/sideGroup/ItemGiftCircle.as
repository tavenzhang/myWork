/**
 * Created by Taven on 2015/8/22.
 */
package taven.sideGroup {
import com.rover022.vo.UserVo;
import com.rover022.vo.VideoConfig;

import flash.events.MouseEvent;
import flash.events.StatusEvent;
import flash.text.StyleSheet;

import manger.UserVoDataManger;

import taven.UserInfo;
import taven.utils.DisplayUtils;
import taven.utils.loadHeadElement;

public class ItemGiftCircle extends res_richGiftItem {
    private var _data:Object;
    private var _itemIcoMc:loadHeadElement;
    private var _headUrl:String = "";
    /**静态共享变量*/
                private static var CSS_STYPE_SHEET:StyleSheet;
    private var callFun:Function;

    public function ItemGiftCircle() {
        _itemIcoMc = new loadHeadElement();
        DisplayUtils.replaceDisplayer(mcIco, _itemIcoMc);
        _itemIcoMc.width  = mcIco.width;
        _itemIcoMc.height = mcIco.height;
        if (CSS_STYPE_SHEET == null) {
            CSS_STYPE_SHEET = new StyleSheet();
            CSS_STYPE_SHEET.parseCSS("a:hover{textDecoration:underline}");
        }
        this.txtSendName.styleSheet = CSS_STYPE_SHEET;
        this.txtRecName.styleSheet  = CSS_STYPE_SHEET;
        this.txtSendName.addEventListener(MouseEvent.CLICK, onLinkeText);
        this.txtRecName.addEventListener(MouseEvent.CLICK, onLinkeText);
    }

    private function onLinkeText(evt:MouseEvent):void {
        evt.stopImmediatePropagation(); //禁止冒泡
        if (callFun) {
            callFun();
        }
    }

    public function get date():Object {
        return _data;
    }

    public function addCallBack(fun:Function):void {
        callFun = fun;
    }

    public function set date(value:Object):void {
        _data = value;
        if (_data) {
            this.visible      = true;
            this.txtTime.text = _data.created;
            if (_data.sendHidden && _data.sendHidden == 1) {
                _data.sendName = "神秘人";
            }
            this.txtSendName.htmlText = '<a href="com.rover022.event:' + _data.roomid + '">' + _data.sendName + '</a>';
            this.txtSendName.x        = this.txtTime.x + this.txtTime.textWidth + 10;
            this.txtSend.text         = "送给";
            this.txtSend.x            = this.txtSendName.x + this.txtSendName.textWidth + 5;
            this.txtRecName.htmlText  = '<a href="com.rover022.event:' + _data.roomid + '">' + _data.recName + '</a>';
            this.txtRecName.x         = this.txtSend.x + this.txtSend.textWidth + 5;
            this.txtNum.text          = _data.gnum.toString() + "个";
            this.txtNum.x             = this.txtRecName.x + this.txtRecName.textWidth + 20;
            var _gurl:String          = VideoConfig.resAdd;
            _gurl                     = _gurl.replace("\{0\}", _data.gid);
            if (_headUrl != _gurl) {
                _itemIcoMc.loadHead(_gurl);
                _headUrl = _gurl;
            }
            _itemIcoMc.x = this.txtNum.x + this.txtNum.textWidth + 10;
        }
        else {
            this.visible = false;
        }
    }
}
}
