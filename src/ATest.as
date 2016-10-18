/**
 * Created by roger on 2016/2/27.
 */
package {
import com.bit101.components.Panel;
import com.bit101.components.VBox;
import com.bit101.components.Window;

import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.utils.getDefinitionByName;

import ghostcat.ui.PopupManager;

import net.GameSocket;

public class ATest extends Sprite {
	private var KEY:int = 1313113;

	public function ATest() {
		super();
		var socket:GameSocket = new GameSocket(["120.76.120.146"], 8888);
		socket.startConnect();
		return;
		var s:Panel = new Panel(this);
		var b:Panel = new Panel(this);
		b.x         = 10;
//		PopupManager.instance.register(this, this);
//		PopupManager.instance.showPopup(s, this, false);
//		PopupManager.instance.showPopup(b, this, false);
//        setTimeout(function () {
//            scroll.content.x = 0;
//            scroll.content.y = 0;
//        }, 1000)
//        addChild(a);
//        scroll.addVScrollBar();
//        addChild(scroll);
//        var loader:Loader = new Loader();
//        addChild(loader);
//        loader.load(new URLRequest("Modules/FingerGuessingGame.swf"));
		return;
		var plainText:int = 20000;
		// 发送端要发送的数据plainText
		trace(" plainText==" + plainText);
		// 发送端加密(知道KEY)
		var cipherText:int = encrypt(plainText, KEY);
		trace(" cipherText==" + cipherText);
		/*
		 发送端把cipherText传输到接收端
		 如果cipherText在途中被犯罪分子截取
		 即使犯罪分子知道加解密算法，也不能进行
		 因为犯罪分子不知道发送端和接收端私下约定的KEY
		 */
		// 接收端解密(知道KEY)
		var result:int = decrypt(cipherText, KEY);
		// 接收端解密得到的数据result
		trace(" result==" + result);
	}

	public function testClip():void {
		var loader:Loader = new Loader();
		loader.load(new URLRequest("demo.swf"));
		addChild(loader);
		loader.x = Math.random() * 800;
		loader.y = Math.random() * 800;
		addChild(loader);
		var _class:Class = getDefinitionByName("_fla.sprite35_2") as Class;
		trace(_class);
		for (var i:int = 0; i < 100; i++) {
		}
	}

	public function testURL():void {
		var url:URLRequest      = new URLRequest("http://v.1room.cc/video_gs/kw?time=0.4063498810864985");
		var loaderUrl:URLLoader = new URLLoader(url);
		loaderUrl.addEventListener(Event.COMPLETE, onCompleteHandle);
	}

	private function onCompleteHandle(event:Event):void {
		var loaderUrl:URLLoader = event.currentTarget as URLLoader;
		trace(decodeURIComponent(loaderUrl.data));
	}

	function encrypt(plainText:int, key:int):int {
		return plainText ^ key;
	}

// 解密算法也可以公开
	function decrypt(cipherText:int, key:int):int {
		return cipherText ^ key;
	}
}
}

import com.bit101.components.ScrollBar;
import com.bit101.components.ScrollPane;

import flash.display.DisplayObjectContainer;

class AbcScrollPane extends ScrollPane {
	public function AbcScrollPane(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0):void {
		super(parent, xpos, ypos);
	}

	public function get vscrollBar():ScrollBar {
		return _vScrollbar;
	}

	public function get hscrollBar():ScrollBar {
		return _hScrollbar;
	}

	override protected function invalidate():void {
		draw();
	}
}
