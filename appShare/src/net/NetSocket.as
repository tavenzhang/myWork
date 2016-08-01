package net {
import com.junkbyte.console.Cc;

import flash.events.ProgressEvent;
import flash.net.Socket;
import flash.utils.ByteArray;

import manger.UserVoDataManger;

public class NetSocket extends Socket {
    private var amfStream:ByteArray;
    private var isReadHeader:Boolean;
    private var amfStreamLength:Number;
    private var buffer:ByteArray = new ByteArray();
    private var HEADERSIZE:uint  = 2;

    public function NetSocket(src:NetManager):void {
        addEventListener(ProgressEvent.SOCKET_DATA, readResponse);
    }

    private function readResponse(event:ProgressEvent):void {
        this.dataAnalysis();
    }

    private function dataAnalysis():void {
        while (this.bytesAvailable >= this.HEADERSIZE) {
            //如果缓冲区可读文件大于文件头的字节长度
//            trace("ByteAvailable:" + this.bytesAvailable);
//            trace("Buffer Length:" + this.buffer.length);
            if (this.isReadHeader == false) {
                this.isReadHeader    = true;
                this.readBytes(this.buffer, 0, this.HEADERSIZE);
                this.buffer.position = 0;
                this.amfStreamLength = this.buffer.readShort();
                //trace(this.amfStreamLength);
            }
            this.amfStream = new ByteArray();
            if (this.bytesAvailable < this.amfStreamLength) {
//                trace("Continue Received");
                return;
            }
            this.readBytes(this.amfStream, 0, this.amfStreamLength);
            if (this.amfStream.length == this.amfStreamLength) {
                this.isReadHeader = false;
                //trace("加入Stream Length:" + this.amfStream.length);
                amfStream.uncompress();
                var msg:Object    = this.amfStream.readObject();
                //trace(JSON.stringify(msg));
                UserVoDataManger.getInstance().socketApp(msg);
            } else if (this.amfStream.length > this.amfStreamLength) {
                //如果读出来的对象大于所需的长度立即中断
                //trace("Error!");
                Cc.log("socket读出来的对象大于所需的长度  flash段自动中断");
                this.close();
                return;
            }
        }
    }
}
}