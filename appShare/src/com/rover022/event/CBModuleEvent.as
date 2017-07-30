/**
 * Created by Administrator on 2015/6/3.
 */
package com.rover022.event {
import flash.events.Event;

public class CBModuleEvent extends Event {
    public static var PLAYER_UPDATE:String = "PLAYER_UPDATE";
    public static var PLAYER_GETMIC:String = "PLAYER_GETMIC";
    public static var PLAYER_DROPMIC:String = "PLAYER_DROPMIC";
    public static var PLAYNAMELINK:String = "chatLinkEvent";
    //
    public static var CHATLINK_GAMRE1:String = "chatlink_gamre1";
    public static var CHATLINK_GAMRE2:String = "chatlink_gamre2";
    public static var CHATLINK_GAMRE3:String = "chatlink_gamre3";
    //
    public var dataObject:Object;
    public static const FLY_PINGMU:String = "FLY_PINGMU";
    public static const LIMIT_ROOM:String = "LIMIT_ROOM";
    public static const LIMIT_ROOM_QAINGENTER:String = "LIMIT_ROOM_QAINGENTER";
    public static const RECONNECT_SOCKET:String = "RECONNECT_SOCKET";
    public static const SHOW_CAR_GAME:String = "SHOW_CAR_GAME";
    public static const SHOW_FINGER_GAME:String = "SHOW_FINGER_GAME";

    public function CBModuleEvent(type:String, bubbles:Boolean = false, _obj:Object = null, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        dataObject = _obj;
    }
}
}
