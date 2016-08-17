package display.ui {
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

public class Alert extends Alert_UI {
    private var yesEvent:Event;
    private var noEvent:Event;
    private var rect:Rectangle;
    private static var _alert:Alert;
    private var dwFuc:Function;
    private var args:Object;

    public function Alert():void {
        _alert = this;
        this.visible = false;

        //this.textFormat = new TextFormat("黑体",null,null, true);
        this.title_txt.mouseEnabled = false;
        this.tabChildren = false;
        this.tabEnabled = false;
        this.yesEvent = new Event("EventYes");
        this.noEvent = new Event("EventNo");

        this.yes_bt.addEventListener(MouseEvent.CLICK, yes_click);
        this.no_bt.addEventListener(MouseEvent.CLICK, no_click);
        this.close_bt.addEventListener(MouseEvent.CLICK, no_click);
        this.alert_bt.addEventListener(MouseEvent.CLICK, yes_click);
        this.addEventListener(Event.ADDED_TO_STAGE, _addToStageEvent);
    }

    private function _addToStageEvent(e:Event):void {
        this.removeEventListener(Event.ADDED_TO_STAGE, _addToStageEvent);
        //this.rect = new Rectangle(0, 0, this.stage.stageWidth - this.bound_mc.width, this.stage.stageHeight - this.bound_mc.height);

        this.stage.addEventListener(Event.RESIZE, _stageResizeEvent);
    }

    private function _stageResizeEvent(e:Event):void {

    }

    private function top_down(e:MouseEvent):void {
        this.startDrag(false, this.rect);
    }

    private function top_up(e:MouseEvent):void {
        this.stopDrag();
    }

    public static function Show(srt:String = "", title:String = "消息", alert_bool:Boolean = true, num:int = 3, enabled:Boolean = false, _function:Function = null, _arg:Object = null):Alert {
        if (!_alert) {
            return null;
        }
        _alert.Show(srt, title, alert_bool, num, enabled, _function, _arg);
        return _alert;
    }

    //警告框
    internal function Show(srt:String = "", title:String = "消息", alert_bool:Boolean = true, num:int = 3, enabled:Boolean = false, _function:Function = null, _arg:Object = null):Alert {
        try {

            this.visible = true;
            this.alert_bt.visible = alert_bool;
            this.yes_bt.visible = Boolean(!alert_bool);
            this.no_bt.visible = Boolean(!alert_bool);
            this.title_txt.text = title;
            this.txt.text = srt;
            //this.title_txt.setTextFormat(this.textFormat)
            this.x = (stage.stageWidth - this.width) / 2;
            this.y = (stage.stageHeight - this.height) / 2;
            this.dwFuc = _function;
            this.args = _arg;
        } catch (e:Error) {
        }
        return this;
    }

    private function yes_click(e:MouseEvent):void {
        this.visible = false;
        dispatchEvent(this.yesEvent);
        if (this.dwFuc != null) {
            if (this.args) {
                this.dwFuc(this.args);
            } else {
                this.dwFuc(1);
            }
        }
    }

    private function no_click(e:MouseEvent):void {
        this.visible = false;
        dispatchEvent(this.noEvent);
        if (this.dwFuc != null) {
            //this.dwFuc(0);
        }
    }
}
}