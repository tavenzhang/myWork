package com.rover022.p2pPlay {
//import com.junkbyte.console.Cc;

import flash.events.Event;
import flash.events.NetStatusEvent;
import flash.media.H264Level;
import flash.media.H264Profile;
import flash.media.H264VideoStreamSettings;
import flash.net.GroupSpecifier;
import flash.net.NetConnection;
import flash.net.NetGroup;
import flash.net.NetStream;
import flash.utils.clearInterval;

public class livep2p extends BaseLiveP2P {
    private var groupID:String = "oneRoom";
    private var rtmfp:String = "";// "rtmfp://p2p.rtmfp.net/d8c6d5b18ddf65bf1529fd4c-c98c749416ce/";
    private var nc:NetConnection;
    private var ns:NetStream;
    private var gsp2p:GroupSpecifier;
    private var nsg:NetGroup;
    private var nsrtmp:NetStream;
    private var _flv:String = "";
    private var _isPlay:Boolean = true;
    private var _rejected:Boolean = false;
    private var _max_try:int = 0;
    private var _tiemId:uint = 0;

    private var _lastPalyTime:int = 0;


    public function livep2p() {
    }

    private function startNet():void {
        if (this._rejected) {
            this.dispatchEvent(new Event(super.P2PFailedEvent));
            return;
        }
        if (this.nc) {
            if (this.nc.connected) {
                this.initStream();
            }
            return;
        }
        this.nc = new NetConnection();
        this.nc.client = this;
        this.nc.addEventListener(NetStatusEvent.NET_STATUS, _netStatusEvent);
        this.nc.connect("rtmfp://p2p.rtmfp.net", "aac5d130a67bf339af3730a3-a09364ca5a0d");
    }

    private function _netStatusEvent(e:NetStatusEvent):void {
        //Cc.log("p2pNetStatusEvent ====================== " + e.info.code+"--------="+e.info.name);
        switch (e.info.code) {
            case "NetConnection.Connect.Success":
                this.initP2P();
                break;
            case "NetGroup.Connect.Success":
                this.initStream();
                break;
            case "NetStream.Play.Start":
                this.dispatchEvent(new Event(super.P2PPlayEvent));
                break;
            case "NetStream.Buffer.Full":
                this.dispatchEvent(new Event(super.P2PFullEvent));
                clearInterval(_tiemId);
                //  _tiemId=setInterval(startCount,1000);
                // _max_try=0;
                break;
            case "NetStream.Publish.Start":
                this.dispatchEvent(new Event(super.P2PPublishEvent));
                break;
            case "NetGroup.MulticastStream.PublishNotify":
                this.formatStream();
                break;
            case  "NetStream.Play.UnpublishNotify":
                if (this._isPlay && this._flv == e.info.name) {
                    close();
                }
                break;
            case "NetGroup.MulticastStream.UnpublishNotify":
//                if (this._isPlay && this._flv == e.info.name) {
//                    this.dispatchEvent(new Event(super.P2PNetStreamStop))
//                }
                break;
            case "NetGroup.Connect.Failed":
            case "NetGroup.Connect.Rejected":
                this._rejected = true;
            case "NetStream.Connect.Rejected":
            case "NetConnection.Connect.Rejected":
            case "NetConnection.Connect.Failed":
            case "NetStream.Connect.Closed":
                this.dispatchEvent(new Event(super.P2PFailedEvent));
                break;
            case "NetStream.Play.Stop":
            case "NetGroup.Neighbor.Disconnect":
                // this.dispatchEvent(new Event(super.P2PNetStreamStop));
                break;
            case "NetGroup.Neighbor.Connect":
                trace("e.info==" + e.info);
                break;

            default:
        }
    }

    //
    private function startCount():void {
        //Cc.log("_max_try=" + _max_try);
        if (this.ns && this.nc) {
            //trace("this.ns.time=="+this.ns.time);
            if (this._lastPalyTime != this.ns.time) {
                _lastPalyTime = this.ns.time;
            }
            else {
                _max_try++;
                if (_max_try >= 2) {
                    this.dispatchEvent(new Event(super.P2PNetStreamStop));
                    clearInterval(_tiemId);
                }
            }
        }
        if (this.nsg) {
            trace(" this.nsg.estimatedMemberCount========== " + this.nsg.estimatedMemberCount);
            trace(" this.nsg.neighborCount========== " + this.nsg.neighborCount);
        }
    }


    private function initP2P():void {
        if (!this.gsp2p) {
            this.gsp2p = new GroupSpecifier(this.groupID);
            this.gsp2p.multicastEnabled = true;
            this.gsp2p.serverChannelEnabled = true;
            this.gsp2p.postingEnabled = true;0
        }
        if (this.nsg) {
            this.nsg.removeEventListener(NetStatusEvent.NET_STATUS, _netStatusEvent);
            this.nsg.close();
            this.nsg = null;
        }
        this.nsg = new NetGroup(this.nc, this.gsp2p.groupspecWithAuthorizations());
        this.nsg.addEventListener(NetStatusEvent.NET_STATUS, _netStatusEvent);
    }

    override public function initStream():void {
        if (this.ns) {
            return;
        }
        this.ns = new NetStream(this.nc, this.gsp2p.groupspecWithAuthorizations());
        var _obj:Object = {};
        this.ns.client = _obj;
        this.ns.addEventListener(NetStatusEvent.NET_STATUS, _netStatusEvent);
        this.formatStream();
    }

    override public function formatStream():void {
        if (!this.ns) {
            return;
        }
        if (this._isPlay) {//是用户
            this.ns.play(this._flv);
            this.ns.bufferTime = 3;
            if (this.video) {
                this.video.attachNetStream(this.ns);
            }
        } else {
            if (this.cam) {
                this.ns.attachCamera(this.cam);
            }
            if (this.mir) {
                this.ns.attachAudio(this.mir);
            }
            if (this.nc) {
                this.nc.maxPeerConnections = 3; //如果是主播 需要限制一下p2p 的连接数  以免影响正常rtmp 流上传 默认是8 先尝试 2
                this.ns.multicastPushNeighborLimit = 3;
            }
            var h264:H264VideoStreamSettings = new H264VideoStreamSettings();
            h264.setProfileLevel(H264Profile.MAIN, H264Level.LEVEL_3_1);
            this.ns.videoStreamSettings = h264;
            this.ns.publish(this._flv);
        }
    }


    private function closeNetStream():void {
        if (!this.ns) {
            return;
        }
        if (this._isPlay) {//是用户
            if (this.video) {
                this.video.clear();
                this.ns.pause();
                this.video.attachNetStream(null);
                this.video.attachNetStream(null);
            }
        } else {
            if (this.video) {
                this.video.clear();
                this.video.attachCamera(null);
            }
        }
        this.ns.removeEventListener(NetStatusEvent.NET_STATUS, _netStatusEvent);
        this.ns.close();
        this.ns = null;
    }

    private function closeNet():void {
        if (!this.nc) {
            return;
        }
        this.nc.removeEventListener(NetStatusEvent.NET_STATUS, _netStatusEvent);
        this.nc.close();
        this.nc = null;
    }

    override public function close(_bool:Boolean = true):void {
        this.closeNetStream();
        this.closeNet();
        if (_bool) {
            this.dispatchEvent(new Event(super.P2PCloseEvent));
        }
    }

    override public function play(_flv:String, _roomid:* = ""):void {
        _roomid = _roomid.toString();
        if (_roomid == "" || this.groupID == _roomid) {
            this.closeNetStream();
        } else {
            this.close(false);
            this.groupID = _roomid;
        }
        this._isPlay = true;
        this._flv = _flv;
        this.startNet();
    }

    override public function publish(_flv:String, _roomid:* = ""):void {
        _roomid = _roomid.toString();
        if (_roomid == "" || this.groupID == _roomid) {
            this.closeNetStream();
        } else {
            this.close(false);
            this.groupID = _roomid;
        }
        this._isPlay = false;
        this._flv = _flv;
        this.startNet();
    }
}
}