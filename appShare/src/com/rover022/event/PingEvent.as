/**
 * Created by roger on 2016/4/8.
 */
package com.rover022.event {
import flash.events.Event;

public class PingEvent extends Event {
    public static const GET_LIST:String = "GET_LIST";
    public var objcet:Object;

    public function PingEvent(type:String, obj:Object, bubbles:Boolean = false, cancelable:Boolean = false) {
        objcet = obj;
        super(type, bubbles, cancelable);
    }
}
}
