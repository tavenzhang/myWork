/**
 * Created by Administrator on 2015/4/28.
 */
package net {
import flash.events.StatusEvent;

import ghostcat.events.OperationEvent;
import ghostcat.operation.LoadOper;
import ghostcat.operation.server.HttpServiceProxy;

public class CBHttpServiceProxy extends HttpServiceProxy {
    public function CBHttpServiceProxy(baseUrl:String) {
        super(baseUrl);
    }

    override public function operate(method:String, para:Object = null, rHander:Function = null, fHander:Function = null):LoadOper {
        function opEvent(e:OperationEvent):void {
            var fun:Function = rHander;
            var tar:LoadOper = e.target as LoadOper;
            var event:StatusEvent = new StatusEvent(StatusEvent.STATUS, false, false, "http", tar.data);
            fun.call(null, event);
        }
        return super.operate(method, para, opEvent, fHander);
    }

}
}
