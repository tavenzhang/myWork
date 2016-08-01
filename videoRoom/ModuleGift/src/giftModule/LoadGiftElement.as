package giftModule {
import com.greensock.TweenLite;

import flash.display.MovieClip;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.text.TextField;
import flash.text.TextFormat;

public class LoadGiftElement extends loadGiftElementMc {
    public var title_mc:MovieClip;
    public var price_txt:TextField;
    public var load_mc:CGLoader;
    private var _dataObject:Object = null;
    private var newIcon:isNewMc;

    public function LoadGiftElement():void {
        load_mc = new CGLoader();
        addChild(load_mc);
        price_txt = new TextField();
        price_txt.defaultTextFormat = new TextFormat("宋体");
        price_txt.textColor = 0xffffff;
        var filter:flash.filters.GlowFilter = new GlowFilter(0, 1, 2, 2, 4);
        price_txt.filters = [filter];
        //price_txt.background = true;
        //price_txt.backgroundColor = 0x999999;
        price_txt.height = 20;
        price_txt.width = 80;
        addChild(price_txt);
        addChild(num_txt);
        this.price_txt.visible = false;
        this.price_txt.mouseEnabled = false;
        this.num_txt.mouseEnabled = false;
        this.buttonMode = true;
        this.mouseChildren = false;
        this.giftOver_mc.visible = false;
        this.addEventListener(MouseEvent.ROLL_OVER, _giftOverEvent);
        this.addEventListener(MouseEvent.ROLL_OUT, _giftOutEvent);
        this.addEventListener(MouseEvent.MOUSE_MOVE, _giftMoveEvent);
        this.addEventListener(MouseEvent.CLICK, _giftClickEvent);
        newIcon = new isNewMc();
        newIcon.x = 46;
        addChild(newIcon);
    }

    private function _giftOverEvent(e:MouseEvent):void {
        this.giftOver_mc.visible = true;
        this.titleShow = true;
    }

    private function _giftOutEvent(e:MouseEvent):void {
        this.giftOver_mc.visible = false;
        this.titleShow = false;
    }

    private function _giftClickEvent(e:MouseEvent):void {
    }

    private function _giftMoveEvent(e:MouseEvent = null):void {
        if (this.title_mc && this.title_mc.visible) {
            this.title_mc.x = this.stage.mouseX + 15;
            this.title_mc.y = this.stage.mouseY - this.title_mc.height / 3;
        }
    }

    private function set titleShow(_v:Boolean):void {
        if (!this.title_mc || !this.dataObject) {
            return;
        }
        if (_v) {
            this.title_mc.txt.text = this.dataObject.name + "\n价格:" + this.dataObject.price + "钻石\n" + this.dataObject.desc;
            this.title_mc.bg_mc.height = this.title_mc.txt.height + 10;
            this.title_mc.visible = true;
            this._giftMoveEvent();
            this.title_mc.alpha = 0;
            TweenLite.to(this.title_mc, 1, {"alpha": 1, "delay": 1});
        } else if (this.title_mc.visible) {
            TweenLite.to(this.title_mc, .5, {"alpha": 0, "onComplete": titleComplete(false)});
        }
    }

    private function titleComplete(_v:Boolean):void {
        if (!_v) {
            this.title_mc.visible = false;
        }
    }

    public function set dataObject(_obj:Object):void {
        this._dataObject = _obj;
        if (!this._dataObject) {
            return;
        }
        this.label = this._dataObject.name;
        this.price_txt.visible = false;
        if (this._dataObject.hasOwnProperty("num")) {
            this.num_txt.text = String(this._dataObject.num);
        } else {
            this.num_txt.text = "";
            this.price_txt.text = this.dataObject.price + "钻石";
            this.price_txt.visible = true;
        }
        if (_obj.isNew == 1) {
            newIcon.visible = true;
            //trace("这个事新的");
        } else {
            newIcon.visible = false;
        }
    }

    public function get dataObject():Object {
        return this._dataObject;
    }

    public function set label(_v:String):void {
        this.txt.text = _v;
    }

    public function get label():String {
        return this.txt.text;
    }

    public function load(_url:String):void {
        this.load_mc.loadHead(_url);
    }
}
}

import flash.display.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.geom.Point;
import flash.net.URLRequest;

class CGLoader extends Loader {
    public function CGLoader() {
        this.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function (e:IOErrorEvent):void {
        });
        this.contentLoaderInfo.addEventListener(Event.COMPLETE, function (e:Event):void {
            var point:Point = new Point(8, 8);
            content.x = point.x;
            content.y = point.y + 3;
            content.width = 70 - point.x * 2;
            content.height = 70 - point.y * 2;
        })
    }

    public function loadHead(src:String):void {
        this.load(new URLRequest(src));
    }
}