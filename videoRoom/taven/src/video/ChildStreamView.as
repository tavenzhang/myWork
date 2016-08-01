package video {
import flash.display.Sprite;
import flash.events.Event;
import flash.events.NetStatusEvent;
import flash.events.TimerEvent;
import flash.geom.Rectangle;
import flash.media.Microphone;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.utils.Timer;

import sk.video.videobaseMap;

public class ChildStreamView extends Sprite {
    private var videoBase:ScaleBitmap;
    private var nc:NetConnection;
    private var ns:NetStream;
    private var video_mc:Video;
    public var flvName:String = "";//flv名字;
    private var statusValue:int = 0;

    private var checkPlayTimer:Timer;
    private var _playOldTimer:int = 0;
    public var parentOwner:VideoPlayerView;
    private var mic:Microphone;

    public function ChildStreamView(_nc:NetConnection = null):void {
        this.videoBase = new ScaleBitmap(new videobaseMap(87, 76));
        this.videoBase.scale9Grid = new Rectangle(20, 20, 10, 10);
        this.videoBase.width = 170;
        this.videoBase.height = 130;
        //this.addChildAt(this.videoBase, 0);

        this.video_mc = new Video();
        this.video_mc.x = 5;
        this.video_mc.y = 5;
        this.addChild(this.video_mc);

        this.checkPlayTimer = new Timer(15000);
        this.checkPlayTimer.addEventListener(TimerEvent.TIMER, _checkPlayTimerEvent);

        this.nc = _nc;
        this.nc.addEventListener(NetStatusEvent.NET_STATUS, _netStatusEvent);
    }

    //播放防假死
    private function _checkPlayTimerEvent(e:TimerEvent):void {
        if (this.ns) {
            if (this._playOldTimer == int(this.ns.time)) {
                this.checkPlayTimer.stop();

                if (this.statusValue == 1) {//视频流,没信号,重连
                    this.initStream();
                } else {//音频流
                    //没信号,直接关闭流
                    this.close();
                }
            } else {
                this._playOldTimer = int(this.ns.time);
            }
        }
    }

    //-------------------width
    override public function get width():Number {
        return this.video_mc.width;
    }

    override public function set width(value:Number):void {
        this.video_mc.width = value;
        this.videoBase.width = value + 10;
    }

    //-------------------height
    override public function get height():Number {
        return this.video_mc.height;
    }

    override public function set height(value:Number):void {
        this.video_mc.height = value;
        this.videoBase.height = value + 10;
    }

    //--------------
    private function _netStatusEvent(e:NetStatusEvent):void {
        switch (e.info.code) {
            case "NetConnection.Connect.Success"://失败重连成功后,继续发布
                this.initStream();//初始视频流
                break;
            case "NetStream.Publish.Start"://成功发布流
                if (this.statusValue == 22) {//音频播放结束
                    this.infoText = "发言中.";
                }
                break;
            case "NetStream.Publish.BadName"://Error 流发布失败,已被人发布
                this.infoText = "对不起,流被占用,无法发言."
                this.dispatchEvent(new Event("publishAudioComplete"));
                break;
            case "NetStream.Record.NoAccess"://Error 录制出错..严重bug
            case "NetStream.Record.Failed"://Error
                this.infoText = "对不起,您没有录制权限."
                this.dispatchEvent(new Event("publishAudioComplete"));
                break;
            case "NetStream.Play.Start"://连上开始播放
                if (this.statusValue == 1) {//音频播放结束
                    this.infoText = "新主播加入.";
                } else {
                    this.infoText = "开始互动.";
                }
                break;
            case "NetStream.Play.Stop":
            case "NetStream.Play.UnpublishNotify"://主播离开
                if (this.statusValue == 2) {//音频播放结束
                    this.infoText = "交流结束.";
                    this.close();
                }
                break;
            default:
        }
    }

    private function set infoText(_v:String):void {
        if (this.parentOwner) {
            this.parentOwner.infoText = _v;
        }
    }

    private function initStream():void {
        if (this.checkPlayTimer) {//取消较验时间事件
            this.checkPlayTimer.stop();
        }
        this.video_mc.attachNetStream(null);

        if (!this.nc) {//没有连接,断开
            return;
        }
        if (this.ns) {
            this.ns.removeEventListener(NetStatusEvent.NET_STATUS, _netStatusEvent);
            this.ns.attachAudio(null);
            this.ns.attachCamera(null);
            this.ns.close();
            this.ns = null;
        }
        if (!(this.nc && this.nc.connected)) {
            this.close();
            return;
        }
        this.ns = new NetStream(this.nc);
        this.ns.client = this;
        this.ns.addEventListener(NetStatusEvent.NET_STATUS, _netStatusEvent);

        switch (this.statusValue) {
            case 1://视频流
            case 2://音频
                this.ns.play(this.flvName);
                this.video_mc.attachNetStream(this.ns);

                this._playOldTimer == 0
                this.checkPlayTimer.reset();
                this.checkPlayTimer.start();
                break;
            case 22:
                this.ns.attachAudio(this.mic);
                this.ns.publish(this.flvName);
                break;
            default:
        }
    }

    public function playVideo(_flvName:String):void {
        this.flvName = _flvName;
        this.statusValue = 1
        this.initStream();
    }

    public function playAudio(_flvName:String):void {
        this.flvName = _flvName;
        this.statusValue = 2
        this.initStream();
    }

    public function publishAudio(_flvName:String, _mic:Microphone):void {
        this.mic = _mic;
        this.flvName = _flvName;
        this.statusValue = 22
        this.initStream();
    }

    public function onMetaData(...rest):void {
    }

    public function close():void {
        if (this.checkPlayTimer) {
            this.checkPlayTimer.stop();
            this.checkPlayTimer.removeEventListener(TimerEvent.TIMER, _checkPlayTimerEvent);
        }

        if (this.nc) {
            this.nc.removeEventListener(NetStatusEvent.NET_STATUS, _netStatusEvent);
        }
        try {
            if (this.ns) {
                this.ns.removeEventListener(NetStatusEvent.NET_STATUS, _netStatusEvent);
                this.ns.attachAudio(null);
                this.ns.attachCamera(null);
                this.ns.close();
            }
        } catch (e:*) {

        }

        this.video_mc.attachNetStream(null);
        this.removeChild(this.video_mc);

        this.nc = null;
        this.ns = null;
        this.video_mc = null;
        this.checkPlayTimer = null;
        this.parentOwner = null;
    }
}
}