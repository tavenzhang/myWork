/**
 * Created by Thomas on 2016/10/31.
 */
package control {

public class MsgHandleVo {


    public var msgId:int;
    public var handleFun:Function;

    public function MsgHandleVo(mid:int,fun:Function) {
        msgId = mid;
        handleFun = fun;
    }

}

}
