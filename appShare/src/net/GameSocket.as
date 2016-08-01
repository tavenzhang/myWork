/**
 * Created by roger on 2016/6/1.
 */
package net {
import com.junkbyte.console.Cc;
import com.rover022.CBProtocol;
import com.rover022.IVideoModule;
import com.rover022.vo.VideoConfig;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.Socket;
import flash.utils.ByteArray;
import flash.utils.clearInterval;
import flash.utils.getTimer;
import flash.utils.setInterval;
import flash.utils.setTimeout;

import tool.VideoTool;

/**
 * 改socket 会保存一个地址列表 和一个端口列表
 */
public class GameSocket extends EventDispatcher {
	private var amfStream:ByteArray;
	private var isReadHeader:Boolean;
	private var amfStreamLength:Number;
	private var buffer:ByteArray = new ByteArray();
	private var HEADERSIZE:uint  = 2;
	public var socketClient:Socket;
	private var ASEkey:String;
	//
	public var module:IVideoModule;
	public var hostArray:Array;
	public var port:int;
	public var current:int       = 0;
	private var id:uint;

	public function GameSocket(_hostArray:Array, _port:int) {
		hostArray = _hostArray;
		port      = _port;
		init();
		
		id = setInterval(sendHeartData, 9000);
	}

	public function startConnect():void {
		Cc.logch("gamesocket", "开始连接游戏服务器", "通道:", current, hostArray[current], port);
		socketClient.connect(hostArray[current], port);
	}

	public function reConnectNextLine(e:Event = null):void {
		Cc.logch("gamesocket", "3秒后开始连接另一条线路");
		current++;
		if (hostArray[current] == null) {
			current = 0;
		}
		setTimeout(startConnect, 3000);
	}

	public function sendHeartData():void {
		if (socketClient.connected) {
			sendDataObject({cmd: CBProtocol.ping, msg: getTimer()})
		}
	}

	public function init():void {
		socketClient                = new Socket();
		socketClient.timeout        = 12000;
		socketClient.objectEncoding = 3;
		socketClient.addEventListener(Event.CONNECT, onConnectEvent);
		socketClient.addEventListener(Event.CLOSE, onCloseHandler);
		socketClient.addEventListener(IOErrorEvent.IO_ERROR, onIOErrorHandler);
		socketClient.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _securityErrorHandler);
		socketClient.addEventListener(ProgressEvent.SOCKET_DATA, readResponse);
	}

	private function onConnectEvent(e:Event):void {
		//_connectTimecost = getTimer() - _connectTimecost;
		Cc.logch("gamesocket", "连接成功" + "------------------------socketClient=", socketClient.connected);
		connectServerASEkey();
	}

	private function connectServerASEkey():void {
		sendDataObject({
			"cmd": 10000
		});
	}

	private function _securityErrorHandler(event:SecurityErrorEvent):void {
		Cc.logch("gamesocket", "socket 安全沙箱 错误");
		reConnectNextLine();
	}

	private function onIOErrorHandler(event:IOErrorEvent):void {
		Cc.logch("gamesocket", "socket io 错误");
		reConnectNextLine();
	}

	private function onCloseHandler(event:Event):void {
		destroy();
		dispatchEvent(event);
	}

	private function readResponse(event:ProgressEvent):void {
		while (socketClient.bytesAvailable >= this.HEADERSIZE) {
			//如果缓冲区可读文件大于文件头的字节长度
//            trace("ByteAvailable:" + this.bytesAvailable);
//            trace("Buffer Length:" + this.buffer.length);
			if (this.isReadHeader == false) {
				this.isReadHeader = true;
				socketClient.readBytes(this.buffer, 0, this.HEADERSIZE);
				this.buffer.position = 0;
				this.amfStreamLength = this.buffer.readShort();
				//trace(this.amfStreamLength);
			}
			this.amfStream = new ByteArray();
			if (socketClient.bytesAvailable < this.amfStreamLength) {
//                trace("Continue Received");
				return;
			}
			socketClient.readBytes(this.amfStream, 0, this.amfStreamLength);
			if (this.amfStream.length == this.amfStreamLength) {
				this.isReadHeader = false;
				//trace("加入Stream Length:" + this.amfStream.length);
				amfStream.uncompress();
				var msg:Object = this.amfStream.readObject();
				//UserVoDataManger.getInstance().socketApp(msg);
				onGetData(msg);
			} else if (this.amfStream.length > this.amfStreamLength) {
				//如果读出来的对象大于所需的长度立即中断
				//trace("Error!");
				trace("game,socket读出来的对象大于所需的长度  flash段自动中断");
				socketClient.close();
				return;
			}
		}
	}

	private function onGetData(data:Object):void {
		Cc.logch("gamesocket", "get<--", data.cmd + "," + JSON.stringify(data));
		switch (data.cmd) {
			case CBProtocol.getKey://拿到服务器的验证钥匙 生成ase;
				joinGame(data.limit);
				break;
		}
		//
		if (module && module.listNotificationInterests().indexOf(data.cmd) != -1) {
			module.handleNotification(data);
		}
	}

	private function joinGame(limit:String):void {
		ASEkey              = limit;
		//var iPlay:IPlayer = ModuleLoaderManger.getInstance().getModule(ModuleNameType.VIDEOPLAYER) as IPlayer;
		var _playSid:String = "";
		var _sting:String   = VideoConfig.loginKey + "finger567";
		var passw:String    = VideoTool.buildAseString(ASEkey, _sting);
		sendDataObject({
			"key":       VideoConfig.loginKey,
			"roomid":    VideoConfig.roomID,
			"pass":      "",
			"roomLimit": passw,
			"isPulish":  false,
			"pulishUrl": "",
			"sid":       _playSid,
			"cmd":       10001
		});
	}

	public function sendDataObject(_obj:Object, cmd:int = -1):void {
		if (socketClient == null || socketClient.connected == false) {
			return;
		}
		try {
			if (cmd != -1 || !_obj.hasOwnProperty("cmd")) {
				_obj.cmd = cmd;
			}
			var _byteArray:ByteArray = new ByteArray();
			_byteArray.writeObject(_obj);
			_byteArray.compress();
			socketClient.writeBytes(_byteArray);
			socketClient.writeUTF("\r\n");
			socketClient.flush()            //
			Cc.logch("gamesocket", "send-->", _obj.cmd + "," + JSON.stringify(_obj));
			//trace("gameSocket:", "-->" + _obj.cmd + "," + JSON.stringify(_obj));
		} catch (e:*) {
			//trace("NetManager->sendDataObject:" + e);
		}
	}

	public function destroy():void {
		if (socketClient.connected) {
			socketClient.close();
		}
		clearInterval(id);
		module = null;
	}
}
}
