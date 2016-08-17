package taven {
import display.BaseModule;
import com.rover022.display.UserIconMovieClip;
import com.rover022.tool.SensitiveWordFilter;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TextEvent;
import flash.net.URLRequest;
import flash.net.URLVariables;
import flash.net.navigateToURL;
import flash.utils.setTimeout;


import taven.enum.EventConst;
import taven.enum.EventUtils;
import taven.enum.StringConst;
import net.TavenHttpService;
import taven.utils.DisplayUtils;
import taven.utils.StringUtils;
import taven.utils.loadHeadElement;

public class PersonInfoModule extends BaseModule {
    private var _mainView:taven_mainPersonView;
    private var _headFace:loadHeadElement;
    private var _isBeFocus:Boolean = false;
    /*设置数据源*/
    private var _data:*;
    /**邮件内容*/
    public var mailContent:String;
    private var _requetUrlPre:String;
    private var _isSending:Boolean = false;
    private var _sendState:int;
    /**alert 信息*/
    public var alertMsg:Object = {};
    private var _manageIcon:UserIconMovieClip;



    override protected function initView():void {
        _mainView = new taven_mainPersonView();
        this.addChild(_mainView);
        _mainView.addEventListener(MouseEvent.CLICK, onViewCick);
        _mainView.mcInfo.mcLevel.removeChildren();
        isBeFocus = false; //默认没有关注
        _headFace = new loadHeadElement();
        DisplayUtils.replaceDisplayer(_mainView.mcInfo.mcFace.icoSp, _headFace);
        _mainView.mcMail.txtMailContent.addEventListener(Event.CHANGE, onTxtChange);
        _mainView.mcMail.txtMailContent.maxChars = 200;
        DisplayUtils.removeFromParent(_mainView.mcMail);
        _mainView.mcInfo.btnFocus.buttonMode = true;
        _mainView.mcInfo.btnFocus.mouseChildren = false;
        _mainView.mcInfo.btnUnFocus.buttonMode = true;
        _mainView.mcInfo.btnUnFocus.mouseChildren = false;
        _mainView.mcInfo.btnMail.visible =false;
        isShowEffect = true;
    }

    private function onTxtChange(evt:Event):void {
        var leng:int = 200 - _mainView.mcMail.txtMailContent.length;
        _mainView.mcMail.txtInputNum.text = StringUtils.strStitute("还能输入{0}字", leng);
    }

    private function onViewCick(evt:MouseEvent):void {
        switch (evt.target) {
            case _mainView.mcInfo.btnClose:
                this.visible = false;
                break;
            case _mainView.mcInfo.btnFocus: //添加关注
                //EventUtils.secndStatusEvent(this, EventConst.PERSON_FOCUS);
                c2sFocusStatue(1);
                break;
            case _mainView.mcInfo.btnMail: //写邮件
                if (!_mainView.mcMail.parent)
                    changeToMail();
                else {
                    DisplayUtils.removeFromParent(_mainView.mcMail);
                }
                break;
            case _mainView.mcInfo.btnSpace: //写点击她的空间
                if (_data) {
                    navigateToURL(new URLRequest(_data.space_url), "_blank");
                }
                break;
            case _mainView.mcInfo.btnUnFocus: //写点取消关注
                //EventUtils.secndStatusEvent(this, EventConst.PERSON_UN_FOCUS);
                c2sFocusStatue(2);
                break;
            case _mainView.mcMail.btnClose: //关闭邮件
                DisplayUtils.removeFromParent(_mainView.mcMail);
                break;
            case _mainView.mcMail.btnSend: //发送邮件
                mailContent = _mainView.mcMail.txtMailContent.text;
                c2sSendMail(mailContent);
                //EventUtils.secndStatusEvent(this, EventConst.PERSON_SEND_MAIL);
                break;
        }
    }

//    override public function test():void {
//        var dataObj:Object = {};
//        dataObj.nickname = "边走边看11111";
//        dataObj.lv_exp = (Math.random() * 15).toString();
//        dataObj.lv_rich = int(Math.random() * 30).toString();
//        dataObj.uid = "10000";
//        dataObj.roled = 3;
//        dataObj.description = "这只是一个测试";
//        dataObj.sex = "女";
//        dataObj.age = "15岁";
//        dataObj.starname = "水平座";
//        dataObj.procity = "上海省";
//        dataObj.attens = int(Math.random() * 8888).toString();
//        dataObj.letterURL = "http://192.168.10.230/letter";
//        dataObj.focusURL = "http://192.168.10.230/focus";
//        dataObj.headUrl = StringConst.DEFAULT_IMG;
//        dataObj.isFocus = true;
//        dataObj.space_url = "http://www.baidu.com";
//        data = dataObj;
//    }

    public function get data():* {
        return _data;
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
    public function set data(value:*):void {
        _data = value;
        DisplayUtils.removeFromParent(_mainView.mcMail);
        if (_data) {
            if (_manageIcon != null) {
                _manageIcon.parent.removeChild(_manageIcon);
                _manageIcon = null;
            }
            _manageIcon = new UserIconMovieClip(_mainView.mcInfo, 240, 26);
            var isAu:Boolean = (int(_data.roled) >= 3) ? true : false;
            if (isAu) {
                _manageIcon.setType(UserIconMovieClip.ICONTYPE_ANCHOR);
                _manageIcon.updateByLv(_data.lv_exp);
            } else {
                _manageIcon.setType(UserIconMovieClip.ICONTYPE_USER);
                _manageIcon.updateByRlv(_data.lv_rich);
            }
            if(isAu)
            {
                _mainView.mcInfo.txtId.text="(主播ID:"+_data.uid +")";
            }
            else
            {
                _mainView.mcInfo.txtId.text="";
            }
            _manageIcon.showVipIconByVipID(_data.vip);
            _mainView.mcInfo.txtName.text = _data.nickname == null ? "" : _data.nickname;
            _mainView.mcInfo.txtDetail.text = _data.description == null ? "" : _data.description;
            var pow:int = int(_data.roled == null ? 0 : _data.roled);
            var tempInt:int;
            if (pow >= 3) {
                _mainView.mcInfo.btnSpace.visible = true;
                tempInt = int(_data.lv_exp);
            }
            else {
                _mainView.mcInfo.btnSpace.visible = false;
                tempInt = int(_data.lv_rich);
            }
            _mainView.mcInfo.txtAddRess.text = StringUtils.strStitute("{0} | {1} | {2} | {3}", _data.sex, _data.age, _data.starname, _data.procity);
            _headFace.loadHead(_data.headimg);
            _mainView.mcInfo.mcLevel.x = _mainView.mcInfo.txtName.x + _mainView.mcInfo.txtName.textWidth + 30;
            isBeFocus = _isBeFocus;
            c2sFocusStatue(0);
        }
    }

    private function changeToMail():void {
        if (_data) {
            _mainView.addChild(_mainView.mcMail);
            _mainView.mcMail.visible = true;
            _mainView.mcMail.txtMailTitle.text = _data.nickname;
            _mainView.mcMail.txtInputNum.text = "还能输入200字";
            _mainView.mcMail.txtMailContent.text = "";
            _mainView.mcMail.txtInputNum.addEventListener(TextEvent.TEXT_INPUT, onTxtChange);
            if (_mainView.stage) {
                if ((this.y + this.height) >= this.stage.stageHeight) {
                    this.y = this.stage.stageHeight - this.height;
                }
            }
        }
    }

    public function get isBeFocus():Boolean {
        return _isBeFocus;
    }

    public function set isBeFocus(value:Boolean):void {
        _isBeFocus = value;
        var attens:int;
        if (_isBeFocus) {
            _mainView.mcInfo.btnFocus.visible = false;
            _mainView.mcInfo.btnUnFocus.visible = true;
            if (_data) {
                attens = int(_data.attens);
                attens = attens <= 0 ? 0 : attens;
                _mainView.mcInfo.btnUnFocus.txtFocusNum.text = StringUtils.strStitute("已关注({0})", attens);
                _mainView.mcInfo.btnUnFocus.txtCancel.x = _mainView.mcInfo.btnUnFocus.txtFocusNum.x + _mainView.mcInfo.btnUnFocus.txtFocusNum.textWidth + 2;
            }
        }
        else {
            _mainView.mcInfo.btnFocus.visible = true;
            _mainView.mcInfo.btnUnFocus.visible = false;
            if (_data) {
                attens = int(_data.attens);
                attens = attens <= 0 ? 0 : attens;
                _mainView.mcInfo.btnFocus.txtFocusNum.text = StringUtils.strStitute("关注({0})", _data.attens);
            }
        }
    }

    /** 设置关注状态 0 查询 1:添加 2:取消*/
    private function c2sFocusStatue(state:int = 0):void {
        if (!_data)
            return;
        if (_isSending == false) {
            var url:String = "{0}?pid={1}&ret={2}";
            url = StringUtils.strStitute(url, _data.focusURL, _data.uid, state);
            TavenHttpService.addHttpService(url, s2cFocusStatue);
            _sendState = state;
            _isSending = true;
            setTimeout(function ():void {
                _isSending = false
            }, 1000);
        }
    }

    private function s2cFocusStatue(data:String):void {
        //trace("data =" + data);
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
                _data.attens++;
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
                _data.attens--;
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

    /** 发送邮件*/
    private function c2sSendMail(msg:String):void {
        if (!_data)
            return;
        if (_isSending == false) {
            //var url:String="{0}?rid={1}&msg={2}";
            //url=StringUtils.strStitute(url, _data.letterURL, _data.uid, msg);
            if (_data.uid == _data.myUid) {
                alertMsg.msg = "不能给自己发送私信!";
                alertMsg.title = "发送私信失败";
                EventUtils.secndStatusEvent(this, EventConst.PERSON_ALERT);
            }
            else {
                if (msg == "") {
                    alertMsg.msg = "发送内容不能为空.";
                    alertMsg.title = "发送私信失败";
                    EventUtils.secndStatusEvent(this, EventConst.PERSON_ALERT);
                }
                else {
                    msg = SensitiveWordFilter.validAndReplaceSensitiveWord(msg);
                    if (SensitiveWordFilter.canSend == false) {
                        videoRoom.showAlert("您发送的内容包含敏感字符，请仔细检查！", "私信");
                        return;
                    }
                    var dataVal:URLVariables = new URLVariables();
                    dataVal.rid = _data.uid;
                    dataVal.msg = msg;
                    TavenHttpService.addHttpService(_data.letterURL, s2cSendMail, dataVal);
                    _isSending = true;
                    //延迟处理
                    setTimeout(function ():void {
                        _isSending = false
                    }, 1000)
                }
            }
        }
    }

    private function s2cSendMail(msg:String):void {
        var dataObj:Object = JSON.parse(msg);
        if (dataObj.status == "1") {
            DisplayUtils.removeFromParent(_mainView.mcMail);
            alertMsg.msg = dataObj.msg;
            alertMsg.title = "私信发送成功";
            EventUtils.secndStatusEvent(this, EventConst.PERSON_ALERT);
        }
        else {
            alertMsg.msg = dataObj.msg;
            alertMsg.title = "邮件发送失败";
            EventUtils.secndStatusEvent(this, EventConst.PERSON_ALERT);
        }
    }
}
}
