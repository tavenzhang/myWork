package com.rover022.tool {
import flash.events.*;
import flash.utils.*;

public class PingManager extends EventDispatcher {
    public static const ITEM_TESTOK:String = "testOK";
    public static const ALL_TESTOK:String = "alltestOK";

    private var rtmpHashMap:Dictionary = new Dictionary();
    private var rtmpSortList:Array = [];
    private var _timeId:uint;
    private var _isFinishTest:Boolean = false;

    private var _finishHandle:Function;


    [Event(name="GET_LIST", type="com.rover022.event.PingEvent")]
    public function PingManager():void {
        // this._heartTimer = new Timer(5000);
        // this._heartTimer.addEventListener(TimerEvent.TIMER, this._heartTimerEvent);
    }// end function
    public function startTestSped():void {
        clearInterval(_timeId);
        _timeId = setTimeout(foreceTestOver, NetPing.DEAD_LINE); //5秒以后没有测到速度的强制设置为大于5秒
        for each(var item:NetPing in rtmpHashMap) {
            if (item) {
                try {
                    item.ping();
                }
                catch (e:Error) {
                    break;
                }
            }
        }
    }// end function


    public function addCliendRtmpArr(param1:Array):void {
        for each(var item:NetPing in rtmpHashMap) {
            if (item) {
                item.isForceClose = true;
            }
        }
        if (param1 && param1.length > 0) {
            for (var i:int = 0; i < param1.length; i++) {
                if (param1[i] != "" && param1[i] != null) {
                    if (rtmpHashMap[param1[i]] is NetPing) {
                        (rtmpHashMap[param1[i]] as NetPing).isForceClose = false;
                    }
                    else {
                        addChildRtmp(param1[i]);
                    }
                }
            }
        }
    }

    private function addChildRtmp(param1:String):NetPing {
        if (rtmpHashMap[param1] is NetPing)
            trace("this rtmp ----------------------- alread in HashMp!");
        else {
            if (param1 != "" && param1 != null) {
                rtmpHashMap[param1] = new NetPing(param1);
                rtmpHashMap[param1].addEventListener("speedOk", onTestSpeedOk);
            }
        }

        return rtmpHashMap[param1] as NetPing;
    }// end function
    //获取当前状态下最快的rtmp
    public function get fastBalanceRtmp():NetPing {
        var rtmp:String = "";
        var fastRtmp:int = 999;
        var itemNewPing:NetPing;
        for each(var item:NetPing in rtmpHashMap) {
            if (item && item.speedOk && !item.isForceClose) {
                if (itemNewPing) {
                    if (item.delay < itemNewPing.delay) {
                        itemNewPing = item;
                    }
                }
                else {
                    itemNewPing = item;
                }
            }
        }
        trace("最终>>> " + fastRtmp + "-" + rtmp);
        return itemNewPing;
    }// end function
    public function set isFinishTest(value:Boolean):void {
        if (_isFinishTest != value) {
            _isFinishTest = value;
            if (_isFinishTest) {
                finishItemSpeed();
            }
        }
    }

    private function foreceTestOver():void {
        for each(var item:NetPing in rtmpHashMap) {
            if (item && !item.speedOk)
            //强制设置完成
                item.delay = NetPing.DEAD_LINE;
            item.speedOk = true;
        }
    }

    //获取 rtmp 列表
    public function get rtmpSortlist():Array {
        rtmpSortList.length = 0;
        for each(var item:NetPing in rtmpHashMap) {
            if (item && !item.isForceClose) {
                rtmpSortList.push(item);
            }
        }
        rtmpSortList.sortOn("delay", Array.NUMERIC);
        return rtmpSortList;
    }// end function

    //当某一个ping 检测完成时 回调这个函数  通过这个事件可以及时刷新 rtmp速度列表
    private function onTestSpeedOk(evt:Event):void {
        var isFinAll:Boolean = true;
        for each(var item:NetPing in rtmpHashMap) {
            if (item && !item.speedOk) {
                isFinAll = false;
                break;
            }
        }
        finishItemSpeed();
        if (isFinAll) {
            dispatchEvent(new Event(ALL_TESTOK));
        }
    }

    //当有item测试完成时 回调结果处理函数
    private function finishItemSpeed():void {
        dispatchEvent(new Event(ITEM_TESTOK));
    }
}
}
