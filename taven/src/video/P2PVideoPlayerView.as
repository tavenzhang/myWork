/**
 * Created by Administrator on 2015/11/16.
 */
package video {
import com.junkbyte.console.Cc;
import com.rover022.ModuleNameType;
import com.rover022.p2pPlay.BaseLiveP2P;

import flash.events.Event;
import flash.utils.setTimeout;

public class P2PVideoPlayerView extends VideoPlayerView {
    //p2p 第一次开启p2p 记录 每次 刷新rmtp 都会重置
    private var _p2pFirstStart:Boolean = false;
    //p2p主播流
    private var _liveP2P:BaseLiveP2P;
    //是否处于p2p 模式中
    private var _isP2PStyle:Boolean = false;

    public function P2PVideoPlayerView() {
        super();
    }

    private function tryP2PPlay():Boolean {
        var result:Boolean = false;
        if (_liveP2P) //如果支持p2p 尝试p2p播放
        {
            _liveP2P.video = this.video_mc;
            _liveP2P.play(this.flvName, videoRoom.getDataByName(ModuleNameType.USERROOMDATA).roomid);
            _p2pFirstStart = true;
            result         = true;
            Cc.log("p2p try conenct... ---rommId=" + videoRoom.getDataByName(ModuleNameType.USERROOMDATA).roomid);
        }
        return result;
    }

    // 重置播放 如果是用户则播放
    override protected function rePlay():void {
        super.rePlay();
        if (!tryP2PPlay()) {
            Cc.log("最终播放线路 rtmp=" + this.nc.uri + "----sid=" + this.flvName);
        }
    }

    //开启p2p模式
    public function startP2p(p2p:BaseLiveP2P):void {
        _liveP2P = p2p;
        _liveP2P.addEventListener(_liveP2P.P2PFailedEvent, P2pStatueEvent);
        _liveP2P.addEventListener(_liveP2P.P2PPlayEvent, P2pStatueEvent);
        _liveP2P.addEventListener(_liveP2P.P2PCloseEvent, P2pStatueEvent);
        _liveP2P.addEventListener(_liveP2P.P2PPublishEvent, P2pStatueEvent);
        _liveP2P.addEventListener(_liveP2P.P2PFullEvent, P2pStatueEvent);
        _liveP2P.addEventListener(_liveP2P.P2PNetStreamStop, P2pStatueEvent);
    }

    public function updateStreamStyle(isP2p:Boolean):void {
        this.video_mc.visible = true;
        this.reconCount       = 0;// 当获得播放数据流时，重置连接次数
        if (isP2p) {
            if (rtmpReadyOK) {
                _isP2PStyle = false;
                closetP2p()
            }
            else {
                _isP2PStyle = true;
                if (this.ns) {
                    this.ns.pause();
                }
                if (_liveP2P.video == null) {
                    _liveP2P.video = this.video_mc;
                    _liveP2P.formatStream();
                }
                Cc.log("最终播放线路-----------------------------------------p2pStream");
            }
        }
        else {
            if (!_isP2PStyle) //如果 rtmpReadyOK 准备好之前  p2p没有准备好 就用正常流 把p2p流关掉
            {
                rtmpReadyOK = true;
                closetP2p()
            }
        }
    }

    //关闭p2p数据流
    private function closetP2p():void {
        if (_liveP2P && !_isP2PStyle) {
            _liveP2P.close();
        }
    }

    //p2p状态
    private function P2pStatueEvent(evt:Event):void {
        switch (evt.type) {
            case _liveP2P.P2PFailedEvent:
            case  _liveP2P.P2PCloseEvent:
                _isP2PStyle = false;
                if (this.isAnchor) //如果是主播 p2p失败
                {
                    _liveP2P.cam = null;
                    _liveP2P.mir = null;
                    Cc.log("主播p2p线路 发布失败");
                }
                else {
                    if (this.ns && _liveP2P.video == this.video_mc && rtmpReadyOK) {
                        this.video_mc.attachNetStream(this.ns); //如果p2p udp 有问题 用正常rtmp流
                        this.ns.resume();
                        Cc.log("最终播放线路 rtmp=" + this.nc.uri + "----sid=" + this.flvName);
                        _liveP2P.video = null;
                        _isP2PStyle    = false;
                    }
                }
                break;
            case  _liveP2P.P2PPlayEvent:
                break;
            case _liveP2P.P2PFullEvent:
                //进行使用流判定
                updateStreamStyle(true);
                break;
            case _liveP2P.P2PPublishEvent://如果p2p发布正常
                Cc.log("p2p线路同时开启");
                this.video_mc.visible = true;
                break;
            case _liveP2P.P2PNetStreamStop://P2p视频播放断开
                Cc.log("p2p视频流断了");
                if (_isP2PStyle && !isAnchor && !isCloseRestConnectRtmp) //如果是p2p模式 并且非主播 非正常关闭rtmp
                {
                    _liveP2P.play(this.flvName, videoRoom.getDataByName(ModuleNameType.USERROOMDATA).roomid);
                    Cc.log("p2p视频进行重连");
                }
                break;
        }
    }

    //断开上传流
    override public function closePublish():void {
        super.closePublish();
        if (_liveP2P) {
            _liveP2P.close();
        }
    }

    //用户播放
    override public function playRTMP(_flv:String, _rtmp:String):void {
        super.playRTMP(_flv, _rtmp);
        //3秒后开启p2p 测试
        _isP2PStyle    = false;
        _p2pFirstStart = false;
        setTimeout(firstP2PNec, 3000)
    }

    //主播
    override public function publish(_flv:String, _rtmp:String):void {
        super.publish(_flv, _rtmp);
        _isP2PStyle = false;
    }

    override public function closeRtmpNoResetConnect():void {
        super.closeRtmpNoResetConnect();
        if (nc) {
            _isP2PStyle = false;
            if (_liveP2P) {
                _liveP2P.close();
            }
        }
    }

    //重置上传,如果中断,需要重新上传
    override public function rePublish():void {
        super.rePublish();
        //正常 发布的同时 也向adobe Cirrus注册p2p
        _liveP2P.cam = this.cam;
        _liveP2P.mir = this.mic;
        _liveP2P.publish(this.flvName, videoRoom.getDataByName(ModuleNameType.USERROOMDATA).roomid);
    }

    private function firstP2PNec():void {
        if (!_p2pFirstStart) {
            tryP2PPlay()
        }
    }
}
}
