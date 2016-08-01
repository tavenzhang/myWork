/**
 * Created by zhangxinhua on 15/10/15.
 */
package com.rover022.p2pPlay {
import com.junkbyte.console.Cc;

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

public class MonaP2P extends BaseLiveP2P {
    private var groupID:String = "oneRoom"
    private var rtmfp:String ="rtmfp://10.1.80.239/"; //rtmfp://p2p.rtmfp.net/d8c6d5b18ddf65bf1529fd4c-c98c749416ce/";
    private var nc:NetConnection;
    private var ns:NetStream;
    private var gsp2p:GroupSpecifier;
    //组播
    private var nsg:NetGroup;
    private var _flv:String = "";
    private var _isPlay:Boolean = true;
    private var _rejected:Boolean = false;
    private var  _max_try:int = 0;
    private var _tiemId:uint=0;

    private var _lastPalyTime:int =0;


    private function initNetGroup(groupId:String):void {
        if (!this.gsp2p) {
            this.gsp2p = new GroupSpecifier(groupId);
            this.gsp2p.multicastEnabled = true;
            this.gsp2p.serverChannelEnabled = true;
            this.gsp2p.postingEnabled = true;
            this.gsp2p.ipMulticastMemberUpdatesEnabled=true;
//            if(!_isPlay)
//            {
//                this.gsp2p.peerToPeerDisabled=true;好好
//            }
           // this.gsp2p.peerToPeerDisabled=true;
        }
        if (this.nsg) {
            this.nsg.removeEventListener(NetStatusEvent.NET_STATUS, netGroupStatusEvent);
            this.nsg.close();
            this.nsg = null;
        }
        this.nsg = new NetGroup(this.nc, this.gsp2p.groupspecWithAuthorizations());
        this.nsg.addEventListener(NetStatusEvent.NET_STATUS, netGroupStatusEvent);
    }

    private function initNetConnect():void {
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
        this.nc.addEventListener(NetStatusEvent.NET_STATUS,netStramStatusEvent);

        if (!_isPlay) {
            this.nc.maxPeerConnections = 2; //如果是主播 需要限制一下p2p 的连接数  以免影响正常rtmp 流上传 默认是8 先尝试 2
           // this.ns.multicastPushNeighborLimit = 3;
        }
        this.nc.connect(rtmfp);
    }

    override public function initStream():void {
        if (this.ns) {
            return;
        }
        this.ns = new NetStream(this.nc, this.gsp2p.groupspecWithAuthorizations());
        var _obj:Object = new Object;
        this.ns.client = _obj;
        this.ns.addEventListener(NetStatusEvent.NET_STATUS, netStramStatusEvent);
        this.formatStream();
    }

    private function netStramStatusEvent(e:NetStatusEvent):void
    {
        Cc.log("p2pStramStatusEvent ====================== " + e.info.code+"--------="+e.info.name);

        switch (e.info.code) {
            case "NetConnection.Connect.Success":
                this.initNetGroup(this.groupID);
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
                break;
            case "NetStream.Publish.Start":
                this.dispatchEvent(new Event(super.P2PPublishEvent));
                break;
            case  "NetStream.Play.UnpublishNotify":
                if (this._isPlay && this._flv == e.info.name) {
                    close();
                }
                break;
            default:
        }
    }

    private function netGroupStatusEvent(e:NetStatusEvent):void {
        Cc.log("p2pNetGroupStatusEvent====================== " + e.info.code+"--------="+e.info.name);
        switch (e.info.code) {
                // case "NetGroup.MulticastStream.UnpublishNotify":
//                if (this._isPlay && this._flv == e.info.name) {
//                    this.dispatchEvent(new Event(super.P2PNetStreamStop))
//                }
  //              break;
            case "NetGroup.MulticastStream.PublishNotify":
                this.formatStream();
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
                trace("e.info=="+e.info);
                break

            default:
        }
    }

    //
    private function startCount():void
    {
        Cc.log("_max_try="+_max_try);
        if(this.ns&&this.nc)
        {
            //trace("this.ns.time=="+this.ns.time);
            if(this._lastPalyTime!=this.ns.time)
            {
                _lastPalyTime =this.ns.time;
            }
            else
            {
                _max_try++;
                if(_max_try>=2)
                {
                    this.dispatchEvent(new Event(super.P2PNetStreamStop));
                    clearInterval(_tiemId);
                }
            }
        }
        if(this.nsg)
        {
            trace(" this.nsg.estimatedMemberCount========== "+ this.nsg.estimatedMemberCount );
            trace(" this.nsg.neighborCount========== "+ this.nsg.neighborCount);
        }
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
            var h264:H264VideoStreamSettings = new H264VideoStreamSettings();
            h264.setProfileLevel(H264Profile.MAIN, H264Level.LEVEL_3_1);
            this.ns.videoStreamSettings = h264;
            this.ns.publish(this._flv);
            this.ns.multicastPushNeighborLimit = 2;
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
        this.ns.removeEventListener(NetStatusEvent.NET_STATUS, netStramStatusEvent);
        this.ns.close();
        this.ns = null;
    }

    private function closeNet():void {
        if (!this.nc) {
            return;
        }
        this.nc.removeEventListener(NetStatusEvent.NET_STATUS, netStramStatusEvent);
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
        this.initNetConnect();
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
        this.initNetConnect();
    }
}
}
