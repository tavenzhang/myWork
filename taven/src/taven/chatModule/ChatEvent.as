/**
 * Created by Administrator on 2015/4/1.
 */
package taven.chatModule {
import flash.events.Event;

public class ChatEvent extends Event {
    public var dataObject:Object;

    public function ChatEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
    }
}
}
