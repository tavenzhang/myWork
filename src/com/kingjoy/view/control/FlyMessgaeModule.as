package com.kingjoy.view.control {
import com.greensock.TweenMax;
import com.greensock.easing.Linear;

import display.BaseModule;

import flash.filters.GlowFilter;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

import ghostcat.manager.RootManager;

[SWF(width=1500, height=700)]
public class FlyMessgaeModule extends BaseModule {
    private var _messageList:Array;
    private var item:TextField;
    private static var _instance:FlyMessgaeModule;


    override protected function initView():void {
        _messageList = [];

        item = new TextField();
        item.defaultTextFormat = new TextFormat("宋体", 30, 0xffffff);
        item.filters = [new GlowFilter(0xff0000)];
        addChild(item);
        //visible = false;

        //test();
    }

    public function test():void {
        for (var i:int = 0; i <= 1; i++) {
            addMessage("中文中文,中文中文中文中文中文中文中文中文中文中文中文中文中文中文" + i);
        }
    }

    public function addMessage(messsage:String, times:int = 2):void {
        //var message:MessageVo = new MessageVo(messsage, times);
        _messageList.push(messsage);
        runPaoMaDeng();
    }

    public static function getInstance():FlyMessgaeModule {
        if (_instance == null) {
            _instance = new FlyMessgaeModule();
        }
        return _instance;
    }

    public function runPaoMaDeng():void {

        RootManager.stage.addChild(this);
        if (TweenMax.isTweening(item) == false && _messageList.length > 0) {
            var message:String = _messageList.shift();
            //
            item.x = RootManager.stage.stageWidth;
            item.y = 10;
            item.text = message;
            item.autoSize = TextFieldAutoSize.LEFT;
            item.mouseEnabled = false;
            TweenMax.to(item, 14, {x: -item.width, ease: Linear.easeNone, onComplete: runPaoMaDeng});
        } else {
            trace("跑马灯结束!...")
        }
    }


}
}
