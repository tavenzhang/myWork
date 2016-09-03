/**
 * Created by Roger on 2014/11/24.
 */
package tool {
import com.greensock.events.LoaderEvent;
import com.greensock.loading.LoaderMax;
import com.greensock.loading.SWFLoader;
import com.greensock.loading.XMLLoader;
import com.hurlant.crypto.symmetric.AESKey;
import com.hurlant.crypto.symmetric.CBCMode;
import com.hurlant.crypto.symmetric.PKCS5;
import com.hurlant.util.Hex;
import com.rover022.IVideoRoom;
import com.rover022.event.CBModuleEvent;
import com.rover022.vo.VideoConfig;
import com.rover022.IVideoModule;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;
import flash.filters.GlowFilter;
import flash.net.SharedObject;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.text.TextField;
import flash.utils.ByteArray;
import flash.utils.getDefinitionByName;
import flash.utils.getTimer;

import manger.ClientManger;

import manger.DataCenterManger;

public class VideoTool {
    public static var videoRomm:IVideoRoom;
    private static var KEY:int = 413256489;

    public static function encrypt(plainText:int):int {
        return plainText ^ KEY;
    }

    public static function decrypt(cipherText:int):int {
        return cipherText ^ KEY;
    }

    public static function formatHeadURL(_id:*):String {
        var _str:String = VideoConfig.configXML.head.@url.toString();
        _str = _str.replace("{0}", _id);
        _str = _str;
        return _str;
    }

    public static function jumpToGuiZhuURL():void {
        if (ExternalInterface.available) {
            ExternalInterface.call("Fla.showNobleDialog", DataCenterManger.roomData.roomid);
        }
    }

    /**视频大厅*/
    public static function formatVideoHeadURL(_id:*, versin:String):String {
        var _str:String = VideoConfig.configXML.httpGetCover + VideoConfig.configXML.head.@videoUrl.toString();
        _str = _str.replace("{0}", _id);
        _str = _str.replace("{1}", versin);
        _str = _str;
        //trace(_str);
        return _str;
    }

    /**观众列表头像请求格式*/
    public static function getAudienceHeadImg():String {
        var _str:String = VideoConfig.httpTomcat + "/video_gs/info/get_headimg?uid={0}";
        return _str;
    }

    public static function getMovieClipInstance(className:String):MovieClip {
        var _class:Class = getDefinitionByName(className) as Class;
        var _mc:MovieClip = new _class() as MovieClip;
        checkIsIvideoRoom(_mc);
        return _mc;
    }

    public static function getSpriteInstance(className:String):Sprite {
        var _class:Class = getDefinitionByName(className) as Class;
        return new _class() as Sprite;
    }

    /**用于提取taven 模块 产生的类*/
    public static function getMCTaven(className:String, iscopy:Boolean = false):MovieClip {
        var mc:MovieClip;
        if (!VideoConfig.isBoundleRes) {
            var _newDomain:SWFLoader = LoaderMax.getLoader("tavenModule");
            mc = MovieClip(new (_newDomain.getClass("taven." + className) as Class));
        }
        else {
            mc = MovieClip(new (getDefinitionByName("taven." + className) as Class));
        }
        checkIsIvideoRoom(mc);
        return mc;
    }

    /**用于提取LoaderMax特定域的类*/
    public static function getClassByModule(className:String, moduelName:String):* {
        var _class:Class;
        if (!VideoConfig.isBoundleRes) {
            var _newDomain:SWFLoader = LoaderMax.getLoader(moduelName);
            _class = _newDomain.getClass(className);
        }
        else {
            _class = getDefinitionByName(className) as Class;
        }
        var _obj:* = new _class();
        checkIsIvideoRoom(_obj);
        return _obj;
    }

    private static function checkIsIvideoRoom(_obj:Object):void {
        if (_obj is IVideoModule) {
            (_obj as IVideoModule).videoRoom = videoRomm;
        }
    }

    public static function remove(_view:DisplayObjectContainer):void {
        if (_view.parent) {
            _view.parent.removeChild(_view);
        }
    }

    public static function jumpToMainURL(event:MouseEvent):void {
        navigateToURL(new URLRequest(VideoConfig.httpFunction));
    }

    public static function jumpToMailURL(event:MouseEvent):void {
        navigateToURL(new URLRequest(VideoConfig.httpFunction + "/mailverific"));
    }

    public static function loadAssRes(url:String, loadExpResComplete:Function, _name:String = ""):void {
        var loader:SWFLoader = new SWFLoader(VideoConfig.HTTP + url + "?version" + VideoConfig.VERSION, {
            name: "expModule",
            onComplete: function (e:LoaderEvent):void {
                loadExpResComplete.call(null);
            }
        });
        loader.load();
    }

    public static function loadXMLRes(_url:String, _name:String, callFunction:Function):void {
        var xmlLoader:XMLLoader = new XMLLoader(VideoConfig.httpTomcat + _url + "?uid=" + VideoConfig.roomID + "&psize=30" + "?version" + VideoConfig.VERSION, {
            name: _name, onComplete: onLoadComplete
        });

        function onLoadComplete(e:LoaderEvent):void {
            var _giftObj:Object = JSON.parse(xmlLoader.content);
            callFunction.call(null, _giftObj);
        }

        xmlLoader.load();
    }

    public static function getMovieLoader(className:String, s2:String, _onComplete:Function):MovieClip {
        var contion:MovieClip = new MovieClip();
        var swf:SWFLoader = LoaderMax.getLoader(s2);
        if (swf) {
            var _class:Class = swf.getClass(className);
            var mc:MovieClip = new _class();
            contion.addChild(mc);
            _onComplete.call(null, mc);
        } else {
            swf = new SWFLoader(s2, {
                onComplete: function ():void {
                    _class = swf.getClass(className);
                    mc = new _class();
                    contion.addChild(mc);
                    _onComplete.call(null, mc);
                }
            });
            swf.load();
        }
        return contion;
    }

    public static function convertDateStr(dateStr:String):String {
        var strArr:Array = dateStr.split(" ");
        var fStr:String = "{0} {1} {2}";
        return format(fStr, (strArr[0] as String).split("-").join("/"), strArr[1], "GMT");
    }

    /**以前的format文章中的方法*/
    public static function format(str:String, ...args):String {
        for (var i:int = 0; i < args.length; i++) {
            str = str.replace(new RegExp("\\{" + i + "\\}", "gm"), args[i]);
        }
        return str;
    }

    public static function areSameDay(dateStr:String, dateStrSoure:String):Boolean {
        var date1:Date = getDateByString(dateStr);
        var date2:Date = getDateByString(dateStrSoure);
        return areSameDayByDate(date1, date2);
    }

    public static function areSameDayByDate(date1:Date, date2:Date):Boolean {
        return date1.getMonth() == date2.getMonth() && date1.getFullYear() == date2.getFullYear() && date1.getDay() == date2.getDay();
    }

    public static function getDateByString(dateStr:String):Date {
        var date1:Date = new Date();
        date1.time = Date.parse(convertDateStr(dateStr));
        return date1;
    }

    public static function buildAseString(messKey:String, _plain:String, ivStr:String = "0102030405060708"):String {
        //var _aseKey:String = '1234567891111111';可以自己定义不同的
        //var plain:String = "test";
        var _aseKey:String = messKey;
        var plain:String = _plain;
        //var ivString:String = '0102030405060708'; //key
        var ivString:String = ivStr;
        var key:ByteArray = new ByteArray();
        key.writeUTFBytes(_aseKey);
        var iv:ByteArray = new ByteArray();
        iv.writeUTFBytes(ivString);
        var des:AESKey = new AESKey(key);//ase模式
        var cbc:CBCMode = new CBCMode(des, new PKCS5()); //加密模式                        ,有多种模式供你选择
        cbc.IV = iv; //设置加密的IV
        /* 得到的密文长度和明文的长度有关,规律大致是:明文<8 密文=12 ,明文<16 密文=24 ,明文>=16 密文=32......后面希望你们推一下*/
        var tmpByteArray:ByteArray = convertStringToByteArray(plain); //转换成二进制编码 (该函数自己定义)
        cbc.encrypt(tmpByteArray);
        var fin:String = com.hurlant.util.Base64.encodeByteArray(tmpByteArray);
//        trace("fin:", fin);
        return fin;
        //利用加密模式对数据进行加密
        trace("base64 =", com.hurlant.util.Base64.encodeByteArray(tmpByteArray));
        var as3Str:String = Hex.fromArray(tmpByteArray); //利用base64对密文进行编码
        trace("as3Str = " + as3Str);//输出结果 为: PXWVqYv/gJ04WpM5vlT9gg==
        //String转ByteArray函数
        function convertStringToByteArray(str:String):ByteArray {
            var bytes:ByteArray;
            if (str) {
                bytes = new ByteArray();
                bytes.writeUTFBytes(str);
            }
            return bytes;
        }
    }

    //aes解码
    public static function decodeAseString(messKey:String, _plain:String, ivStr:String):String {
        var _aseKey:String = messKey;
        var plain:String = _plain;
        //var ivString:String = '0102030405060708'; //key
        var ivString:String = ivStr;
        var key:ByteArray = new ByteArray();
        key.writeUTFBytes(_aseKey);
        var iv:ByteArray = new ByteArray();
        iv.writeUTFBytes(ivString);
        var des:AESKey = new AESKey(key);//ase模式
        var cbc:CBCMode = new CBCMode(des, new PKCS5()); //加密模式                        ,有多种模式供你选择
        cbc.IV = iv; //设置加密的IV
        var dataArr:ByteArray = com.hurlant.util.Base64.decodeToByteArray(_plain);
        cbc.decrypt(dataArr);
        dataArr.position = 0;
        var resutStr:String = dataArr.readMultiByte(dataArr.bytesAvailable, "utf-8");
        return resutStr;
    }

    public static function isOverTime():int {
        return getTimer() > 60 * 5 * 1000 ? 1 : 0;
    }

    public static function getShareObject(_name:String):Object {
        var so:SharedObject = SharedObject.getLocal(_name, "/");
        if (so.data) {
            return so.data.value;
        } else {
            return null;
        }
    }

    public static function saveShareObject(_signal:Object, _name:String):void {
        var so:SharedObject = SharedObject.getLocal(_name, "/");
        so.data.value = _signal;
        so.data.time = new Date();
        so.flush();
    }

    public static function buildButtonEff(btnDown:Sprite):void {
        btnDown.buttonMode = true;
        btnDown.mouseChildren = false;
        var txt:TextField = btnDown["labelTxt"];
        if (txt) {
            txt.mouseEnabled = false;
        }
        btnDown.addEventListener(MouseEvent.ROLL_OVER, onOverHandle);
        btnDown.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
        function onOverHandle(e:MouseEvent):void {
            var _filter:flash.filters.GlowFilter = new GlowFilter(0xffcc00, 1, 2, 2);
            btnDown.filters = [_filter]
        }

        function onRollOut(e:MouseEvent):void {
            btnDown.filters = [];
        }
    }

    public static function makeMovieClipToButton(btnChongzhi:Sprite):void {
        btnChongzhi.addEventListener(MouseEvent.ROLL_OVER, onMove);
        btnChongzhi.addEventListener(MouseEvent.ROLL_OUT, onOut);
        btnChongzhi.buttonMode = true;
        function onMove(e:MouseEvent):void {
            btnChongzhi.scaleX = btnChongzhi.scaleY = 0.95;
        }

        function onOut(e:MouseEvent):void {
            btnChongzhi.scaleX = btnChongzhi.scaleY = 1;
        }
    }

    public static  function sendUserLinkEvent(evt:CBModuleEvent):void
    {
        (ClientManger.getInstance().view as MovieClip).onChatLinkEvent(evt);
    }
}
}
