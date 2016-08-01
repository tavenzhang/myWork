package com.kingjoy.view {
import com.rover022.vo.VideoConfig;
import display.ui.CGLoader;
import display.ui.ScaleBitmap;

import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.net.URLRequest;

public class BackGroundLay extends MovieClip {
    public var view_mc:MovieClip;//背景图
    private var body_mc:Sprite;
    private var layoutData:Object = {};
    private var leftBase:ScaleBitmap;
    private var centerBase:ScaleBitmap;
    private var videoLightBase:ScaleBitmap;
    private var rightBase:ScaleBitmap;
    private var chatBase:ScaleBitmap;
    private var chatNewsBase:ScaleBitmap;

    public function BackGroundLay():void {
        this.mouseChildren = false;
        this.mouseEnabled = false;
        this.body_mc = new Sprite;
        this.body_mc.x = 5;
        this.body_mc.y = 5;
        this.addChild(this.body_mc);
        this.leftBase = new ScaleBitmap(new baseBorder(84, 84));
        this.leftBase.scale9Grid = new Rectangle(20, 20, 10, 10);
        this.leftBase.y = 85;
        this.leftBase.width = 300;
       //∫ this.body_mc.addChild(this.leftBase);
        //**************中间
        this.centerBase = new ScaleBitmap(new baseBorder2(607, 41));
        this.centerBase.scale9Grid = new Rectangle(50, 10, 500, 20);
        this.centerBase.x = this.leftBase.width + 35;
        this.centerBase.y = 5;
        this.centerBase.width = 752;
        this.centerBase.height = 420;
        //this.body_mc.addChild(this.centerBase);
        //高光
        this.videoLightBase = new ScaleBitmap(new baseVideoLight(607, 154));
        this.videoLightBase.scale9Grid = new Rectangle(50, 10, 50, 130);
        this.videoLightBase.alpha = .1;
        this.videoLightBase.x = this.centerBase.x
        this.videoLightBase.y = this.centerBase.y;
        this.videoLightBase.width = this.centerBase.width;
        //this.body_mc.addChild(this.videoLightBase);
        //****************右边
        this.rightBase = new ScaleBitmap(new baseBorder(84, 84));
        this.rightBase.scale9Grid = new Rectangle(20, 20, 10, 10);
        this.rightBase.x = this.centerBase.x + this.centerBase.width + 10;
        this.rightBase.y = 85;
        this.rightBase.width = 300;
        this.body_mc.addChild(this.rightBase);
        //消息
//        this.chatNewsBase = new ScaleBitmap(new baseNewsBorder(91, 41));
//        this.chatNewsBase.scale9Grid = new Rectangle(30, 15, 10, 10);
//        this.chatNewsBase.x = this.rightBase.x + 5;
//        this.chatNewsBase.y = this.rightBase.y + 50;
//        this.chatNewsBase.width = 270;
//        this.body_mc.addChild(this.chatNewsBase);
        //聊天
        this.chatBase = new ScaleBitmap(new baseChatBorder(51, 81));
        this.chatBase.scale9Grid = new Rectangle(20, 20, 10, 10);
        this.chatBase.x = this.rightBase.x + 2;
        this.chatBase.width = 276;
        this.body_mc.addChild(this.chatBase);
        this.addEventListener(Event.ADDED_TO_STAGE, _addedToStageEvent);
        var loader:CGLoader = new CGLoader();
        loader.load(new URLRequest(VideoConfig.HTTP + "image/other/background.jpg"));
        loader.x = -360;
        loader.y = -40;
        addChildAt(loader, 0);
    }

    private function _addedToStageEvent(e:Event):void {
        this.removeEventListener(Event.ADDED_TO_STAGE, _addedToStageEvent);
        this.stage.addEventListener(Event.RESIZE, _resizeStageEvent);
        this._resizeStageEvent(null);
    }

    //------------------尺寸变化
    private function _resizeStageEvent(e:Event):void {
        var _leftHeight:Number = this.stage.stageHeight - this.leftBase.y;
        if (_leftHeight < 610) {
            _leftHeight = 610;
        }
        if (_leftHeight > 820) {
            _leftHeight= 820;
        }
        this.leftBase.height = _leftHeight;
        this.rightBase.height = _leftHeight;
        var _h:int = int(this.rightBase.height);
        if (this.rightBase.height > 820) {
            _h = 820;
        }
        this.chatBase.y = _h - 50;
        this.x = (this.stage.stageWidth - 1400) / 2
        this.renderLayout();//提交布局
    }

    //------------------------
    //更新布局
    private function renderLayout():void {
        this.layoutData.view = {x: this.x, y: this.y, w: 1400, h: this.body_mc.height};
        this.layoutData.leftBase = {
            x: this.body_mc.x + this.leftBase.x,
            y: this.body_mc.y + this.leftBase.y,
            w: this.leftBase.width,
            h: this.leftBase.height
        };
        this.layoutData.centerBase = {
            x: this.body_mc.x + this.centerBase.x,
            y: this.body_mc.y + this.centerBase.y,
            w: this.centerBase.width,
            h: this.centerBase.height
        };
        this.layoutData.rightBase = {
            x: this.body_mc.x + this.rightBase.x,
            y: this.body_mc.y + this.rightBase.y,
            w: this.rightBase.width,
            h: this.rightBase.height
        };
        /**/
        this.dispatchEventView(this.layoutData);
    }

    //发布事件
    private function dispatchEventView(_data:Object):void {
        this.dispatchEvent(new ktvStageEvent(_data));
    }
}
}