/**
 * Created by Taven on 2015/9/12.
 */
package com.rover022.tool {
import com.junkbyte.console.Cc;
import com.rover022.CBProtocol;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.Socket;
import flash.utils.getTimer;

import ghostcat.ui.layout.Padding;

public class SocketPing {
    public var netHost:String = "";
    public var netPort:int = 843;
    public var client:* = null;
    public var pingTime:uint=0;
    public var socketClient:Socket;
    public var _suceedFun:Function;
    //只要找到1个可用socket 就可以了
    public function SocketPing(host:String, port:int,callSucFun) {
        socketClient = new Socket();
        socketClient.timeout = 12000;
        socketClient.objectEncoding = 3;
        socketClient.addEventListener(Event.CONNECT, onConnectEvent);
        socketClient.addEventListener(Event.CLOSE, onCloseHandler);
        socketClient.addEventListener(IOErrorEvent.IO_ERROR, _ioErrorHandler);
        socketClient.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _securityErrorHandler);
        netHost = host;
        netPort = port;
        _suceedFun =callSucFun;
        Cc.log("start ping..." + host + ":" + port);
        pingTime = getTimer();
        socketClient.connect(host,port);
    }


    private function onConnectEvent(e:Event):void {
        pingTime = getTimer()-pingTime;
        Cc.log(netHost + ":", "连接成功"+"------------------------costTime===="+pingTime);
        if(_suceedFun!=null)
        {
            _suceedFun(netHost+":"+netPort);
            _suceedFun=null;
        }
    }

    private function _ioErrorHandler(e:IOErrorEvent):void {
        Cc.log(netHost+"---socketIO错误.." + e);
    }

    public function onCloseHandler(e:Event = null):void {
       Cc.log(netHost +"---SOCKET断开事件.....");
    }

    private function _securityErrorHandler(e:SecurityErrorEvent):void {
        Cc.log(netHost+"---socket安全沙箱错误." + e);
    }

    public function focreClose():void
    {
        socketClient.close();
        socketClient.removeEventListener(Event.CONNECT, onConnectEvent);
        socketClient.removeEventListener(Event.CLOSE, onCloseHandler);
        socketClient.removeEventListener(IOErrorEvent.IO_ERROR, _ioErrorHandler);
        socketClient.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _securityErrorHandler);
        _suceedFun =null;
    }
    //先不考虑销毁 免得 异步引起问题
    public function dispose():void
    {
//        socketClient.removeEventListener(Event.CONNECT, onConnectEvent);
//        socketClient.removeEventListener(Event.CLOSE, onCloseHandler);
//        socketClient.removeEventListener(IOErrorEvent.IO_ERROR, _ioErrorHandler);
//        socketClient.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _securityErrorHandler);
    }
}
}
