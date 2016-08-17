package com.kingjoy.view {
import com.junkbyte.console.Cc;
import com.rover022.vo.VideoConfig;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;
import flash.geom.Matrix;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.text.TextField;
import flash.text.TextFormat;

import ghostcat.manager.RootManager;

import tool.GoogleAdSence;

public class LoadUI extends Sprite {
    private var _loading:MovieClip;
    public static var loadingUI:LoadUI;

    public function LoadUI() {
        this._loading = new loading_res();
        this.addChild(this._loading);
        this.addEventListener(Event.ADDED_TO_STAGE, _addedToStageEvent);
        this.addEventListener(Event.REMOVED_FROM_STAGE, _removedFromStageEvent);
        pButton.addEventListener(MouseEvent.CLICK, jumpToHelpURL);
        pButton.buttonMode = true;
        this._loading.mcView.width=10;
       // pBtnText.defaultTextFormat.underline = true;
       // var defaultextformat:TextFormat = new TextFormat("宋体", 12, 0xBEA890, true, null, true);
       // pBtnText.setTextFormat(defaultextformat);
//        var googleAdClip:GoogleAdSence = new GoogleAdSence();
//        googleAdClip
         
    }


    public function get pButton():MovieClip {
        return _loading.helpBtn;
    }

    public function get pBtnText():TextField {
        return _loading.helpBtn._mession;
    }



    /**
     * 设置加载面板上面的信息
     * @param _str
     * @param _progress
     */
    public static function setLoadInfo(_str:String = "", _progress:int = -1):void {
        if (loadingUI == null) {
            loadingUI = new LoadUI();
        }
        if (loadingUI.parent == null) {
            RootManager.stage.addChild(loadingUI);
        }
        if (_str != "") {
            loadingUI.infoText = _str;
        }
        if (_progress != -1) {
            loadingUI.progressValue = _progress;

        }
        if (_progress >= 100) {
            loadingUI.parent.removeChild(loadingUI);
        }
        loadFlashComplete(_str, _progress);
    }

    public function jumpToHelpURL(e:MouseEvent = null):void {
        var str:String = VideoConfig.localHttpAddress + "about/help#flasherror";
        str = VideoConfig.httpFunction + "/nac/47";
        Cc.log("jumpToHelpURL" + str);
        navigateToURL(new URLRequest(str))
    }

    /**
     * 禁言
     */
    private static function loadFlashComplete(_str:String = "", _progress:Number = 0):void {
        try {
            if (ExternalInterface.available) {
                ExternalInterface.call("flashLoading", _str, _progress);
            }
        } catch (e:*) {
        }
    }

    private function _addedToStageEvent(e:Event):void {
        this.stage.addEventListener(Event.RESIZE, _resizeEvent);
        this._resizeEvent(null);
    }

    private function _removedFromStageEvent(e:Event):void {
        this.removeEventListener(Event.ADDED_TO_STAGE, _addedToStageEvent);
        this.removeEventListener(Event.REMOVED_FROM_STAGE, _removedFromStageEvent);
        this.stage.removeEventListener(Event.RESIZE, _resizeEvent);
        this.stopAllMovieClips();
        this.graphics.clear();
        this.removeChild(this._loading);
        this._loading = null;
    }

    private function _resizeEvent(e:Event):void {
        this._loading.x = this.stage.stageWidth / 2;
        this._loading.y = this.stage.stageHeight / 2;
        this.graphics.clear();
        var matr:Matrix = new Matrix();
        matr.createGradientBox(this.stage.stageWidth, this.stage.stageHeight, 80, 0, 0);
        //this.graphics.beginGradientFill(GradientType.LINEAR, [0x421C4F,0xD84EBA], [1, 1], [0x00, 0xFF],matr);
       // this.graphics.beginFill(0xF6F1EB);
        this.graphics.beginFill(0xfefefe);

        this.graphics.drawRect(0, 0, this.stage.stageWidth, this.stage.stageHeight);
        this.graphics.endFill();
    }

    public function set progressValue(_value:Number):void {
        if (this._loading) {
            this._loading.txt.text = int(_value) + "%";
        }
        _loading.mcView.width=(_value/100)*725;
    }

    public function set infoText(_value:String):void {
        if (this._loading) {
            this._loading.info_txt.text = _value;
        }
    }
}
}