/**
 * Created by ws on 2015/7/7.
 */
package com.rover022.p2pPlay {
import flash.display.Sprite;
import flash.media.Camera;
import flash.media.Microphone;
import flash.media.Video;

public class BaseLiveP2P extends Sprite {
    public const P2PFailedEvent:String = "P2PFailedEvent";
    public const P2PPlayEvent:String = "P2PPlayEvent";
    public const P2PPublishEvent:String = "P2PPublishEvent";
    public const P2PCloseEvent:String = "P2PCloseEvent";
    public const P2PFullEvent:String = "P2PFullEvent";
    public const P2PNetStreamStop:String = "P2PNetStreamStop";
    public var cam:Camera;
    public var mir:Microphone;
    public var video:Video;

    public function initStream():void {
    }
    public function close(_bool:Boolean = true):void {
    }
    public function play(_flv:String, _roomid:* = ""):void {
    }
    public function publish(_flv:String, _roomid:* = ""):void {

    }
    public function formatStream():void{

    }
}
}
