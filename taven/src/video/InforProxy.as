/**
 * Created by chenbin on 2015/8/17.
 */
package video {
import com.rover022.ModuleNameType;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.NetStream;
import flash.net.URLRequest;


/**
 * 信息收集器
 */
public class InforProxy {
    private var _videoPlayerView:VideoPlayerView;
   // public var addressArray:Array = ["http://vlog1.gagaten.com/index.html", "http://vlog2.gagaten.com/index.html"];
    public var addressArray:Array = ["", ""];
    public var count:int = 0;
    public var messageCount:Number = 0;

    public function InforProxy(videoPlayerView:VideoPlayerView) {
        _videoPlayerView = videoPlayerView;
    }

    public function sendInforToServer(isP2p:Boolean):void {
        var urlLoader:CURLLoader = new CURLLoader();
        if (_videoPlayerView.nc && _videoPlayerView.nc.connected) {
            var nsValue:NetStream = _videoPlayerView.ns;
        } else {
            nsValue = null;
        }
        var ursString:String = getInforMessage(addressArray[count], nsValue, isP2p);
        urlLoader.load(new URLRequest(ursString));
        urlLoader.addEventListener(Event.COMPLETE, function (e:Event):void {
        });
        urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
        urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onIOError);
        //trace("sendInforToServer", count)
    }

    public function onIOError(event:IOErrorEvent):void {
        //trace("onIOError")
        var urlLoader:CURLLoader = event.currentTarget as CURLLoader;
        if (urlLoader.count < 1) {
            urlLoader.count++;
            //指针移动位置
            //trace("指针移动位置")
            count++;
            if (count >= addressArray.length) {
                count = 0;
                //trace("归位")
            }
        }
    }

    public function getInforMessage(_mains:String, ns:NetStream, isp2p:Boolean = false):String {
        var userObj:Object = _videoPlayerView.videoRoom.getDataByName(ModuleNameType.USERDATA);

        if (userObj == null) {
            userObj = {};
        }
        if (ns == null) {
            var obj:Object = {};
            return "";
        } else {
            obj = ns.info;
        }
        messageCount++;
        var ursString:String = _mains + "?droppedFrames=" + obj.droppedFrames;
        ursString += "&maxBytesPerSecond=" + obj.maxBytesPerSecond;
        ursString += "&playbackBytesPerSecond=" + obj.playbackBytesPerSecond;
        ursString += "&resourceName=" + obj.resourceName;
        ursString += "&videoBufferByteLength=" + obj.videoBufferByteLength;
        ursString += "&videoBufferLength=" + obj.videoBufferLength;
        ursString += "&videoByteCount=" + obj.videoByteCount;
        ursString += "&videoBytesPerSecond=" + obj.videoBytesPerSecond;
        ursString += "&currentBytesPerSecond=" + obj.currentBytesPerSecond;
        ursString += "&audioBytesPerSecond=" + obj.audioBytesPerSecond;
        ursString += "&dataBytesPerSecond=" + obj.dataBytesPerSecond;
        ursString += "&maxBytesPerSecond=" + obj.maxBytesPerSecond;
        // ursString += "&playbackBytesPerSecond=" + obj.playbackBytesPerSecond;
        //临时调整用于判断当前是否是用户还是主播 1 是主播 0 是用户
        ursString += "&playbackBytesPerSecond=" + ((_videoPlayerView.videoRoom.getDataByName(ModuleNameType.USERDATA).ruled) == 3 ? 1 : 0);
        //临时调整用于判断当前是否是p2p连接 还是 正常rtmp
        ursString += "&ncConnect=" + isp2p == true ? "true" : "false";
        ursString += "&count=" + messageCount;
        ursString += "&roomid=" + _videoPlayerView.videoRoom.getDataByName(ModuleNameType.USERROOMDATA).roomid;
        ursString += "&uid=" + userObj.uid;
        ursString += "&socket=" + _videoPlayerView.videoRoom.getDataByName(ModuleNameType.SOCKETADDRESS);
        ursString += "&rtmp=" + _videoPlayerView.videoRoom.getDataByName(ModuleNameType.RTMPADDRESS);
        ursString += "&isSocketConnect=" + _videoPlayerView.videoRoom.getDataByName(ModuleNameType.SOCKETISCONNECT);
        ursString += "&random=" + Math.random();
        return ursString;
    }
}
}

import flash.net.URLLoader;

class CURLLoader extends URLLoader {
    public var count:int = 0;
}