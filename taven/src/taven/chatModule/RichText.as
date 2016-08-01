/**
 * Created by Administrator on 2015/6/30.
 */
package taven.chatModule {
import com.bit101.components.VScrollBar;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.system.Capabilities;
import flash.text.engine.FontLookup;
import flash.utils.Timer;

import flashx.textLayout.container.ContainerController;
import flashx.textLayout.conversion.TextConverter;
import flashx.textLayout.edit.SelectionManager;
import flashx.textLayout.elements.FlowElement;
import flashx.textLayout.elements.ParagraphElement;
import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.events.FlowElementMouseEvent;
import flashx.textLayout.events.StatusChangeEvent;
import flashx.textLayout.events.TextLayoutEvent;
import flashx.textLayout.events.UpdateCompleteEvent;

public class RichText extends MovieClip {
    public var textFlow:TextFlow;
    public var controller:ContainerController;
    public var isFirstContain:Boolean = true;
    public var vscrollBar:VScrollBar;
    public var textLay:Sprite = new Sprite();
    public var poolArray:Array = [];
    public var _width:Number;
    public var _height:Number;
    private var _tiemDelay:Timer;
    private var _isDealing:Boolean = false;
    private var _waitList:Array = [];
    //
    //干脆5秒刷一次好了
    public var canDraw:Boolean = false;
    public var maxLength:uint = 30;

    public function RichText(_w:Number, _h:Number) {
        _width = _w;
        _height = _h;
        this.textFlow = new TextFlow();
        textFlow.fontLookup = FontLookup.DEVICE;
        textFlow.fontFamily = "微软雅黑";
        textFlow.fontSize = 12;
        if (Capabilities.manufacturer.indexOf("Google") > -1) {
            textFlow.fontFamily = "微软雅黑";
            TextFlowTool.fontClass = "微软雅黑";
        } else {
            textFlow.fontFamily = "宋体";
            TextFlowTool.fontClass = "宋体";
        }
        textFlow.color = 0xffffff;
        //textFlow.lineHeight = 22;
        addChild(textLay);
        controller = new ContainerController(textLay, _w, _h);
        textFlow.flowComposer.addController(controller);
        textFlow.interactionManager = new SelectionManager();
        textFlow.backgroundColor = 0x333333;
        textFlow.addEventListener(TextLayoutEvent.SCROLL, this.textFlowScrollEvent);
        textFlow.addEventListener(UpdateCompleteEvent.UPDATE_COMPLETE, tlfUpdtHandler, false, 0, true);
        textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, this.graphicChangeEvent);
        addEventListener(FocusEvent.FOCUS_IN, this.setIMEChinese);
        vscrollBar = new VScrollBar(this, _w, 0, onSelectHandle);
        vscrollBar.setSize(60, _h);
        vscrollBar.value = 1000;
        vscrollBar.setThumbPercent(0);
        vscrollBar.alpha = 0;
        //_tiemDelay = new Timer(200, 1);
        //_tiemDelay.addEventListener(TimerEvent.TIMER_COMPLETE, onDealTime);
        //flash.utils.setInterval(updateAllControllers, 1000);
        addEventListener(Event.ENTER_FRAME, updateAllControllers)
    }

    public function updateAllControllers(e:Event = null):void {
        if (canDraw) {
            canDraw = false;
            textFlow.flowComposer.updateAllControllers();
            //
            controller.verticalScrollPosition = Math.ceil(controller.getContentBounds().height);
            //
            var m:Number = controller.getContentBounds().height - controller.compositionHeight;
            vscrollBar.alpha = (m > 0) ? 1 : 0;
            vscrollBar.setSliderParams(0, m, m);
        }
    }

    public function customClickHandler(e:MouseEvent):void {
    }

    private function tlfUpdtHandler(e:Event):void {
        var textFlow:TextFlow = e.currentTarget as TextFlow;
        var containerController:ContainerController = textFlow.flowComposer.getControllerAt(0) as ContainerController;
        //trace("update", containerController.getContentBounds());
        textFlow.flowComposer.composeToPosition();
    }

    /**
     * 滚动条相关
     * @param e
     */
    private function onSelectHandle(e:Event):void {
        //这个不会再触发其他事件了
        controller.verticalScrollPosition = vscrollBar.value;
    }

    /**
     * 滚动条相关
     * @param e
     */
    private function textFlowScrollEvent(event:TextLayoutEvent):void {
        //trace("textFlowScrollEvent")
        vscrollBar.value = controller.verticalScrollPosition;
    }

    private function changeTextFlowColor(e:FlowElementMouseEvent):void {
        var textFlow:TextFlow = e.flowElement.getTextFlow();
        textFlow.color = textFlow.color == 0x00ff00 ? 0 : 0x00ff00;
        textFlow.flowComposer.updateAllControllers();
    }

    /**
     * 支持输入<TextFlow> 文本进入
     * @param markup
     */
    public function appendRichTxt(markup:String):void {
        trace("appendRichTxt");
        var copyMc:TextFlow = TextConverter.importToFlow(markup, TextConverter.TEXT_LAYOUT_FORMAT);
        if (copyMc == null) {
            trace("丢进来的聊天元素不是TextFlow")
            return;
        }
        if (isFirstContain) {
            textFlow.removeChildAt(0);
            isFirstContain = false;
        }
        while (copyMc.numChildren > 0) {
            var item:FlowElement = copyMc.getChildAt(0)
            textFlow.addChild(copyMc.getChildAt(0));
            poolArray.push(item);
            if (poolArray.length > maxLength) {
                item = poolArray.shift();
                textFlow.removeChild(item);
            }
        }
        textFlow.flowComposer.updateAllControllers();
        //在这里修改
        controller.verticalScrollPosition = controller.getContentBounds().height;
        var m:Number = controller.getContentBounds().height - controller.compositionHeight;
        vscrollBar.alpha = (m > 0) ? 1 : 0;
        vscrollBar.setSliderParams(0, m, m);
    }

    public function clear():void {
        while (textFlow.numChildren > 0) {
            textFlow.removeChildAt(0)
        }
        poolArray = [];
        textFlow.flowComposer.updateAllControllers();
        isFirstContain = true;
    }

    private function graphicChangeEvent(event:StatusChangeEvent):void {
        //textFlow.flowComposer.updateAllControllers();
        //controller.verticalScrollPosition = Math.ceil(controller.getContentBounds().height);
        canDraw = true;
    }

    private function setIMEChinese(event:FocusEvent):void {
    }

    private function onDealTime(evt:Event):void {
        _isDealing = false;
        if (_waitList.length > 0) {
            flushView(_waitList.pop());
            _isDealing = true;
            _tiemDelay.reset();
            _tiemDelay.start();
        }
    }

    /**
     *  加入元素 当n多消息同时加入是 把处理与渲染分开。间隔0.25秒 防止卡顿现象
     * @param item
     */
    public function addRichChild(item:ParagraphElement):void {
        flushView(item);
        return;
        _waitList.push(item);
        if (!_isDealing) {
            flushView(_waitList.pop());
            _isDealing = true;
            _tiemDelay.reset();
            _tiemDelay.start();
        }
    }

    private function dealWaitLisMessage():void {
    }

    private function flushView(item:ParagraphElement):void {
        if (isFirstContain) {
            textFlow.removeChildAt(0);
            isFirstContain = false;
        }
        textFlow.addChild(item);
        poolArray.push(item);
        if (poolArray.length > maxLength) {
            item = poolArray.shift();
            textFlow.removeChild(item);
//            TextFlowTool.resetEelement(item);
        }
        canDraw = true;
//        textFlow.flowComposer.updateAllControllers();
//        //
//        controller.verticalScrollPosition = Math.ceil(controller.getContentBounds().height);
//        //
//        var m:Number = controller.getContentBounds().height - controller.compositionHeight;
//        vscrollBar.alpha = (m > 0) ? 1 : 0;
//        vscrollBar.setSliderParams(0, m, m);
    }

    public function setHeight(_h:Number):void {
        _height = _h;
        controller.setCompositionSize(_width, _height);
        vscrollBar.height = _h;
        textFlow.flowComposer.updateAllControllers();
    }
}
}
