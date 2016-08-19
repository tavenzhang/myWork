package taven.seatView {
import flash.display.SimpleButton;
import flash.events.MouseEvent;

import seatsModule.userparkMc;

public class Userpark extends userparkMc {
    public var parkData:Array;
    private var _tempDataObject:Object;
    private var parkArr:Array;
    public var num_box:NumBox = new NumBox();
    public var load1_mc:ParkLoad;
    public var load2_mc:ParkLoad;
    public var load3_mc:ParkLoad;
    public var load4_mc:ParkLoad;

    public function Userpark():void {
        this.parkArr = [];
        this.parkArr.push("");
        load1_mc = buildLoaderMc(23, 23);
        load2_mc = buildLoaderMc(198, 23);
        load3_mc = buildLoaderMc(370, 23);
        load4_mc = buildLoaderMc(545, 23);
        addChild(park1_bt);
        addChild(park2_bt);
        addChild(park3_bt);
        addChild(park4_bt);
        addChild(title_mc);
        this.title_mc.visible = false;
        addChild(num_box);
        num_box.visible = false;
        this.addEventListener(MouseEvent.CLICK, _parkMouseEvent);
        this.addEventListener(MouseEvent.MOUSE_OVER, _overMouseEvent);
        this.addEventListener(MouseEvent.ROLL_OUT, _outMouseEvent);
    }

    private function buildLoaderMc(_x:Number, _y:Number):ParkLoad {
        var _mc:ParkLoad = new ParkLoad();
        _mc.x = _x;
        _mc.y = _y;
        _mc.visible = false;
        addChild(_mc);
        parkArr.push(_mc);
        return _mc;
    }
    private function dispatchModuleEvent(_code:String, _data:Object):void {
        this.dispatchEvent(new ktvEvent(_data, _code));
    }

    private function _parkMouseEvent(e:MouseEvent):void {
        var _sbt:SimpleButton = e.target as SimpleButton;
        if (_sbt) {
            switch (_sbt.name) {
                case "park1_bt":
                    this.num_box.x = _sbt.x;
                    this.num_box.base = int(this.load1_mc.dataObject.num) + 1;
                    this._tempDataObject = this.load1_mc.dataObject;
                    break;
                case "park2_bt":
                    this.num_box.x = _sbt.x;
                    this.num_box.base = int(this.load2_mc.dataObject.num) + 1;
                    this._tempDataObject = this.load2_mc.dataObject;
                    break;
                case "park3_bt":
                    this.num_box.x = _sbt.x;
                    this.num_box.base = int(this.load3_mc.dataObject.num) + 1;
                    this._tempDataObject = this.load3_mc.dataObject;
                    break;
                case "park4_bt":
                    this.num_box.x = _sbt.x;
                    this.num_box.base = int(this.load4_mc.dataObject.num) + 1;
                    this._tempDataObject = this.load4_mc.dataObject;
                    break;
                case "submit_bt":
                    this._tempDataObject.value = this.num_box.value;
                    this.dispatchModuleEvent("seizePark", this._tempDataObject);
                    this.num_box.visible = false;
                    return;
                default:
            }
            this.title_mc.visible = false;
            this.num_box.visible = true;
        }
    }

    public function parksData(_arr:Array):void {
        for (var i:int = 0; i < _arr.length; i++) {
            this.setHold(i + 1, _arr[i]);
        }
        this.parkData = _arr;
    }

    public function setHold(_index:int = 1, _obj:Object = null):void {
        switch (_index) {
            case 1:
                if (_obj && _obj.num > 0) {
                    this.load1_mc.visible = true;
                    this.load1_mc.formatData(_obj);
                }
                this.load1_mc.dataObject = _obj;
                break;
            case 2:
                if (_obj && _obj.num > 0) {
                    this.load2_mc.visible = true;
                    this.load2_mc.formatData(_obj);
                }
                this.load2_mc.dataObject = _obj;
                break;
            case 3:
                if (_obj && _obj.num > 0) {
                    this.load3_mc.visible = true;
                    this.load3_mc.formatData(_obj);
                }
                this.load3_mc.dataObject = _obj;
                break;
            case 4:
                if (_obj && _obj.num > 0) {
                    this.load4_mc.visible = true;
                    this.load4_mc.formatData(_obj);
                }
                this.load4_mc.dataObject = _obj;
                break;
            default:
        }
    }

    public function setParkSpeak(obj:Object):void {
        for each(var park:Object in this.parkData) {
            if (park.uid == obj.uid) {
                this.parkArr[park.seatid].setSpeak(obj.msg);
            }
        }
    }

    private function _overMouseEvent(e:MouseEvent):void {
        var _sbt:SimpleButton = e.target as SimpleButton;
        var _bool:Boolean = false;
        if (_sbt) {
            switch (_sbt.name) {
                case "park1_bt":
                    if (!this.load1_mc.dataObject || int(this.load1_mc.dataObject.num) == 0) {
                        _bool = true;
                    }
                    break;
                case "park2_bt":
                    if (!this.load2_mc.dataObject || int(this.load2_mc.dataObject.num) == 0) {
                        _bool = true;
                    }
                    break;
                case "park3_bt":
                    if (!this.load3_mc.dataObject || int(this.load3_mc.dataObject.num) == 0) {
                        _bool = true;
                    }
                    break;
                case "park4_bt":
                    if (!this.load4_mc.dataObject || int(this.load4_mc.dataObject.num) == 0) {
                        _bool = true;
                    }
                    break;
                default:
            }
            if (_bool && !this.num_box.visible) {
                this.title_mc.x = _sbt.x;
                this.title_mc.visible = true;
            }
        }
    }

    private function _outMouseEvent(e:MouseEvent):void {
        this.title_mc.visible = false;
        this.num_box.visible = false;
    }

    //单价
    public function set price(_v:int):void {
        if (_v < 0) {
            _v = 1;
        }
        this.num_box.coe = _v;//输入框系数
    }

    public function get price():int {
        return this.num_box.coe;
    }
}
}