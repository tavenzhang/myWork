/**
 * Created by Administrator on 2015/4/1.
 */
package com.rover022.event {
import flash.events.Event;

public class ModuleEvent extends Event {
    public var data:Object;
    //主动去关闭rtmp流事件
    public static const CLOSE_ALL_RTMP_BY_SOCKET:String = "CLOSE_ALL_RTMP_BY_SOCKET";


    public function ModuleEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
    }
}
}
