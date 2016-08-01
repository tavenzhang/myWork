package taven.seatView {
import com.greensock.TimelineLite;
import com.greensock.TweenLite;
import com.greensock.TweenMax;
import com.greensock.easing.Linear;

import flash.events.MouseEvent;
import flash.utils.clearInterval;

import seatsModule.parkLoadMc;

import taven.utils.HeadIconBuildTool;

import tool.FormatDataTool;

public class ParkLoad extends parkLoadMc {
    private static var TEXT_X:int = -40;
    private static var TEXT_WIDTH:int = 80;
    private var txtTween:TweenLite;
    private var inteverId:uint;
    public var dataObject:Object = {};
    public var timeline:TimelineLite = new TimelineLite();
    public var _speekMc:SpeedkTxt;

    public function ParkLoad():void {
        this.load_mc.mouseChildren = false;
        this.load_mc.mouseEnabled = false;
        this.load_mc.width = 45;
        this.load_mc.height = 45;
        this.load_mc.mask = this.mask_mc;
        this.name_txt.mask = this.fontMask;
        this.name_txt.addEventListener(MouseEvent.ROLL_OVER, onOverHandler);
        //this.showTxtTween();
        _speekMc = new SpeedkTxt();
        _speekMc.alpha = 0;
        addChild(_speekMc);
    }

    public function formatData(_v:Object):void {
        this.visible = true;
        this.dataObject = _v;
        this.name_txt.text = FormatDataTool.getNickeNameByInt(_v.name, _v.hidden);
        HeadIconBuildTool.loaderUserHead(_v.headimg, this.load_mc)
    }

    public function setSpeak(str:String):void {
        var pattern:RegExp = /{@BQ_[0-9]+}|(\/[0-9]+)/g;
        var str2:String = str.replace(pattern, "");
        if (str2.length == 0)
            return;
        timeline.append(TweenMax.to(_speekMc, 1, {
            onStart: onStartFunc,
            alpha: 1,
            repeat: 1,
            yoyo: true,
            repeatDelay: 4
        }));
        function onStartFunc():void {
            _speekMc.setText(str2);
        }
    }

    private function onOverHandler(e:MouseEvent):void {
        if (txtTween == null || !txtTween.isActive())
            this.showTxtTween();
    }

    //名字动画
    private function showTxtTween():void {
        if (this.name_txt.textWidth <= ParkLoad.TEXT_WIDTH)
            return;
        if (this.inteverId != 0)
            clearInterval(this.inteverId);
        var tempX:int = this.name_txt.x + this.name_txt.width - this.name_txt.textWidth - 10;
        txtTween = TweenLite.to(this.name_txt, 5, {x: tempX, ease: Linear.easeNone, onComplete: onCompleteHandler});
        this.name_txt.width = this.name_txt.textWidth + 5;
    }

    private function onCompleteHandler():void {
        this.name_txt.x = ParkLoad.TEXT_X;
        this.name_txt.width = ParkLoad.TEXT_WIDTH;
    }
}
}

import flash.display.Sprite;
import flash.filters.DropShadowFilter;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

class SpeedkTxt extends Sprite {
    public var bg:ScaleBitmap = new ScaleBitmap(new txtbg());
    public var textF:TextField = new TextField();

    public function SpeedkTxt():void {
        bg.scale9Grid = new Rectangle(12, 6, 40, 28);
        addChild(bg);
        addChild(textF);
        textF.autoSize = TextFormatAlign.LEFT;
        textF.x = 10;
        textF.y = 10;
        textF.defaultTextFormat = new TextFormat("宋体", 12, 0xffffff);
        mouseChildren = false;
        mouseEnabled = false;
        var filter:flash.filters.DropShadowFilter = new DropShadowFilter(3);
        this.filters = [filter];
    }

    public function setText(src:String):void {
        textF.text = src;
        bg.width = textF.textWidth + 20;
        y = -80;
        x = -bg.width + 20;
    }
}