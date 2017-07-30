package net {
import com.junkbyte.console.Cc;
import com.rover022.CBProtocol;
import com.rover022.IPlayer;
import com.rover022.ModuleNameType;

import display.ui.Alert;
import display.ui.MaskLoaderMc;

import com.rover022.event.ModuleEvent;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.VideoEvent;
import flash.external.ExternalInterface;
import flash.net.Socket;
import flash.utils.ByteArray;
import flash.utils.clearTimeout;
import flash.utils.getTimer;
import flash.utils.setInterval;
import flash.utils.setTimeout;

import ghostcat.manager.RootManager;

import manger.ClientManger;
import manger.ModuleLoaderManger;
import manger.DataCenterManger;

import tool.VideoTool;

public class NetManager extends EventDispatcher {
    private static var _instance:NetManager;
    public var netHost:String = "";
    public var netPort:int = 843;
    public var userCode:String = "";
    public var roomID:int = 0;
    public var roomPass:String = "";
    public var appInit:Boolean = false;
    public var client:* = null;
    public var socketClient:Socket;
    public var connectionErrorCount:uint = 0;
    public static var SERVERCLOSECLIENT:uint = 10000;
    public var maxConnectTime:int = 9;
    public var ASEkey:String;
    //socket断开时候的时间
    private var disConnectedTime:int = getTimer();
    private var _connectTimecost:int=0;

    public function getSelfRoomId():int {
        return roomID;
    }

    public function NetManager():void {
        setInterval(_heartTimerEvent, 9000);
        socketClient = new NetSocket(_instance);
        socketClient.timeout = 12000;
        socketClient.objectEncoding = 3;
        socketClient.addEventListener(Event.CONNECT, onConnectEvent);
        socketClient.addEventListener(Event.CLOSE, onCloseHandler);
        socketClient.addEventListener(IOErrorEvent.IO_ERROR, onIOErrorHandler);
        socketClient.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _securityErrorHandler);
    }

    public static function getInstance():NetManager {
        if (_instance == null) {
            _instance = new NetManager();
        }
        //每隔9秒调用注册js行数 roger
        return _instance;
    }

    private function _heartTimerEvent():void {
        if (ASEkey != null) {
            sendDataObject({cmd: CBProtocol.ping, msg: getTimer()});
        }
        checkSocketState();
    }

    //检测socket连接状态 如果超过3分钟 socket 还是断开的状态 试图去关闭rmtp流
    private function checkSocketState():void {
        if (socketClient.connected == false) {
            trace("socket 是断开的", "经过时间:", getTimer() - disConnectedTime, "毫秒");
            if (getTimer() - disConnectedTime > 60 * 1000 * 3) {
                RootManager.stage.dispatchEvent(new VideoEvent(ModuleEvent.CLOSE_ALL_RTMP_BY_SOCKET));
            }
        } else {
            disConnectedTime = getTimer();
        }
    }

    public function connectSocket(_host:String, _port:int, _roomid:int = 0, _loginKey:String = "0000"):void {

        roomID = _roomid;
        if(_loginKey=="")
        {
            _loginKey="0000";
        }
        userCode = _loginKey;
        netHost = _host;
        netPort = _port;
        Cc.log("Cc开始连接Socket..." + _host + ":" + _port, "程序运行了:", getTimer());
        _connectTimecost = getTimer();
        socketClient.connect(_host, _port);
    }

    public function createKey(src:String):void {
        ASEkey = src;
        //var key1:ASE
        connectRoom();
    }

    /**
     * 进入房价
     * 1加密判断
     * 2是否主播在发布判断
     */
    public function connectRoom():void {
        if (ASEkey == null) {
            Cc.log("钥匙没建立");
            return;
        }
        if (socketClient.connected == false) {
            Cc.log("连接没建立");
            return;
        }
        if (appInit == false) {
            Cc.log("appUI没建立");
            return;
        }
        var iPlay:IPlayer = ModuleLoaderManger.getInstance().getModule(ModuleNameType.VIDEOPLAYER) as IPlayer;
        var _isPulish:Boolean = false;
        var _playurl:String = "";
        var _playSid:String = "";
        if (iPlay) {
            _isPulish = iPlay.isGetMic;
            if (iPlay["nc"]) {
                _playurl = iPlay["nc"].uri;
                _playSid = iPlay["flvName"];
            }
        }

        var _sting:String = userCode + roomID + "73uxh9*@(58u)fgxt";
        var passw:String = VideoTool.buildAseString(ASEkey, _sting);
        sendDataObject({
            "key": userCode,
            "roomid": roomID,
            "pass": roomPass,
            "roomLimit": passw,
            "isPulish": _isPulish,
            "pulishUrl": _playurl,
            "sid": _playSid,
            "cmd": 10001
        });
    }

    /**
     * 去拿服务器的钥匙
     */
    public function connectServerASEkey():void {
        sendDataObject({
            "cmd": 10000
        });
    }

    /**
     * 重新连接服务器;
     */
    public function resetConnect():void {
        Cc.log("socket重新开始连接...");
        socketClient.connect(netHost, netPort);
        ClientManger.getInstance().addChatSpanMessage({
            message: "开始第" + connectionErrorCount + "次重新连接socket服务器!",
            color: "0xFF00FF"
        });
    }

    private function onConnectEvent(e:Event):void {
        _connectTimecost = getTimer() - _connectTimecost;
        Cc.log(netHost + ":", "连接成功"+"------------------------connectTime="+_connectTimecost);
        connectServerASEkey();
    }

    /**
     * 听到断开事件后的重新连接动作
     * @param e
     */
    public function onCloseHandler(e:Event = null):void {
        Cc.log("SOCKET 后台小弟侦听到SOCKET断开事件.....");
        disConnectedTime = getTimer();
        ClientManger.getInstance().addChatSpanMessage({message: "Socket连接已断开...", color: "0xFF00FF"});
        reConnectServer();
    }

    private var _resetID:uint;

    /**
     * 重新连接服务器 加入延时3秒机制
     */
    public function reConnectServer():void {
        var playModule:IPlayer = ModuleLoaderManger.getInstance().getModule(ModuleNameType.VIDEOPLAYER) as IPlayer;
        if (playModule) {
            playModule.updatePer30Second();
        }
        if (connectionErrorCount == NetManager.SERVERCLOSECLIENT) {
            return;
        }
        connectionErrorCount++;
        if (connectionErrorCount <= maxConnectTime) {
            Cc.log("socket 断开 3秒之后重新连接...第" + (connectionErrorCount ) + "次");
            //出现一个提示显示信息
            var _maskMc:MaskLoaderMc = new MaskLoaderMc(connectionErrorCount);
            RootManager.root.addChild(_maskMc);
            clearTimeout(_resetID);
            _resetID = setTimeout(resetConnect, 3000);
        } else {
            Alert.Show("您的socket链接断了，点击确认按钮,再次帮你重新尝试连接。", "警告", true, 3, false, function ():void {
                connectionErrorCount = 0;
                reConnectServer();
            });
            //Alert.Show("后台小弟太累了,重连次数超过8次");
        }
    }

    private function onIOErrorHandler(e:IOErrorEvent):void {
        Cc.log("socketIO错误.." + e);
        //resetConnect();
        ClientManger.getInstance().addChatSpanMessage({message: "SocketIO连接错误..请检查你的网络环境.", color: "0xFF00FF"});
        reConnectServer();
    }

    /**
     * 重新加载页面
     */
    public function reLoaderPage():void {
        if (ExternalInterface.available) {
            ExternalInterface.call("window.location.reload");
        }
    }

    private function _securityErrorHandler(e:SecurityErrorEvent):void {
        Cc.log("socket安全沙箱错误." + e);
        resetConnect();
    }

    public function sendDataObject(_obj:Object, cmd:int = -1):void {
        if (socketClient == null || socketClient.connected == false) {
            return;
        }

        try {
            if (cmd != -1 || !_obj.hasOwnProperty("cmd")) {
                _obj.cmd = cmd;
            }
            var _byteArray:ByteArray = new ByteArray();
            _byteArray.writeObject(_obj);
            _byteArray.compress();
            socketClient.writeBytes(_byteArray);
            socketClient.writeUTF("\r\n");
            socketClient.flush();
            if (DataCenterManger.filterCMDArray.indexOf(_obj.cmd) == -1) {
                Cc.logch("taven", "-->" + _obj.cmd + "," + JSON.stringify(_obj));
            }
        } catch (e:*) {
            Cc.log("NetManager->sendDataObject:" + e);
        }
    }

    public function closeSocket():void {
        if (socketClient.connected) {
            socketClient.close();
            ClientManger.getInstance().addChatSpanMessage({message: "后台小弟已经把Socket中断...", color: "0xFF00FF"});
        }
    }
}
}