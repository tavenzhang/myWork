/**
 * Created by Taven on 2015/9/12.
 */
package com.rover022.tool {
import com.junkbyte.console.Cc;

import flash.events.Event;

import flash.events.EventDispatcher;
import flash.events.StatusEvent;
import flash.net.Socket;

public class SocketPingManager extends  EventDispatcher{
    public static const PING_SUCCESS:String="PING_SUCCESS";
    public  var bestHost:String="";
    private var _socktList:Array=[];
    private var _socketClient:Socket;
    private var _socketPort:int=0;
    public  function SocketPingManager() {
        _socketClient = new Socket();
    }

    public function testSocktList(ipList:Array):void
    {
       for(var i:int=0;i<ipList.length;i++)
       {
           var data:Array = (ipList[i] as String).split(":");
           var ipString:String =data[0];
           _socketPort = data[1];
           var socketP:SocketPing = new SocketPing(ipString,_socketPort,pingSucessFul);
           _socktList.push(socketP);
       }
    }

    private function pingSucessFul(host:String):void
    {
        for each(var item:SocketPing in _socktList)
        {
            if(item)
            {
                item.focreClose();
            }
        }
        bestHost =host;
        Cc.log("最终socket=="+bestHost);
        dispatchEvent(new Event(PING_SUCCESS));
    }
}
}
