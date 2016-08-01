/**
 * Created by Taven on 2015/8/31.
 */
package control {
import flash.utils.Dictionary;

import manger.UserVoDataManger;

import net.NetManager;

public class ControlsManger {
    private static var msgOneMap:Dictionary = new Dictionary();
    private static var msgGlobeMap:Dictionary = new Dictionary();

    //用于 全局监听 随时做出反应的消息
    public static function regCotrolls():void
    {
        new GlobalControl().regMsg();
        new GiftAndVideoUIControl().regMsg();
        new ChatAndErrorControl().regMsg();
        new ParkAndSeatControl().regMsg();
        new RankAndInfoControl().regMsg();
        new RoomManageControl().regMsg();
        new VideoControl().regMsg();
    }

    //用于  一次性请求消息 ,无需一直监听的请求  减少control 数量  直接回调处理函数，回调一次后自动消除引用
    public static function sendOneTimesMsg(sendData:*,callFun:Function):void
    {
        var msgId:int =0;
        if(sendData&&sendData.cmd>0)
        {
            msgId =sendData.cmd;
        }
        if(msgId>0) {
            if (!msgOneMap[msgId]) {
                msgOneMap[msgId] = [];
            }
            var msgList:Array = msgOneMap[msgId]; //已经注册过的无需注册
            if (msgList.indexOf(callFun) == -1) {
                msgOneMap[msgId].push(callFun);
            }
            NetManager.getInstance().sendDataObject(sendData);
        }
    }


    //消息处理
    public static function handleMessgae(msgId:uint,data:*):void
    {
        var msgList:Array =  msgGlobeMap[msgId] as Array;
        if(msgList)
        {
            for each (var item:Function in msgList)
            {
                if(item)
                {
                    item(data);
                }
            }
        }

        msgList =  msgOneMap[msgId] as Array; //判断是否临时消息  临时消息处理一次完后 直接消除引用
        if(msgList)
        {
            for each (var item2:Function in msgList)
            {
                if(item2)
                {
                    item2(data);
                }
            }
            delete  msgOneMap[msgId];
            msgOneMap[msgId] =null;
        }
    }



    //清除全局注册的某个消息 消除引用
    public static function deleteMessgae(msgId:uint,delList:Array=null):void
    {
        if(delList==null) //如果 msgList ==null 清除msgId 的所有消息处理。否则只删除某个
        {
            delete  msgGlobeMap[msgId];
            msgGlobeMap[msgId] =null;
        }
        else
        {
            if(delList.length>0)
            {
                var msgList:Array =  msgGlobeMap[msgId] as Array;
                if(msgList)
                {
                    for each (var item:BaseControl in delList)
                    {
                        if(msgList.indexOf(item)>-1)
                        {
                            msgList.splice(msgList.indexOf(item),1);
                        }
                    }
                }
            }
        }
    }


    //消息注册 负责业务处理
    public static function regMessgae(msgId:uint,callFun:Function):void
    {
        if(msgId>0) {
            if (!msgGlobeMap[msgId]) {
                msgGlobeMap[msgId] = [];
            }
            var msgList:Array = msgGlobeMap[msgId]; //已经注册过的无需注册
            if (msgList.indexOf(callFun) == -1) {
                msgGlobeMap[msgId].push(callFun);
            }
        }
      }
    }
}
