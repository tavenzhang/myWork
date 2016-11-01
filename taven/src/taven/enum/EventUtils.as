package taven.enum {
import com.junkbyte.console.Cc;
import com.rover022.IVideoRoom;

import control.ControlsManger;

import flash.display.MovieClip;
import flash.events.StatusEvent;
import flash.utils.getQualifiedClassName;

import net.NetManager;

public class EventUtils {
    /**通用发生 事件接口，方便统一处理*/
    public static function secndStatusEvent(sendObj:MovieClip, level:String = "", code:String = ""):void {
        if (sendObj) {
            if (code == "") {
                code = getQualifiedClassName(sendObj);
                code = code.substr(getQualifiedClassName(sendObj).lastIndexOf("::") + 2);
            }
            var event:StatusEvent = new StatusEvent(StatusEvent.STATUS, false, false, code, level);
            sendObj.dispatchEvent(event);
            trace("sender=" + getQualifiedClassName(sendObj) + " -->code =" + code + " -->level= " + level);
        }
    }

    /**通用发生 事件接口，方便统一处理*/
    public static function secndNetData(iVideoRoom:IVideoRoom, cmdId:int, dataStr:Object, func:Function = null):void {
        secndNetDataNew(cmdId,dataStr,func);
    }

    /**通用发生 事件接口，方便统一处理*/
    public static function secndNetDataNew(cmdId:int, dataStr:Object, func:Function = null):void
    {
        dataStr.cmd = cmdId;
        if (func != null) {
            NetManager.sendOnceDataObject(dataStr,  dataStr.callBack);
        }
        else
        {
            NetManager.sendDataObject(dataStr);
        }

    }
}
}