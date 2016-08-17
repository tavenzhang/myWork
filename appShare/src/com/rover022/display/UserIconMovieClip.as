/**
 * Created by Administrator on 2015/6/16.
 */
package com.rover022.display {
import com.greensock.loading.ImageLoader;
import com.rover022.vo.VideoConfig;

import flash.display.DisplayObjectContainer;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;
import flash.utils.Dictionary;
import flash.utils.getDefinitionByName;

public class UserIconMovieClip extends MovieClip {
    public static const ICONTYPE_ANCHOR:String = "TYPE_ANCHOR";
    public static const ICONTYPE_USER:String = "TYPE_USER";
    public var actionIcon:MovieClip;//主播等级
    public var vIcon:MovieClip;//主播等级
    public var richIcon:MovieClip;//财富等级
    public static var AROOT:String = "";
    private var _oldId:int = 0;
    private var _activeIcoMap:Dictionary = new Dictionary();
    private var _image:ImageLoader = new ImageLoader("", {container: this});

    public function UserIconMovieClip(parent:DisplayObjectContainer, _x:Number = 0, _y:Number = 0) {
        this.x = _x;
        this.y = _y;
        parent.addChild(this);
    }

    /**
     * 直接设置看使用哪种图标
     * @param _num
     */
    public function setType(_num:String):void {
        var _c:Class;
        if (_num == ICONTYPE_ANCHOR) {
            _c = getDefinitionByName("shareElement.level_icon") as Class;
            if (vIcon == null) {
                vIcon = new _c() as MovieClip;
                addChild(vIcon);
            }
            vIcon.visible = true;
            if (richIcon) {
                richIcon.visible = false;
            }
        } else if (_num == ICONTYPE_USER) {
            _c = getDefinitionByName("shareElement.asset_icon") as Class;
            if (richIcon == null) {
                richIcon = new _c() as MovieClip;
                addChild(richIcon);
            }
            richIcon.visible = true;
            if (vIcon) {
                vIcon.visible = false;
            }
        }
    }

    public function showVipIconByVipID(_id:Number):void {
        if (_oldId != _id) {
            _oldId = _id;
        }
        else {
            return;
        }
        if (_id > 0) {
            if (actionIcon && actionIcon.parent) {
                actionIcon.parent.removeChild(actionIcon);
            }
            actionIcon = buildIcon(_id);
            addChild(actionIcon);
            actionIcon.visible = true;
        } else {
            if (actionIcon) {
                actionIcon.visible = false;
            }
        }
    }

    private function buildIcon(id:Number):MovieClip {
        var s:MovieClip;
        var url:String = AROOT + "image/signal_icon/" + id + ".png";


        if (!_activeIcoMap[url]) {
            s = new MovieClip();
            var pngLoader:Loader = new Loader();
            pngLoader.load(new URLRequest(url));
            pngLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function (e:IOErrorEvent):void {

            });
            pngLoader.x = -30 - 30;
            pngLoader.y = -7 - 7;
            s.addChild(pngLoader);
            _activeIcoMap[url] = s;
        }
        else
            s = _activeIcoMap[url] as MovieClip;
        return s;
    }

    public function updateByLv(_frame:int):void {
        updateLv(_frame);
        //  vIcon.gotoAndStop(_frame);
    }

    public function updateLv(_frame:int):void {
        _frame = _frame <= 0 ? 0 : _frame;
        if (vIcon) {
            vIcon.gotoAndStop(_frame > vIcon.totalFrames ? vIcon.totalFrames : _frame);
        }
        if (richIcon) {
            richIcon.gotoAndStop(_frame > richIcon.totalFrames ? richIcon.totalFrames : _frame);
        }
    }


    public function updateLvByImage(_id:int):void {
        _image.url = VideoConfig.HTTP + "image/rlv_icon/" + _id + ".png";
        _image.load();
    }


    public function updateByRlv(_frame:int):void {
        updateLv(_frame);
        //richIcon.gotoAndStop(_frame);
    }

    public function updateAptitude(userData:Object, roomData:Object):void {
        if (userData.uid == roomData.roomid) {
            vIcon.gotoAndStop(userData.lv);
        } else if (userData.rlv > 1) {
            richIcon.gotoAndStop(userData.rlv);
        }
    }
}
}
