/**
 * Created by Roger on 2014/12/1.
 */
package com.kingjoy.view {
import com.rover022.vo.GiftVo;
import com.rover022.vo.VideoConfig;

import flash.display.DisplayObjectContainer;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import flash.net.URLRequest;
import flash.text.TextField;
import flash.utils.setTimeout;

import ghostcat.manager.RootManager;
import ghostcat.ui.PopupManager;
import ghostcat.ui.RootLoader;

import manger.ClientManger;

import tool.CTimeoutOper;
import tool.VideoTool;

/**
 * 礼物池...
 */
public class GiftPool {
    public var giftArray:Vector.<GiftView>;
    public var showSpace:Array = new Array(4);
    /**
     * 调节礼物池的大小
     */
    public var maxSpace:int = 8;
    /**
     *  父的容器
     */

    //    public var effDiction:Dictionary;
    [Embed(source="/com/kingjoy/view/g_data.xml", mimeType="application/octet-stream")]
    public var dataClassXML:Class;
    private var xmlData:XML;

    public function GiftPool() {
        xmlData = XML(new dataClassXML());
        giftArray = new <GiftView>[];
    }

    public function getFixGiftArry(num:int):Array {
        //var _temp:String = effDiction[num];
        var _temp:String = String(xmlData.item.(@num == num));
        if (_temp.length > 1) {
            var _arr:Array = _temp.split(",");
            for (var i:int = 0; i < _arr.length; i++) {
                var object:Array = String(_arr[i]).split("_");
                _arr[i] = object;
            }
            return _arr;
        } else {
            return [];
        }
    }

    /**
     * 检查
     */
    private function checkPool(event:Event = null):void {
        if (giftArray.length == 0) {
            return;
        }
        var body:GiftView = giftArray[0];
        for (var i:int = 0; i < maxSpace; i++) {
            var object:GiftView = showSpace[i];
            if (object == null) {
                showGiftToTable(body, i);
                return;
            }
            if (object && object.parent == null) {
                showGiftToTable(body, i);
                return;
            }
        }
    }

    private function showGiftToTable(src:GiftView, i:int):void {
        //remove
        var index:int = giftArray.indexOf(src);
        giftArray.splice(index, 1);
        //show
        src.addEventListener(Event.REMOVED, checkPool, false, 0, true);
        showView.addChild(src);
        src.y += 20 * i;
        showSpace[i] = src;
    }

    private function buildWingMc(_obj:GiftVo):MovieClip {
        var src:Object = _obj;
        var clip:MovieClip = VideoTool.getMovieLoader("giftModule.wingSkin",
                VideoConfig.HTTP + "Modules/skin/GiftEff.swf",
                onComplete);

        function makeHtmlText(word:String, color:String):String {
            return "<font color='" + color + "'>" + word + "</font>";
        }

        function onComplete(_mc:MovieClip):void {
            var loader:Loader = new Loader();
            loader.load(new URLRequest(VideoConfig.HTTP + "image/gift_material/" + src.id + ".png"));
            _mc.txtMc.recName.htmlText = makeHtmlText(src.sendName, "#0000FF") + makeHtmlText(" 赠送给 ", "#ff0000") + makeHtmlText(src.recName, "#0000FF");
            trace(_mc.txtMc.recName.htmlText);
            _mc.txtMc.numTxt.text = src.num + "个";
            _mc.loadMc.addChild(loader);
            _mc.HandMc.visible = false;
            _mc.wingMc.visible = false;
            if (src.num >= 500) {
                _mc.HandMc.visible = true;
                _mc.wingMc.visible = true;
            } else if (src.num < 500 && src.num >= 200) {
                _mc.wingMc.visible = true;
            }
            setTimeout(function ():void {
                if (clip.parent) {
                    clip.parent.removeChild(clip);
                }
            }, 4400);
        }

        return clip;
    }

    /**
     * 播放礼物动画逻辑
     * @param vo
     */
    public function quickShowEff(vo:GiftVo):void {

        //==============================
        var i:int;
        //逻辑1 swf 礼物 动态礼物
        //如果是swf动画排队显示
        if (vo.type == "swf") {
            if (vo.num > 50) {
                setTimeout(popSWF, 2000);
                function popSWF():void {
                    var clip:MovieClip = buildWingMc(vo);
                    PopupManager.instance.showPopup(clip, null, false);
                }
            }
            if (vo.playType == "multiline") {
                if (vo.num > 20) {
                    vo.num = 20;
                }
                new CTimeoutOper(100 * vo.num + 2000, doNewItNow).commit();
                function doNewItNow():void {
                    for (var j:int = 0; j < vo.num; j++) {
                        var _x1:Number = (RootManager.stage.stageWidth / 2 - 200) + Math.random() * 400;
                        var _y1:Number = (RootManager.stage.stageHeight / 2 - 200) + Math.random() * 400;
                        setTimeout(addGiftByPoint, 100 * j, vo, _x1, _y1, 1, 1);
                    }
                }
            } else {
                if (vo.time == 0) {
                    vo.time = 0.1;
                }
                new CTimeoutOper(vo.time * 1000, doItNow).commit();
                function doItNow():void {
                    var svo:GiftVo = vo;
                    addGiftByPoint(svo, svo.x, svo.y, svo.scaleX, svo.scaleY);
                }
            }
            return;
        }
        //逻辑2 png礼物静态礼物
        //如果包含动态数据优先显示动态数据里面的点
        var array:Array;// = ClientManger.getInstance().getEffDataByName(vo.num);
        array = getFixGiftArry(vo.num);
        if (array.length > 0) {
            //new
            var _lay:Sprite = GiftView.makeCloudGraphics(vo, array);
            showView.addChild(_lay);
        } else {
            if (vo.num > 240) {
                vo.num = 240;
            }
            array = [];
            for (i = 0; i < vo.num; i++) {
                var point:Point = getRandomPoint();
                var obj:Array = [];
                obj[0] = point.x;
                obj[1] = point.y;
                array.push(obj);
            }
            _lay = GiftView.makeCloudGraphics(vo, array, false);
            showView.addChild(_lay);
        }
    }

    public function get showView():DisplayObjectContainer {
        return ClientManger.getInstance().view["giftSpr"];
    }

    public function addGiftByPoint(vo:GiftVo, _x:Number = 0, _y:Number = 0, _scaleX:Number = 1, _scaleY:Number = 1, rotation:Number = 0):GiftView {
        var view:GiftView = new GiftView(vo, _x, _y);
        view.scaleX = _scaleX;
        view.scaleY = _scaleY;
        view.rotation = rotation;
        showView.addChild(view);
        return view;
    }

    private function getRandomPoint():Point {
        var point:Point = new Point();
        point.x = Math.random() * 600 + 400;
        point.y = Math.random() * 118 + 328;
        return point;
    }
}
}
