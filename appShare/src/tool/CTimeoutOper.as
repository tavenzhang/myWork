/**
 * Created by Administrator on 2015/1/8.
 */
package tool {
import ghostcat.operation.TimeoutOper;

public class CTimeoutOper extends TimeoutOper {
    public var func:Function;

    public function CTimeoutOper(_time:Number, callFunc:Function) {
        super();
        timeout = _time;
        func = callFunc;
    }

    override public function execute():void {
        func.call(null);
        func = null;
        super.execute();
    }
}
}
