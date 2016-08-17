package com.rover022.tool {
import flash.events.AsyncErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.NetStatusEvent;
import flash.events.SecurityErrorEvent;
import flash.net.NetConnection;
import flash.utils.getTimer;

public class NetPing extends EventDispatcher {
    public static const DEAD_LINE:int = 10000;
    private var _delay:int = DEAD_LINE;
    private var _startTime:int = 0;
    private var _rtmp:String = "";
    private var _nc:NetConnection;
    private var _total:int = 0;
    public var _speedOk:Boolean = true;
    //是否强行终端当前测速
    private var _isForceClose:Boolean = false;
    private var _name:String;

    public function NetPing(param1:String):void {
        var _arr:Array = param1.split("@@");
        _rtmp = _arr[0];
        _name = _arr[1] == undefined ? "未知线路" : _arr[1];

    }// end function
    public function get label():String {
        return _name;//+ ":" + desc;
    }

    public function get rtmp():String {
        return this._rtmp;
    }// end function
    //获取平均时间计算延迟
    public function get delay():int {
        return _delay;
    }// end function
    public function set delay(value:int):void {
        _delay = value;
    }

    public function get desc():String {
        var result:String = "";
        if (!speedOk) {
            result = "测速ing..."
        }
        else {
            if (delay == DEAD_LINE) {
                result = "延迟(大于5000毫秒)";
            }
            else {
                result = "延迟(" + _delay.toString() + "毫秒" + ")";
            }
        }
        return result;
    }

    public function ping():void {
        if (speedOk && !isForceClose) //如果上一次测速还没结束，不开始重新测试,最多等待3秒后 PingManager 会强制测速完成
        {
            delay = DEAD_LINE;
            speedOk = false;
            if (!this._nc) {
                this._nc = new NetConnection();
                this._nc.client = this;
                this._nc.addEventListener(NetStatusEvent.NET_STATUS, this._netStatusEvent);
                this._nc.addEventListener(IOErrorEvent.IO_ERROR, this._netErrorEvent);
                this._nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, this._netErrorEvent);
                this._nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this._netErrorEvent);
            }
            if (!this._nc.connected) {
                this._nc.connect(this._rtmp);
            }
            else {
                this.callNetPing();
            }
        }

    }// end function
    private function _netStatusEvent(event:NetStatusEvent):void {
        //trace("this rtmp=" + this.rtmp + "------------------------------com.rover022.event.info.code ==" + com.rover022.event.info.code);
        switch (event.info.code) {
            case "NetConnection.Connect.Success":
            {
                this.callNetPing();
                break;
            }
            case "NetConnection.Connect.Closed":
            case "NetConnection.Connect.Failed":
            case "NetConnection.Connect.Rejected":
            case "NetConnection.Connect.IdleTimeout":
            {
//              if(!speedOk)
//              {
//                  delay==DEAD_LINE
//              }
                break;
            }
            default:
            {
//                if(!speedOk)
//                {
//                    delay==DEAD_LINE
//                }
                break;
            }
        }

    }// end function
// end function
    private function callNetPing():void {
        if (this._nc.connected) {
            this._startTime = getTimer();
            this._nc.call("netping", null, int(Math.random() * 1000));
        }
    }// end function
    //用于测试连接回调 以便就算间隔
    public function netping(...args):void {
        if (args) {
        }
        if (args.length > 1) {
            this._total = int(args[1]);
            trace(this._rtmp + "[人数]:" + this._total);
        }
        int(_delay + this._total / 4);
        delay = (getTimer() - this._startTime) + this._total / 10;
        speedOk = true;
        //测速完成后主动断开连接
        dispatchEvent(new Event("speedOk"));
        trace("ping:", delay, _name, rtmp);
        if (_nc && _nc.connected) {
            _nc.close();
        }

    }// end function
    public function get speedOk():Boolean {
        return _speedOk;
    }

    public function set speedOk(value:Boolean):void {
        if (_speedOk != value) {
            _speedOk = value;
            //trace("this ping finish delay=" + this.delay);
            if (_speedOk) {
                dispatchEvent(new Event("speedOk"));
            }
        }
    }

    public function get total():int {
        return this._total;
    }

    private function _netErrorEvent(param1:Object):void {
        speedOk = true;

    }

    public function onBWCheck(...args):void {

    }// end function
    public function onBWDone(...args):void {

    }// end function
    public function onMetaData(...args):void {

    }// end function
    public function get isForceClose():Boolean {
        return _isForceClose;
    }

    public function set isForceClose(value:Boolean):void {
        if (_isForceClose != value) {
            _isForceClose = value;
            if (_isForceClose) //强行断开连接
            {
                if (_nc && _nc.connected) {
                    _nc.close();
                }
            }
        }
    }
}
}
