package taven.rightView {
import com.rover022.display.UserIconMovieClip;

import flash.events.MouseEvent;
import flash.text.TextFormat;

import right.menuUserInfoMc;

import taven.utils.HeadIconBuildTool;

public class MenuUserInfo extends menuUserInfoMc {
    private var _textFormat:TextFormat = new TextFormat("宋体", 14, 0xFFFFFF, true);
    private var _icoMc:UserIconMovieClip


    public function MenuUserInfo() {
        this.name_txt.defaultTextFormat = this._textFormat;
        this.head_mc.width = this.head_mc.height = 48;
        this.head_mc.mask = this.mask_mc;
        this.visible = false;
        this.addEventListener(MouseEvent.CLICK, _userInfoEvent);
        _icoMc = new UserIconMovieClip(this, 100, 37);
    }

    public function formatData(_obj:Object):void {
        if (_obj) {
            this.name_txt.text = _obj.name;
            HeadIconBuildTool.loaderUserHead(_obj.headimg, head_mc);
            this.visible = true;
            if (_obj.ruled == 3) {
                _icoMc.setType(UserIconMovieClip.ICONTYPE_ANCHOR);
                _icoMc.updateByLv(_obj.lv);
            } else {
                _icoMc.setType(UserIconMovieClip.ICONTYPE_USER);
                _icoMc.updateByRlv(_obj.richLv);
            }
            _icoMc.showVipIconByVipID(_obj.vip);
        } else {
            this.visible = false;
        }
    }

    private function _userInfoEvent(e:MouseEvent):void {
        switch (e.target.name) {
            case "close_bt":
                if (this.parent) {
                    this.parent.visible = false;
                }
                break;
            default:
        }
    }
}
}
