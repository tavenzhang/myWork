package com.kingjoy.view {
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.external.ExternalInterface;
import flash.geom.Matrix;

import ghostcat.manager.RootManager;

public class LoadUI extends Sprite {
    private var _loading:MovieClip;
    public static var loadingUI:LoadUI;


    public function LoadUI() {
        this._loading = new loading_res();
        if (!this._loading) {
            return;
        }
        this.addChild(this._loading);
        this.addEventListener(Event.ADDED_TO_STAGE, _addedToStageEvent);
        this.addEventListener(Event.REMOVED_FROM_STAGE, _removedFromStageEvent);
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

        //   this.stopAllMovieClips();
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
        this.graphics.beginFill(0xF6F1EB);
        this.graphics.drawRect(0, 0, this.stage.stageWidth, this.stage.stageHeight);
        this.graphics.endFill();
    }

    public function set progressValue(_value:Number):void {
        if (this._loading) {
            this._loading.txt.text = int(_value) + "%";
        }
    }

    public function set infoText(_value:String):void {
        if (this._loading) {
            this._loading.info_txt.text = _value;
        }
    }

}
}