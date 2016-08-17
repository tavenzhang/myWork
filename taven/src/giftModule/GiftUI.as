package giftModule {
import com.greensock.TweenLite;
import com.junkbyte.console.Cc;

import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.events.SecurityErrorEvent;
import flash.events.TimerEvent;
import flash.filters.ColorMatrixFilter;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.text.TextFormat;
import flash.utils.Timer;

public class GiftUI extends giftUIMc {
    private var giftSend_bt:SimpleButton;
    private var menuGroup:Sprite;
    private var giftGroup:Sprite;
    private var itemGroup:Sprite;
    private var _box:ChoiceBox;
    private var _selectIndex:int = -1;
    private var giftSelectObject:LoadGiftElement;
    private var giftsArray:Array = new Array(50);
    private var _colorFilter:Array = [new ColorMatrixFilter([0.3, 0.3, 0.3, 0, 0, 0.3, 0.3, 0.3, 0, 0, 0.3, 0.3, 0.3, 0, 0, 0, 0, 0, 1, 0])];
    private var _timer:Timer;//计时滚动时间
    private var _scrollBoolean:Boolean = true;//可以滚动
    private var _textFormat:TextFormat = new TextFormat("宋体", 12, 0x91a1ad, true);
    private var _textFormat2:TextFormat = new TextFormat("宋体", 12, 0xccdae7, true);
    //*数据
    private var giftLoadData:URLLoader;
    private var giftDataObject:Object;
    private var giftLoadDepot:URLLoader;
    private var giftDepotObject:Object;
    private var giftDataURL:String = "";
    private var giftDepotURL:String = "";
    private var giftIconURL:String = "";



    public function GiftUI():void {
        this.menuOver_mc.alpha = 0;
        this.menuSelect_mc.visible = false;
        this.giftSend_bt = this.control_mc.giftSend_bt;
        //鼠标触发层
        this.base_mc.mouseChildren = false;
        this.base_mc.x = this.mask_mc.x;
        this.base_mc.y = this.mask_mc.y;
        this.base_mc.width = this.mask_mc.width;
        this.base_mc.height = this.mask_mc.height;
        this.giftGroup = new Sprite;
        this.giftGroup.y = this.mask_mc.y;
        this.giftGroup.mask = this.mask_mc;
        this.addChildAt(this.giftGroup, this.getChildIndex(this.mask_mc));
        this.itemGroup = new Sprite;
        this.itemGroup.mouseEnabled = false;
        this.itemGroup.addEventListener(MouseEvent.CLICK, _giftItemClickEvent);
        this.giftGroup.addChild(this.itemGroup);
        this.focus_mc.mouseChildren = false;
        this.focus_mc.mouseEnabled = false;
        this.focus_mc.visible = false;
        this.focus_mc.txt.autoSize = "left";
        this.focus_mc.txt.wordWrap = true;
        giftSelect_mc.mouseChildren = false;
        giftSelect_mc.mouseEnabled = false;
        giftSelect_mc.visible = false;
        for (var i:int = 0; i < this.giftsArray.length; i++) {
            var _clip:LoadGiftElement = new LoadGiftElement();
            _clip.name = "LoadGiftElement" + i;
            _clip.title_mc = this.focus_mc;
            _clip.doubleClickEnabled = true;
            _clip.addEventListener(MouseEvent.DOUBLE_CLICK, doubleClick);
            giftsArray[i] = _clip;
        }

        this.addEventListener(Event.ADDED_TO_STAGE, _addedToStageEvent);
        this.addEventListener(MouseEvent.CLICK, _clickMouseEvent);
        this.giftEnabled = false;
        this._timer = new Timer(1000);
        this._timer.addEventListener(TimerEvent.TIMER, _tmerEvent);
        this.control_mc.title_txt.defaultTextFormat = this._textFormat;
        this.control_mc.title_txt.setTextFormat(this._textFormat);
        this.control_mc.gift_txt.defaultTextFormat = this._textFormat2;
    }

    override public function get height():Number {
        return super.height;
    }

    override public function set height(value:Number):void {
        this.mask_mc.height = value - this.mask_mc.y;
        this.base_mc.height = this.mask_mc.height;
        this.control_mc.y = value - 30 + this.mask_mc.y;
    }

    private function set giftEnabled(_v:Boolean):void {
        if (_v) {
            this.giftSend_bt.filters = null;
            this.giftSend_bt.mouseEnabled = true;
            this.control_mc.gift_txt.text = this.giftSelectObject.dataObject.name;
        } else {
            this.control_mc.gift_txt.text = "";
            this.giftSend_bt.filters = this._colorFilter;
            this.giftSend_bt.mouseEnabled = false;
        }
    }

    public function doubleClick(e:MouseEvent):void {
        giftSend_bt.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
    }

    private function _addedToStageEvent(e:Event):void {
        this.removeEventListener(Event.ADDED_TO_STAGE, _addedToStageEvent);
        this.giftSend_bt.visible = true;
        this.stage.addChild(this.focus_mc);
        this.initComboBox();
    }

    private function initComboBox():void {
        this._box = new ChoiceBox();
        this._box.x = 115;
        this._box.y = 6;
        this.control_mc.addChild(this._box);
    }

    private function initMenus(_ar:Array):void {
        this.menuGroup = new Sprite;
        this.menuGroup.x = 170;
        this.menuGroup.y = 20;
        this.menuGroup.addEventListener(MouseEvent.MOUSE_OVER, _menuOverEvent);
        this.menuGroup.addEventListener(MouseEvent.ROLL_OUT, _menuOutEvent);
        this.menuGroup.addEventListener(MouseEvent.CLICK, _menuClickEvent);
        this.addChild(this.menuGroup);
        var _item:MenuItem;
        for (var i:int = 0; i < _ar.length; i++) {
            _item = new MenuItem(_ar[i]);
            _item.x = i * _item.width;
            _item.selectIndex = i;
            this.menuGroup.addChild(_item);
        }
        this.selectIndex = 0;
    }

    private function _menuOverEvent(e:MouseEvent):void {
        TweenLite.to(this.menuOver_mc, .5, {"alpha": 1, "x": e.target.x + this.menuGroup.x});
    }

    private function _menuOutEvent(e:MouseEvent):void {
        TweenLite.to(this.menuOver_mc, .3, {"alpha": 0});
    }

    private function _menuClickEvent(e:MouseEvent):void {
        this.menuOver_mc.alpha = 0;
        TweenLite.to(this.menuOver_mc, .3, {"alpha": 1});
        var _item:MenuItem = e.target as MenuItem;
        if (_item) {
            this.selectIndex = _item.selectIndex;
        }
    }

    public function set selectIndex(_v:int):void {
        if (this._selectIndex == _v) {
            return;
        }
        this._selectIndex = _v;
        var _item:MenuItem = this.menuGroup.getChildAt(_v) as MenuItem;
        if (_item) {
            for (var i:int = 0; i < this.menuGroup.numChildren; i++) {
                MenuItem(this.menuGroup.getChildAt(i)).selected = false;
            }
            _item.selected = true;
            this.menuOver_mc.x = this.menuGroup.x + _item.x;
            this.menuSelect_mc.x = this.menuOver_mc.x + _item.width / 2;
            if (this.giftDataObject && this.selectIndex < this.giftDataObject.length) {//礼物列表
                try {
                    this.updateGifts(this.giftDataObject[this.selectIndex].items);
                } catch (e:*) {
                    this.updateGifts([]);
                }
            } else {//库存
                this.updateGifts([]);
                this.loadDepot();//更新库存信息
            }
            this.menuSelect_mc.visible = true;
        }
    }

    public function get selectIndex():int {
        return this._selectIndex;
    }

    /**
     * 刷新下面的小礼物格子内容
     * @param _items
     */
    public function updateGifts(_items:Array = null):void {
        var _gift:LoadGiftElement;
        this.giftSelect_mc.visible = false;
        this.giftSelect_mc.y = 15;
        while (this.itemGroup.numChildren > 0) {
            this.itemGroup.removeChildAt(0);
        }
        TweenLite.killTweensOf(this.itemGroup);
        this.itemGroup.y = 0;
        this.stage.focus = this.stage;
        this._box.reset();
        this.giftEnabled = false;
        this.itemGroup.x = this.mask_mc.x;
        if (_items && _items.length > 0) {
            for (var i:int = 0; i < _items.length; i++) {
                _gift = this.giftsArray[i];
                _gift.x = i * (70 + 15) + 10;
                _gift.y = 13;
                //VideoConfig.HTTP
                _gift.load(giftIconURL + "image/gift_material/" + _items[i].gid + ".png");
                _gift.dataObject = _items[i];
                this.itemGroup.addChild(_gift);
            }
        }
        this.itemGroup.addChild(this.giftSelect_mc);
        if (_items.length > 0) {
            focusOnGift(giftsArray[0]);
        }
    }

    private function _giftItemClickEvent(e:MouseEvent):void {
        var _mc:LoadGiftElement = e.target as LoadGiftElement;
        if (!_mc) {
            return;
        }
        focusOnGift(_mc);
    }

    /**
     * 当焦点落在礼物框上面的时候
     * @param src
     */
    public function focusOnGift(src:LoadGiftElement):void {
        this.giftSelectObject = src;//选中的对应
        this.giftSelect_mc.visible = true;
        this.giftSelect_mc.y = this.giftSelectObject.y;
        TweenLite.to(this.giftSelect_mc, .3, {"x": src.x});
        this.stage.focus = this.stage;
        //this._box.reset();
        this.giftEnabled = true;
    }

    //----------------加载数据
    public function configURLS(_dataurl:String, _depoturl:String, _iconurl:String):void {
        this.giftDataURL = _dataurl;
        this.giftDepotURL = _depoturl;
        this.giftIconURL = _iconurl;
        this.loadData(this.giftDataURL);
    }

    public function loadData(_url:String):void {
        if (_url == "") {
            //trace("url is null")
            return;
        }
        if (!this.giftLoadData) {
            this.giftLoadData = new URLLoader();
        }
        var surl:String=_url + "?v=" + int(Math.random() * 100000);
        this.giftLoadData.load(new URLRequest(surl));
        Cc.log("sur==="+surl);
        this.giftLoadData.addEventListener(IOErrorEvent.IO_ERROR, _loadDataErrorEvent);
        this.giftLoadData.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _loadDataErrorEvent);
        this.giftLoadData.addEventListener(Event.COMPLETE, _loadDataComplete);
    }

    private function _loadDataErrorEvent(e:*):void {
        //trace("_loadDataErrorEvent")
    }

    private function _loadDataComplete(e:Event):void {
        //trace("gift2:",e.target.data)
        try {
            giftData = JSON.parse(e.target.data);

        } catch (error:Error) {
            trace("礼物模块数据加载出错...");
        }
    }

    public function set giftData(_v:Object):void {
        this.giftDataObject = _v;
        Cc.log("giftData==="+_v.toString());
        var _menuArr:Array = [];
        if (this.giftDataObject) {
            for (var i:int = 0; i < this.giftDataObject.length; i++) {
                _menuArr.push({"label": this.giftDataObject[i].name, "data": this.giftDataObject[i].category});
            }
        } else {
            _menuArr = [{"label": "初级", "data": 1}, {"label": "中级", "data": 2}, {
                "label": "高级",
                "data": 3
            }, {"label": "豪华", "data": 4}, {"label": "特殊", "data": 5}]
        }
//        _menuArr.push({"label": "库存", "data": 0});
        this.initMenus(_menuArr);
    }

    /**
     * 加载库存
     */
    public function loadDepot():void {
        if (this.giftDepotURL == "") {
            return;
        }
        if (!this.giftLoadDepot) {
            this.giftLoadDepot = new URLLoader();
        }
        this.giftLoadDepot.load(new URLRequest(this.giftDepotURL + "?v=" + int(Math.random() * 100000)));
        this.giftLoadDepot.addEventListener(IOErrorEvent.IO_ERROR, _loadDepotErrorEvent);
        this.giftLoadDepot.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _loadDepotErrorEvent);
        this.giftLoadDepot.addEventListener(Event.COMPLETE, _loadDepotComplete);
    }

    private function _loadDepotErrorEvent(e:*):void {
    }

    private function _loadDepotComplete(e:Event):void {
        this.giftDepotObject = JSON.parse(e.target.data);
        if (!this.giftDepotObject || !this.giftDataObject) {
            return;
        }
        for (var i:int = 0; i < this.giftDepotObject.length; i++) {
            outerFor:for (var n:int = 0; n < this.giftDataObject.length; n++) {
                for (var k:int = 0; k < this.giftDataObject[n].items.length; k++) {
                    if (this.giftDepotObject[i].gid == this.giftDataObject[n].items[k].gid) {
                        for (var v:* in this.giftDataObject[n].items[k]) {
                            this.giftDepotObject[i][v] = this.giftDataObject[n].items[k][v];
                        }
                        break outerFor;
                    }
                }
            }
        }
        if (this.selectIndex >= this.giftDataObject.length) {
            this.updateGifts(this.giftDepotObject as Array);
        }
    }

    //##############  礼物模块给外部用的三个变量  ##########
    public var gid:Number;
    public var gnum:Number;

    public function sendGift():void {
        if (giftSelectObject) {
            gid = giftSelectObject.dataObject.gid;
            if (_box.view.numTxt.text.length > 0) {
                gnum = _box.giftNum;
                dispatchEvent(new Event("sendGift"));
            } else {
                trace("礼物数量长度小于0")
            }
        }
    }

    //--------------------------------------
    //事件
    private function _clickMouseEvent(e:Event):void {
        switch (e.target.name) {
            case "giftSend_bt":
//              trace("sendGift");
                sendGift();
                break;
            case "left_bt":
                prevScroll();
                break;
            case "right_bt":
                nextScroll();
                break;
            case "pay_bt":
                dispatchEvent(new Event("rechargeEvent", true));
                break;
            default:
        }
    }

    private function _tmerEvent(e:TimerEvent):void {
        this._timer.reset();
        this._scrollBoolean = true;
    }

    //往前
    public function prevScroll():void {
        if (!this._scrollBoolean || int(this.itemGroup.x) >= int(this.mask_mc.x)) {
            return;
        }
        this._scrollBoolean = false;
        var _x:Number = this.itemGroup.x;
        _x += 510;
        if (_x > int(this.mask_mc.x)) {
            _x = int(this.mask_mc.x);
        }
        TweenLite.to(this.itemGroup, 1, {"x": int(_x)});
        this._timer.start();//防误点
    }

    //往后
    public function nextScroll():void {
        if (!this._scrollBoolean || int(this.itemGroup.width + this.itemGroup.x - int(this.mask_mc.x)) < 510) {
            return;
        }
        this._scrollBoolean = false;
        var _x:Number = this.itemGroup.x;
        _x -= 510;
        TweenLite.to(this.itemGroup, 1, {"x": int(_x)});
        this._timer.start();//防误点
    }
}
}