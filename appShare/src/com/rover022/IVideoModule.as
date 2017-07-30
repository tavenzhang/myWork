/**
 * Created by Administrator on 2015/4/28.
 */
package com.rover022 {
public interface IVideoModule {
    function set videoRoom(src:IVideoRoom):void;

    function get videoRoom():IVideoRoom;

    function listNotificationInterests():Array;

    function handleNotification(src:Object):void;
}
}
