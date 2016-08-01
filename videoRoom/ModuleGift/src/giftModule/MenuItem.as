package giftModule {
import flash.text.TextFormat;

public class MenuItem extends menuItemMc {
    private var _textFormat:TextFormat = new TextFormat("宋体", 14, 0xb3b9c5, false);
    private var _selectFormat:TextFormat = new TextFormat("宋体", 14, 0x4dc2ff, true);
    public var selectIndex:int = 0;
    public var dataObject:Object = null;
    private var _selected:Boolean = false;

    public function MenuItem(_item:Object = null):void {
        this.buttonMode = true;
        this.mouseChildren = false;
        if (_item && _item.label) {
            this.label = _item.label;
        }
        this.dataObject = _item;
        this.txt.setTextFormat(this._textFormat);
    }

    public function set label(_v:String):void {
        this.txt.text = _v;
    }

    public function set selected(_v:Boolean):void {
        if (_v) {
            this.txt.setTextFormat(this._selectFormat);
        } else {
            this.txt.setTextFormat(this._textFormat);
        }
        this._selected = _v;
    }

    public function get selected():Boolean {
        return this._selected;
    }
}
}