package taven {
/**
 * @author ever
 * @E-mail: ever@Kingjoy.co
 * @version 1.0.0
 * 创建时间：2015-1-20 下午5:45:12
 * ever.SpeakModule
 */

import display.BaseModule;

import com.rover022.tool.SensitiveWordFilter;

import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.events.StatusEvent;
import flash.system.IME;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;

import taven.common.Marquee;


public class SpeakerModule extends BaseModule {
    private var _textFormat:TextFormat = new TextFormat("宋体", 12, 0x000000, false);
    private var pBroadCast:PublishBroadCast;
    private var inputBox:TextInputBox;

    private var infoTxt:TextField;
    private var numTxt:TextField;

    private var marqueeText:Marquee;

    public var msg:String = "公告不能为空!!!";
    public var title:String = "提示";

    private var txt:TextField;

    public function SpeakerModule() {
        super();
        this.addEventListener(Event.ADDED_TO_STAGE, onAddToStageHandler);
    }

    private function onAddToStageHandler(e:Event):void {
        this.addEventListener(Event.REMOVED_FROM_STAGE, onRemoveToStageHandler);
        viewInit();
        eventInit();
    }

    //视图初始化
    private function viewInit():void {
        this.inputBox = new TextInputBox();
        this.numTxt = this.inputBox.num_txt;

        this.pBroadCast = new PublishBroadCast();
        this.pBroadCast.basemap_mc.visible = false;
        this.pBroadCast.mask_mc.width = this.pBroadCast.basemap_mc.width = this.stage.stageWidth - this.pBroadCast.speaker_bt.width;
        this.pBroadCast.mask_mc.x = this.pBroadCast.basemap_mc.x = -this.pBroadCast.basemap_mc.width;
//			trace(this.pBroadCast.mask_mc.width);
//			this.pBroadCast.x=this.stage.stageWidth-this.pBroadCast.speaker_bt.width;
//			this.pBroadCast.y=this.inputBox.y+this.inputBox.height;
        this.addChild(this.pBroadCast);

//			this.inputBox.x=this.pBroadCast.x+this.pBroadCast.speaker_bt.width-this.inputBox.width;

        //文本输入框
        this.infoTxt = new TextField();
        this.infoTxt.type = TextFieldType.INPUT;
        this.infoTxt.x = 17;
        this.infoTxt.y = 42;
        this.infoTxt.width = 315;
        this.infoTxt.height = 70;
        this.infoTxt.defaultTextFormat = this._textFormat;
        this.infoTxt.text = "";
        this.infoTxt.multiline = false;
        this.infoTxt.wordWrap = true;
        this.infoTxt.maxChars = 30;
        this.infoTxt.addEventListener(Event.CHANGE, onInputHandler);
        this.inputBox.addChild(this.infoTxt);

        this.numTxt.text = String(this.infoTxt.maxChars);

        this.marqueeText = new Marquee();
        this.marqueeText.mask = this.pBroadCast.mask_mc;
//			this.marqueeText.x=this.pBroadCast.x;
//			this.marqueeText.y=this.pBroadCast.y;
        this.addChild(this.marqueeText);
    }

    //事件初始化
    private function eventInit():void {
        this.addEventListener(MouseEvent.CLICK, onClickHandler);
        this.inputBox.addEventListener(FocusEvent.FOCUS_IN, onSetIMEHandler);
        this.inputBox.addEventListener(Event.REMOVED_FROM_STAGE, onInputBoxRemovedHandler);
        this.infoTxt.addEventListener(Event.CHANGE, onInputHandler);
        this.marqueeText.addEventListener("marqueeCompleteEvent", _marqueeCompleteEvent);
    }

    private function onClickHandler(e:Event):void {
        trace(e.target.name);
        switch (e.target.name) {
            case "speaker_bt"://公告按钮
//					if(this.contains(this.inputBox))
//						return;
//					this.addChild(this.inputBox);
                this.dispatchEvent(new Event("speakerClickEvent"));
                break;
            case "send_bt"://发送公告
                if (this.infoTxt.length == 0) {
                    var statusEvt:StatusEvent = new StatusEvent(StatusEvent.STATUS);
                    statusEvt.code = "sides";
                    statusEvt.level = "warning";
                    this.dispatchEvent(statusEvt);
                    return;
                }
                this.infoTxt.text = SensitiveWordFilter.validAndReplaceSensitiveWord(this.infoTxt.text);
                if (SensitiveWordFilter.canSend == false) {
                    videoRoom.showAlert("您发送的内容包含敏感字符，请仔细检查！", "飞屏");
                }
                else {
                    this.dispatchEvent(new Event("speakerCompleteEvent"));
                }
                break;
            case "close_bt"://关闭按钮
                this.removeChild(this.inputBox);
                break;
            default:
                break;
        }

    }

    private function onSetIMEHandler(e:FocusEvent):void {
        this.stage.focus = this.infoTxt;
        IME.enabled = true;
    }

    //文本框输入
    private function onInputHandler(e:Event):void {
        //trace(this.infoTxt.maxChars," $$ ",this.infoTxt.length," ### ",this.infoTxt.text);
        this.numTxt.text = (this.infoTxt.maxChars - this.infoTxt.length).toString();
    }

    private function onInputBoxRemovedHandler(e:Event):void {
        this.infoTxt.text = "";
        this.numTxt.text = (this.infoTxt.maxChars).toString();
    }

    //缓动播放完成
    private function _marqueeCompleteEvent(e:Event):void {
        this.pBroadCast.basemap_mc.visible = false;
//			this.marqueeText.x=this.pBroadCast.x;
    }

    //打开或关闭广播框
    public function openAndCloseInput():void {
        if (this.contains(this.inputBox))
            this.removeChild(this.inputBox);
        else
            this.addChild(this.inputBox);
    }

    //发布广播
    public function set text(value:String):void {
        this.marqueeText.text = value;
        this.pBroadCast.basemap_mc.visible = true;

        if (this.contains(this.inputBox))
            this.removeChild(this.inputBox);
    }

    //获取发布广播按钮宽度
    public function getSpeakWidth():Number {
        if (this.pBroadCast)
            return this.pBroadCast.speaker_bt.width;
        return 0;
    }

    //获得这个组件的高度
    public function getSpeakHeight():Number {
        return this.inputBox.height + this.pBroadCast.height;
    }

    public function getInPutHeight():Number {
        return this.inputBox.height;
    }

    //获取输入内容
    public function get text():String {
        return this.infoTxt.text;
    }

    override public function set width(value:Number):void {
        this.pBroadCast.basemap_mc.width = this.pBroadCast.mask_mc.width = value - this.pBroadCast.speaker_bt.width;
        this.pBroadCast.basemap_mc.x = this.pBroadCast.mask_mc.x = -(value - this.pBroadCast.speaker_bt.width);
        this.marqueeText.mask = this.pBroadCast.mask_mc;
        //trace("##### ",this.marqueeText.mask.width);

        this.pBroadCast.x = this.stage.stageWidth - this.pBroadCast.speaker_bt.width;
        this.pBroadCast.y = this.inputBox.y + this.inputBox.height;

        this.inputBox.x = this.pBroadCast.x + this.pBroadCast.speaker_bt.width - this.inputBox.width;
        this.marqueeText.x = this.pBroadCast.x;
        this.marqueeText.y = this.pBroadCast.y;

        this.marqueeText.tweenWidth();
    }

    private function onRemoveToStageHandler(e:Event):void {
        this.removeEventListener(Event.ADDED_TO_STAGE, onAddToStageHandler);
        this.removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveToStageHandler);
        this.removeEventListener(MouseEvent.CLICK, onClickHandler);
        this.inputBox.removeEventListener(FocusEvent.FOCUS_IN, onSetIMEHandler);
        this.inputBox.removeEventListener(Event.REMOVED_FROM_STAGE, onInputBoxRemovedHandler);
        this.infoTxt.removeEventListener(Event.CHANGE, onInputHandler);
    }
}
}