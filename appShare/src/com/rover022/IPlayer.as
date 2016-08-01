/**
 * Created by Administrator on 2015/6/24.
 */
package com.rover022 {
import flash.events.IEventDispatcher;
import flash.utils.ByteArray;

/**
 * 播放器接口
 * 实现播放功能
 */
public interface IPlayer {
    function headDataComlete():void

    function get headData():ByteArray;

    function playRTMP(s1:String, s2:String):void;

    function publish(s1:String, s2:String):void;

    function closePublish():void;

    function dispatchEvent(event:flash.events.Event):Boolean;

    function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void;

    function get isGetMic():Boolean;

    function updatePer30Second():void;
}
}
