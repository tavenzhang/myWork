/**
 * Created by Administrator on 2015/7/7.
 */
package com.rover022.display {
import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.utils.Dictionary;
import flash.utils.getDefinitionByName;

import ghostcat.manager.RootManager;
import ghostcat.ui.PopupManager;
import ghostcat.ui.RootLoader;

public class IAssetMovieClip extends MovieClip {
	public var assLoader:Loader    = new Loader();
	public var titleBar:MovieClip;
	public var view:MovieClip;
	public var message:String      = "";
	private var _draggable:Boolean = true;
	private var message_txt:TextField;

	public function IAssetMovieClip() {
		super();
		assLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onViewDidLoad);
		assLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOErrorHandle);
		//内容
		view = new MovieClip();
		addChild(view);
		//拖动框
		titleBar = new MovieClip();
		addChild(titleBar);
		//
	}

	public function setCanDrage(w:Number = 420):void {
		var mc:Sprite = new Sprite();
		mc.graphics.beginFill(0xff0000, 0);
		mc.graphics.drawRect(0, 0, w, 100);
		mc.graphics.endFill();
		mc.addEventListener(MouseEvent.MOUSE_DOWN, onMouseGoDown);
		titleBar.addChild(mc);
	}

	private function onIOErrorHandle(event:IOErrorEvent):void {
		trace("IOERROR")
	}

	public function loaderAsset(src:String):void {
		assLoader.load(new URLRequest(src), new LoaderContext(false, ApplicationDomain.currentDomain));
	}

	public function onViewDidLoad(event:Event):void {
	}

	public function getAssMovieClip(_name:String):MovieClip {
		var _class:Class = getDefinitionByName(_name) as Class;
		return new _class as MovieClip;
	}

	/**
	 * Internal mouseDown handler. Starts a drag.
	 * @param event The MouseEvent passed by the system.
	 */
	protected function onMouseGoDown(event:MouseEvent):void {
		if (_draggable) {
			startDrag();
			RootManager.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseGoUp);
			parent.addChild(this); // move to top
		}
		dispatchEvent(new Event(Event.SELECT));
	}

	/**
	 * Internal mouseUp handler. Stops the drag.
	 * @param event The MouseEvent passed by the system.
	 */
	protected function onMouseGoUp(event:MouseEvent):void {
		stopDrag();
		RootManager.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseGoUp);
	}

	public function createRunTextField(_x:Number = 112, _y:Number = 371):void {
		var text:TextField     = new TextField();
		text.defaultTextFormat = new TextFormat("宋体", 12, 0xFFCC00);
		text.multiline         = false;
		text.wordWrap          = false;
		text.mouseEnabled      = false;
		text.width             = 400;
		text.x                 = _x;
		text.y                 = _y;
		text.autoSize          = TextFieldAutoSize.CENTER;
		addChild(text);
		text.filters = [new flash.filters.GlowFilter(0, 1, 2, 2, 4)];
		message_txt  = text;
	}

	public function setRunTextField(content:String):void {
		message          = content;
		message_txt.text = "";
		addEventListener(Event.ENTER_FRAME, onRunEnterFrame);
	}

	public function onRunEnterFrame(e:Event):void {
		var _string:String = message_txt.text;
		if (_string.length == message.length) {
			removeEventListener(Event.ENTER_FRAME, onRunEnterFrame);
		}
		message_txt.text = message.substr(0, _string.length + 1);
	}
}
}
