package taven.playerInfo {
import com.rover022.display.UserIconMovieClip;
import com.rover022.event.CBModuleEvent;
import com.rover022.vo.UserVo;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.StatusEvent;

import taven.common.IListItem;
import taven.utils.MathUtils;

import tool.VideoTool;

public class ItemUserRender extends taven_playerMRender implements IListItem {
    private var _data:*;
    private var _select:Boolean;
    private var icoMc:UserIconMovieClip;

    public function ItemUserRender() {
        this.mcPower.visible = false;
        this.mcSelect.mouseEnabled = this.mcPower.mouseEnabled = this.txtName.mouseEnabled = this.mcLevel.mouseEnabled = false;
        this.mcSelect.visible = false;
        this.addEventListener(MouseEvent.CLICK, onClickHandle);
        this.mcLevel.mouseChildren = false;
        icoMc = new UserIconMovieClip(this.mcLevel, 0, 0);
        icoMc.setType(UserIconMovieClip.ICONTYPE_ANCHOR);
        //icoMc.scaleX = icoMc.scaleY = 0.95;
        this.mcLevel.x += 5;
    }

    /**数据源*/
    public function get data():* {
        return _data;
    }

    /**
     * @private
     */
    public function set data(value:*):void {
        _data = value;
        if (_data != null) {
            this.visible = true;
            this.mcPower.gotoAndStop(_data.power == 1 ? 2 : 1);
            this.mcPower.visible = _data.power != 0;
            this.txtName.text = _data.name;
            this.mcLevel.removeChildren();
            if (_data.power == 2) {
                icoMc.setType(UserIconMovieClip.ICONTYPE_ANCHOR);
                icoMc.updateLv(_data.level);
            }
            else {
                icoMc.setType(UserIconMovieClip.ICONTYPE_USER);
                icoMc.updateLv(_data.level);
            }
            icoMc.showVipIconByVipID(_data.vip);
            this.mcLevel.addChild(icoMc);
            select=false;
        }
        else {
            this.visible = false;
            this.mcPower.visible = false;
            this.txtName.text = "";
        }
    }

    private function onClickHandle(evt:Event):void
    {
        var event:CBModuleEvent = new CBModuleEvent(CBModuleEvent.PLAYNAMELINK, true);
        var usrVo = new UserVo(_data);
        event.dataObject        = usrVo;
        VideoTool.sendUserLinkEvent(event);
    }

    public function get select():Boolean {
        return _select;
    }

    public function set select(value:Boolean):void {
        _select = value;
       // this.mcSelect.visible = _select;
    }

    public function  get view():DisplayObject {
        return this;
    }
}
}
