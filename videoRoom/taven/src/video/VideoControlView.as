package video {
import com.greensock.TweenLite;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Rectangle;
import flash.utils.Timer;

import sk.video.videoControl;

public class VideoControlView extends videoControl {
    public var isMute:Boolean = false;//是否静音
    public var isPause:Boolean = false;//是否暂停
    private var sliderNum:int = 0;//音量系数
    private var rect:Rectangle = new Rectangle(8, 2, 0, 96);
    private var _timer:Timer;
    private var _parent:VideoPlayerView;

    public function VideoControlView(src:VideoPlayerView):void {
        this.slider_mc.mouseChildren      = false;
        this.slider_mc.buttonMode         = true;
        this.speaker_mc.mouseChildren     = false;
        this.speaker_mc.buttonMode        = true;
        this.playControl_mc.mouseChildren = false;
        this.playControl_mc.buttonMode    = true;
        this.speaker_mc.gotoAndStop(1);
        this.playControl_mc.gotoAndStop(1);
        this.locus_mc.gotoAndStop(1);
        this._timer = new Timer(24);
        this._timer.addEventListener(TimerEvent.TIMER, _enterFrameEvent);
        this.report_bt.visible = false;
        this.locus_mc.gotoAndStop(70);
        this.slider_mc.y = 30 * .95;
        this.slider_mc.addEventListener(MouseEvent.MOUSE_DOWN, _mouseDownEvent);
        this.speaker_mc.addEventListener(MouseEvent.CLICK, _speakerClickEvent);
        this.playControl_mc.visible = false;
        //
        _parent = src
        _parent.addEventListener(MouseEvent.ROLL_OVER, _rollOverEvent);
        _parent.addEventListener(MouseEvent.ROLL_OUT, _rollOutEvent);
        addEventListener(Event.CHANGE, controlChangeEvent);
        _parent.addChild(this);
        x = 455;
        y = 140;
    }

    private function _rollOverEvent(e:MouseEvent):void {
        if (visible)
            TweenLite.to(this, .5, {"alpha": 1});
    }

    private function _rollOutEvent(e:MouseEvent):void {
        TweenLite.to(this, .5, {"alpha": 0});
    }

    private function _speakerClickEvent(e:MouseEvent):void {
        this.isMute = !this.isMute;
        if (this.isMute) {
            this.speaker_mc.gotoAndStop(2);
        } else {
            this.speaker_mc.gotoAndStop(1);
        }
        this.dispatchEvent(new Event(Event.CHANGE));
    }

    private function _mouseDownEvent(e:MouseEvent):void {
        this.slider_mc.startDrag(false, this.rect);
        this.addEventListener(MouseEvent.MOUSE_MOVE, _mouseMoveEvent);
        this.slider_mc.addEventListener(MouseEvent.MOUSE_UP, _mouseUpEvent);
        this.addEventListener(MouseEvent.MOUSE_UP, _mouseUpEvent);
        this.addEventListener(MouseEvent.ROLL_OUT, _mouseUpEvent);
    }

    private function _mouseUpEvent(e:MouseEvent):void {
        this.removeEventListener(MouseEvent.MOUSE_MOVE, _mouseMoveEvent);
        this.slider_mc.removeEventListener(MouseEvent.MOUSE_UP, _mouseUpEvent);
        this.removeEventListener(MouseEvent.MOUSE_UP, _mouseUpEvent);
        this.removeEventListener(MouseEvent.ROLL_OUT, _mouseUpEvent);
        this.slider_mc.stopDrag();
        this.locusValue = 100 - int(this.slider_mc.y / 95 * 100);
    }

    private function _mouseMoveEvent(e:MouseEvent):void {
        this.locusValue = 100 - int(this.slider_mc.y / 95 * 100);
    }

    private function set locusValue(_v:int):void {
        this.sliderNum = _v;
        if (this.sliderNum > this.locus_mc.totalFrames) {
            this.sliderNum = this.locus_mc.totalFrames
        } else if (this.sliderNum < 1) {
            this.sliderNum = 1;
        }
        this._timer.start();
    }

    private function _enterFrameEvent(e:TimerEvent):void {
        if (this.sliderNum > this.locus_mc.currentFrame) {
            this.locus_mc.nextFrame();
        } else if (this.sliderNum < this.locus_mc.currentFrame) {
            this.locus_mc.prevFrame();
        } else {
            this._timer.stop();
            this.locus_mc.stop();
        }
        this.dispatchEvent(new Event(Event.CHANGE));
    }

    private function rePlayControl():void {
        this.isPause = false;
        if (this.isPause) {
            this.playControl_mc.gotoAndStop(2);
        } else {
            this.playControl_mc.gotoAndStop(1);
        }
    }

    public function get sliderValue():Number {
        var _v:Number = 0;
        if (this.locus_mc.currentFrame > 1) {
            _v = this.locus_mc.currentFrame / this.locus_mc.totalFrames;
        }
        return _v;
    }

    //*播放/声音控制模块
    public function controlChangeEvent(e:Event = null):void {
        if (this.isMute) {//静音
            _parent.volumeTransform.volume = 0;
        } else {//不静音
            _parent.volumeTransform.volume = this.sliderValue;
        }
        if (_parent.ns) {
            try {
                _parent.ns.soundTransform = _parent.volumeTransform;
            } catch (e:*) {
                trace("VideoPlayerView:设置音量出错...")
            }
        }
    }
}
}