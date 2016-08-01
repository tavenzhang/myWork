package taven {
import display.BaseModule;
import com.rover022.display.UserIconMovieClip;

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.text.TextFormat;
import flash.utils.setTimeout;

import taven.common.progress;

import taven.enum.EventConst;
import taven.enum.EventUtils;
import net.TavenHttpService;
import taven.sideGroup.GiftCircleView;
import taven.utils.HeadIconBuildTool;
import taven.utils.StringUtils;

public class leftMap extends BaseModule {
    public var playerPanel_mc:MovieClip;
    public var roomConfig_spr:MovieClip;
    private var roomSet_bt:SimpleButton;
    private var dataInfo:Object;
    private var view:res_leftMap;
    private var _textFormat:TextFormat = new TextFormat("宋体", 14, 0x00AEFF, true);
    private var _isSending:Boolean = false;
    private var _sendState:int;
    private var _isBeFocus:Boolean = false;
    /*设置数据源*/
    private var _focusInfo:*;
    /**alert 信息*/
    public var alertMsg:Object = new Object();
    private var _isPlayer:Boolean;
    private var _isDisplayFocus:Boolean;
    private var _showTranUser:Boolean;
    public var _icon:UserIconMovieClip;





    public function leftMap():void {
        view = new res_leftMap();
        this.playerPanel_mc = view.playerPanel_mc;
        this.addChild(view);
        new progress(this.playerPanel_mc.progress_mc);
        this.playerPanel_mc.head_mc.x -= 3;
        this.playerPanel_mc.head_mc.y -= 1;
        this.playerPanel_mc.mouseEnabled = false;
        this.playerPanel_mc.visible = false;
        this.playerPanel_mc.vip_mc.visible = false;
        this.playerPanel_mc.asset_mc.visible = false;
        this.playerPanel_mc.rname_txt.visible = false;
        this.playerPanel_mc.time_txt.visible = false;
        this.playerPanel_mc.totalExp_txt.visible = false;
        _icon = new UserIconMovieClip(playerPanel_mc, 173, 48);
        _icon.setType(UserIconMovieClip.ICONTYPE_ANCHOR);
        this.addEventListener(Event.ADDED_TO_STAGE, _addedToStageEvent);
        this.roomConfig_spr = view.roomConfig_spr;
        this.roomConfig_spr.mouseEnabled = false;
        this.roomSet_bt = this.roomConfig_spr.roomSet_bt;
        this.roomConfig_spr.visible = false;
        atten_bt.visible = false; //关注按钮
        hasAtten_bt.visible = false;//已关注按
        space_bt.visible = false; //访问空间按钮
        this.addEventListener(MouseEvent.CLICK, _clickMouseEvent);
        this.playerPanel_mc.txtFocuse.text = "";
        //主播 才显示
    }


    public function get isPlayer():Boolean {
        return _isPlayer;
    }

    private function _addedToStageEvent(e:Event):void {
        this.removeEventListener(Event.ADDED_TO_STAGE, _addedToStageEvent);
        this.stage.addEventListener(Event.RESIZE, _resizeStageEvent);
        this._resizeStageEvent(null);
    }

    //------------------尺寸变化
    private function _resizeStageEvent(e:Event):void {
    }

    public function formatData(_obj:Object, _bool:Boolean = false):void {
        this.dataInfo = _obj;
        if (_obj) {
            var _mc:MovieClip = this.playerPanel_mc;
            _mc.name_txt.defaultTextFormat = this._textFormat;
            _mc.name_txt.setTextFormat(this._textFormat);
            _mc.name_txt.selectable = true;
            _mc.head_mc.mask = _mc.mask_mc;
            _mc.name_txt.text = _obj.name;
            _mc.time_txt.text = _obj.sdate;
            _mc.sex_mc.gotoAndStop(int(_obj.sex) + 1)
            _mc.asset_mc.gotoAndStop(int(_obj.richLv));
            HeadIconBuildTool.loaderUserHead(_obj.headimg, _mc.head_mc)
            _mc.vip_mc.gotoAndStop(int(_obj.vip) + 1);
            _mc.rname_txt.text = _obj.rname;
            this.updataExp(_obj);
            //_mc.totalExp_txt.visible = _bool; 主播端本场直播点数
            this.playerPanel_mc.visible = true;
        } else {
            this.playerPanel_mc.visible = false;
        }
    }

    public function updataExp(_obj:Object):void {
        if (_obj) {
            var _mc:MovieClip = this.playerPanel_mc;
            _mc.totalExp_txt.mouseEnabled = false;
            _mc.progress_mc.step = _obj.expLevel;
            _mc.progress_mc.value = _obj.expLevel - (_obj.expTotal - _obj.exp);
            _mc.exp_txt.text = StringUtils.strStitute("还差{0}钻石升级", (_obj.expTotal - _obj.exp));
            _icon.updateByLv(_obj.lv);
            if (this.dataInfo) {
                _mc.totalExp_txt.text = "本场增加:" + (_obj.exp - this.dataInfo.exp) + "点"
            }
        }
    }

    public function get atten_bt():SimpleButton {
        return this.playerPanel_mc.atten_bt;
    }

    public function get hasAtten_bt():SimpleButton {
        return this.playerPanel_mc.hasAtten_bt;
    }

    public function get space_bt():SimpleButton {
        return this.playerPanel_mc.space_bt;
    }

    public function resetModule():void {
        this.formatData(null);
    }

    public function set isPlayer(_v:Boolean):void {
        //	this.roomConfig_spr.visible = _v;
        _isDisplayFocus = _v;
        if (_isDisplayFocus) {
            atten_bt.visible = false;
            hasAtten_bt.visible = false;
        }
    }

    //--------------------------------------
    //事件
    private function _clickMouseEvent(e:Event):void {
        //trace(e.target.name)
        switch (e.target.name) {
            case "roomSet_bt":
                EventUtils.secndStatusEvent(this, "roomConfigPanel");
                //this.dispatchEvent(new ktvEvent(null, "roomConfigPanel", ktvEvent.KTV_MouseEvent));
                break;
            case "atten_bt":
                //EventUtils.secndStatusEvent(this,"atten");
                c2sFocusStatue(1);
                //this.dispatchEvent(new ktvEvent(this.data, "atten", ktvEvent.KTV_MouseEvent));
                break;
            case "hasAtten_bt":
                //EventUtils.secndStatusEvent(this,"hasAtten");
                c2sFocusStatue(2);
                //this.dispatchEvent(new ktvEvent(this.data, "hasAtten", ktvEvent.KTV_MouseEvent));
                break;
            case "space_bt":
                //EventUtils.secndStatusEvent(this,"space");
                if (_focusInfo) {
                    navigateToURL(new URLRequest(_focusInfo.space_url), "_blank");
                }
                //this.dispatchEvent(new ktvEvent(this.data, "space", ktvEvent.KTV_MouseEvent));
                break;
            default:
        }
    }

    /** 设置关注状态 0 查询 1:添加 2:取消*/
    private function c2sFocusStatue(state:int = 0):void {
        if (!this._focusInfo)
            return;
        if (_isSending == false) {
            var url:String = "{0}?pid={1}&ret={2}";
            url = StringUtils.strStitute(url, _focusInfo.focusURL, _focusInfo.uid, state);
            TavenHttpService.addHttpService(url, s2cFocusStatue);
            _sendState = state;
            _isSending = true;
            setTimeout(function ():void {
                _isSending = false
            }, 1000);
        }
    }

    public function get dataFocus():* {
        return _focusInfo;
    }

    /*
     nickname 昵称
     username 用户名
     lv_rich 财富等级
     roled 主播/普通会员   身份 0:用户 1,2:管理 3:主播
     lv_exp 主播等级
     uid 用户id
     birthday 生日
     age 年龄
     starname 星座
     description 个人签名
     sex 性别
     procity 省市
     attens 关注量
     space_url 空间url
     sid 写邮件是 发送者id
     httpUrl httpseriver前置 比如http://vf.com/letter
     */
    public function set dataFocus(value:*):void {
        _focusInfo = value;
        if (_focusInfo) {
            isBeFocus = _isBeFocus;
            c2sFocusStatue(0);
            space_bt.visible = true //访问空间按钮
        }
        else {
            atten_bt.visible = false //关注按钮
            hasAtten_bt.visible = false//已关注按
            space_bt.visible = false //访问空间按钮
        }
    }

    private function s2cFocusStatue(data:String):void {
        trace("data =" + data);
        var dataObj:Object = JSON.parse(data);
        if (_sendState == 0) //如果是查询成功
        {
            if (dataObj.status == "1") //表示已经有关注
            {
                isBeFocus = true;
            }
            else {
                isBeFocus = false;
            }
        }
        else if (_sendState == 1) //添加关注
        {
            if (dataObj.status == "1") //表示添加关注成功
            {
                _focusInfo.attens++;
                isBeFocus = true;
                alertMsg.msg = dataObj.msg;
                alertMsg.title = "添加关注成功";
                EventUtils.secndStatusEvent(this, EventConst.PERSON_ALERT);
            }
            else {
                alertMsg.msg = dataObj.msg;
                alertMsg.title = "添加关注失败";
                EventUtils.secndStatusEvent(this, EventConst.PERSON_ALERT);
            }
        }
        else if (_sendState == 2) //取消关注成功
        {
            if (dataObj.status == "1") ///取消关注成功
            {
                _focusInfo.attens--;
                isBeFocus = false;
                alertMsg.msg = dataObj.msg;
                alertMsg.title = "取消关注成功";
                EventUtils.secndStatusEvent(this, EventConst.PERSON_ALERT);
            }
            else {
                alertMsg.msg = dataObj.msg;
                alertMsg.title = "取消关注失败";
                EventUtils.secndStatusEvent(this, EventConst.PERSON_ALERT);
            }
        }
    }

    public function set isBeFocus(value:Boolean):void {
        view.playerPanel_mc.txtFocuse.mouseEnabled = false;
        _isBeFocus = value;
        var attens:int;
        if (_isBeFocus) {
            if (_focusInfo) {
                if (_isDisplayFocus) {
                    atten_bt.visible = false;
                    hasAtten_bt.visible = false;
                }
                else {
                    atten_bt.visible = false;
                    hasAtten_bt.visible = true;
                }
                attens = int(_focusInfo.attens);
                attens = attens <= 0 ? 0 : attens;
                if (attens > 9999) {
                    view.playerPanel_mc.txtFocuse.text = StringUtils.strStitute("({0})人", attens);
                }
                else {
                    view.playerPanel_mc.txtFocuse.text = StringUtils.strStitute("已关注({0})", attens);
                }
                if (hasAtten_bt.visible) {
                    view.playerPanel_mc.txtFocuse.x = hasAtten_bt.x - view.playerPanel_mc.txtFocuse.textWidth - 1;
                }
                else {
                    view.playerPanel_mc.txtFocuse.text = StringUtils.strStitute("已关注({0})", attens);
                    view.playerPanel_mc.txtFocuse.x = space_bt.x - view.playerPanel_mc.txtFocuse.textWidth - 2;
                }
            }
        }
        else {
            if (_isDisplayFocus) {
                atten_bt.visible = false;
                hasAtten_bt.visible = false;
            }
            else {
                atten_bt.visible = true;
                hasAtten_bt.visible = false;
            }
            if (_focusInfo) {
                attens = int(_focusInfo.attens);
                attens = attens <= 0 ? 0 : attens;
                if (attens > 99999) {
                    view.playerPanel_mc.txtFocuse.text = StringUtils.strStitute("关注{0}", attens);
                }
                else {
                    view.playerPanel_mc.txtFocuse.text = StringUtils.strStitute("关注({0})", attens);
                }
                if (atten_bt.visible) {
                    view.playerPanel_mc.txtFocuse.x = atten_bt.x - view.playerPanel_mc.txtFocuse.textWidth - 2;
                }
                else {
                    view.playerPanel_mc.txtFocuse.text = StringUtils.strStitute("关注({0})", attens);
                    view.playerPanel_mc.txtFocuse.x = space_bt.x - view.playerPanel_mc.txtFocuse.textWidth - 2;
                }
                //view.playerPanel_mc.txtFocuse.x =	atten_bt.x -view.playerPanel_mc.txtFocuse.textWidth-2
                /*atten_bt.x =hasAtten_bt.x =view.playerPanel_mc.txtFocuse.x+view.playerPanel_mc.txtFocuse.textWidth+2;
                 space_bt.x = atten_bt.x +atten_bt.width+2;*/
            }
        }
    }
}
}