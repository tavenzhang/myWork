/**
 * Created by Taven on 2015/8/31.
 */
package control {

public class BaseControl implements IControl
{
    protected var msgVOList:Array;

    public function regMsg():void {
    }

    //如果处理多个msgid消息 利用switch 和 data.cmd区分
    public function handleMessgae(data:*):void {
    }

    public function dispose():void {
        if(msgVOList&&msgVOList.length)
        {
            for(var i:int; i<msgVOList.length; i++)
            {
                ControlsManger.deleteMessgae(msgVOList[i],false);
            }
        }
    }

    public function regMagHanlde(msgId:int,call:Function):void
    {
        if(msgId>0)
        {
            if(!msgVOList)
            {
                msgVOList =[];
            }
            var vo=new MsgHandleVo(msgId,call);
            ControlsManger.regMessgae(vo);
            if(msgVOList.indexOf(vo)==-1)
            {
                msgVOList.push(vo);
            }
        }
    }

}
}
