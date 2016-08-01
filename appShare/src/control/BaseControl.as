/**
 * Created by Taven on 2015/8/31.
 */
package control {
public class BaseControl implements IControl
{
    protected var msgIdList:Array;

    public function regMsg():void {
    }

    //如果处理多个msgid消息 利用switch 和 data.cmd区分
    public function handleMessgae(data:*):void {
    }

    public function dispose():void {
        if(msgIdList&&msgIdList.length)
        {
            for(var i:int;i<msgIdList.length;i++)
            {
                ControlsManger.deleteMessgae(msgIdList[i],[this]);
            }
        }
    }

    public function regMagHanlde(msgId:int,call:Function):void
    {
        if(msgId>0)
        {
            if(!msgIdList)
            {
                msgIdList =[];
            }
            ControlsManger.regMessgae(msgId,call);
            if(msgIdList.indexOf(msgId)==-1)
            {
                msgIdList.push(msgId);
            }
        }
    }

}
}
