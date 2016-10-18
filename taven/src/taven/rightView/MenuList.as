package taven.rightView {
import flash.display.Sprite;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

import right.menuListMc;

public class MenuList extends menuListMc {
    private var bgBitmap:ScaleBitmap;
    private var items_mc:Sprite;
    public var selectItem:MenuItem;
    public var selectIndex:int;
    private var head_mc:MenuUserInfo;
    private var userBool:Boolean = false;

    public function MenuList():void {
        this.visible = false;
        this.bgBitmap = new ScaleBitmap(new bg_LIST_BGMc(23, 24));
        this.bgBitmap.scale9Grid = new Rectangle(5, 5, 5, 5);
        this.addChildAt(bgBitmap, 0);
        this.head_mc = new MenuUserInfo();
        this.head_mc.visible = false;
        this.head_mc.x = 15;
        this.head_mc.y = 15;
        this.addChild(this.head_mc);
        this.items_mc = new Sprite;
        this.items_mc.x = 3;
        this.items_mc.y = 75;
        this.addChild(this.items_mc);
        this.items_mc.addEventListener(MouseEvent.CLICK, _itemsClickEvent);
        this.addEventListener(FocusEvent.FOCUS_OUT, _focusOutEvent);
        addEventListener(Event.ADDED_TO_STAGE, onStageHandle);
    }

    private function onStageHandle(event:Event):void {
        stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
    }

    private function onMouseDown(event:MouseEvent):void {
        if (stage) {
            if (this.hitTestPoint(stage.mouseX, stage.mouseY) == false) {
                this.visible = false;
            }
        }
    }

    public function userInfoMenus(_obj:Object, _arr:Array):void {
        this.head_mc.formatData(_obj);
        this.initMenus(_arr, true);
    }

    public function initMenus(_ar:Array, _userBool:Boolean = false):void {
        this.userBool = _userBool;
        if (this.userBool) {
            this.head_mc.visible = true;
            this.items_mc.y = 75;
        } else {
            this.head_mc.visible = false;
            this.items_mc.y = 3;
        }
        while (this.items_mc.numChildren > 0) {
            this.items_mc.removeChildAt(0);
        }
        if (_ar && _ar.length) {
            for (var i:int = 0; i < _ar.length; i++) {
                this.addItem(_ar[i]);
            }
            this.visible = true;
        } else {
            this.visible = false;
        }
    }

    public function addItem(_obj:Object):void {
        var _item:MenuItem = new MenuItem;
        _item.formatItem(_obj);
        this.items_mc.addChild(_item);
        var tempItem:MenuItem, _w:int = 200, i:int = 0;
        for (i = 0; i < this.items_mc.numChildren; i++) {
            tempItem = this.items_mc.getChildAt(i) as MenuItem;
            if (tempItem) {
                tempItem.name = i.toString();
                tempItem.y = i * 36;
                if (tempItem.width > _w) {
                    _w = tempItem.width;
                }
            }
        }
        for (i = 0; i < this.items_mc.numChildren; i++) {
            tempItem = this.items_mc.getChildAt(i) as MenuItem;
            if (tempItem) {
                tempItem.renderGraphics(_w);
            }
        }
        if (this.userBool) {
            this.bgBitmap.setSize(_w, this.items_mc.numChildren * 36 + 80);
        } else {
            this.bgBitmap.setSize(_w, this.items_mc.numChildren * 36 + 6);
        }
    }

    private function _itemsClickEvent(e:MouseEvent):void {
        if (e.target is MenuItem) {
            this.selectIndex = int(e.target.name);
            this.selectItem = e.target as MenuItem;
            this.visible = false;
            this.dispatchEvent(new Event("menuListSelectEvent"));
        }
    }

    private function _focusOutEvent(e:Event):void {
        this.visible = false;
    }
}
}