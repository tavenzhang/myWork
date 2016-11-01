/**
 * Created by ws on 2015/8/17.
 */
package taven {
import com.rover022.display.UserIconMovieClip;
import com.rover022.event.CBModuleEvent;
import com.rover022.vo.VideoConfig;

import display.BaseModule;
import display.ui.Alert;

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;

import manger.DataCenterManger;

import net.NetManager;

import tool.VideoTool;

public class LimitEnterModule extends BaseModule {
    private var _view:tavenRoomValid;
    private var icoLRich:UserIconMovieClip;
    private var icoRich:UserIconMovieClip;

    override protected function initView():void {
        _view = new tavenRoomValid();
        $view = _view;
        addChild($view);
        icoLRich = new UserIconMovieClip(_view, _view.txtLRich.x, _view.txtLRich.y + 4);
        icoRich = new UserIconMovieClip(_view, _view.txtRich.x, _view.txtLRich.y + 4);
        icoLRich.setType(UserIconMovieClip.ICONTYPE_USER);
        icoRich.setType(UserIconMovieClip.ICONTYPE_USER);
        _view.txtLRich.text = "";
        _view.txtRich.text = "";
        _view.btnClose.visible = false;
        _view.addEventListener(MouseEvent.CLICK, onViewClick);
        VideoTool.makeMovieClipToButton(_view.btnChongzhi);
        VideoTool.makeMovieClipToButton(_view.btnMail);
        VideoTool.makeMovieClipToButton(_view.btnVip);
        VideoTool.makeMovieClipToButton(_view.use_up);
        addEventListener(CBModuleEvent.LIMIT_ROOM, onLimuteHandle);
        addEventListener(CBModuleEvent.LIMIT_ROOM_QAINGENTER, onQiangEnterHandle);
      //  _view.guizuiMc.visible = false;

    }

    private function onQiangEnterHandle(event:CBModuleEvent):void {
        trace("................");
        //{"cmd":10014,"uid":101116443,"restCount":0}
        this.visible = false;
    }

    private function onLimuteHandle(e:CBModuleEvent):void {

        var obj:Object = e.dataObject;
        //{"open":1,"mailCheckedLimit":0,"roomid":101152823,"richLimit":2000,"show":1,"cmd":10011,"richLvLimit":0}
        visible = false;
        var isGetPower:Boolean = true;//已经达到限制权限;
        _view.use_up.visible = DataCenterManger.userData.ruled >= 0 ? true : false;
        _view.use_up.visible = false;
        if (obj.open == 1) {
            if (obj.richLimit > DataCenterManger.userData.points) {
                isGetPower = false;
                _view.txtMony.textColor = 0xff0000;
            }
            if (obj.richLvLimit > DataCenterManger.userData.richLv) {
                isGetPower = false;
                _view.txtRlvError.textColor = 0xff0000;
            } else {
                _view.txtRlvError.text = "";
            }
            //trace(obj.mailCheckedLimit == 1)
            if (obj.mailCheckedLimit == 1 && DataCenterManger.userData.emailValid == 0) {
                isGetPower = false;
                _view.txtmail.textColor = 0xff0000;
            }
        }
        if (isGetPower == false) {
            visible = true;
        }
        //设置数据
        var uservo:Object = DataCenterManger.userData;
        _view.txtMony.text = uservo.points.toString();
        _view.txtmail.text = uservo.emailValid ? "已验证" : "未验证";
        icoRich.updateLvByImage(uservo.richLv);
        //
        _view.txtLmail.text = obj.mailCheckedLimit == 0 ? "无需验证" : "需要验证";
        _view.txtLMony.text = obj.richLimit == 0 ? "无需验证" : "需:" + obj.richLimit;
        _view.txtLRich.text = obj.richLvLimit == 0 ? "无需验证" : "";
        if (obj.richLvLimit != 0) {
            icoLRich.updateLvByImage(obj.richLvLimit);
        }
        //
    }

    private function onViewClick(evt:MouseEvent):void {
        switch (evt.target) {
            case _view.btnClose://点击关闭
                this.hide();
                break;
            case _view.btnChongzhi://点击充值
                ( $videoroom as MovieClip).dispatchEvent(new Event("rechargeEvent"));  //由于不能直接调cliendManager； 通关videoroom间接来做
                break;
            case _view.btnMail://点击邮件
                VideoTool.jumpToMailURL(null);
                break;
            case _view.btnVip://点击vip
                VideoTool.jumpToGuiZhuURL();
                break;
            case _view.use_up:
                if (DataCenterManger.vipInfo.limitRoomCount <= 0) {
                    Alert.Show("没有特权,请提升你的用户或贵族等级", "消息");
                } else {
                    Alert.Show("当前剩余特权次数为 " + DataCenterManger.vipInfo.limitRoomCount + "次,是否消耗1次特权来进入房间", "消息", false, 3, false, requestGuiZhuPower);
                }
                break;
        }
    }

    private function requestGuiZhuPower(e:* = null):void {
        NetManager.getInstance().sendDataObject({cmd: 10014, roomid: VideoConfig.roomID});
    }
}
}
