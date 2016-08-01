package net {
import com.junkbyte.console.Cc;
import com.rover022.vo.VideoConfig;

import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;

public class TavenHttpService {
    private var _requetUrl:String;
    private var _callBack:Function;
    public static const AES_IV_URL:String = "0502030806040501";//HTTP_AES密匙偏移量
    public static const AES_KEY_URL:String = "2593743757275918";//HTTP_AES秘钥
    public static const AES_IV:String = "0201070308020504";//AES密匙偏移量
    public static const AES_KEY:String = "1547862587402563";//AES秘钥
    public static var sockt_SERVICE:String = "http://10.1.100.104:1388/trafficop?cmd=1001&appid=61201&cbussid=1";//socket 服务器请求列表
    //如果需要修改房间 修改 cbussid 为对应的id 就行
    public static var rtmp_SERVICE_U:String = "http://10.1.100.104:1388/trafficop?cmd=1001&appid=61101&cbussid=" + VideoConfig.roomID;//rtmp 上播 服务器请求列表
    public static var rtmp_SERVICE_D:String = "http://10.1.100.104:1388/trafficop?cmd=1002&appid=61101&cbussid=" + VideoConfig.roomID + "&ubussid=-1";//rtmp 下播服务器请求列表
    //public static var RTMP_LIST:Array;
    //请求服务端
    public function reuqestServer(reuestUrl:String = "", callFun:Function = null, urlVars:URLVariables = null):void {
        Cc.log("reuqestServer-----" + reuestUrl);
        _requetUrl = reuestUrl;
        _callBack  = callFun;
        //创建URLLoader对象
        var urlLoader:URLLoader = new URLLoader();
        //设置接收数据方式(文本、原始二进制数据、URL 编码变量);
        urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
        //设置传递参数
        //var urlVars:URLVariables=new URLVariables();
        //urlVars.name="go 去服务端";
        //建立Request访问对象
        var urlRequest:URLRequest = new URLRequest(_requetUrl);
        //设置参数
        //urlRequest.data=urlVars;
        if (urlVars) {
            //设置访问模式(POST,GET) 默认是get
            urlRequest.method = URLRequestMethod.POST;
            urlRequest.data   = urlVars;
        }
        try {
            urlLoader.load(urlRequest);
            Cc.log("HttpService send =" + _requetUrl);
        }
        catch (error:Error) {
            trace(error)
        }
        //加载完成
        urlLoader.addEventListener(Event.COMPLETE, urlLoaderCompleteHandler);
        //开始访问
        urlLoader.addEventListener(Event.OPEN, urlLoaderOpenHandler);
        //加载进度
        urlLoader.addEventListener(ProgressEvent.PROGRESS, urlLoaderProgressHandler);
        //跨域访问安全策略
        urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, urlLoaderSecurityErrorHandler);
        //Http状态事件
        urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, urlLoaderHttpStatusHandler);
        //访问出错事件
        urlLoader.addEventListener(IOErrorEvent.IO_ERROR, urlLoaderIoErrorHandler);
    }

    private function urlLoaderCompleteHandler(e:Event):void {
        Cc.log("HttpService recieve = " + e.target.data);
        if (_callBack != null) {
            _callBack(e.target.data);
            _callBack = null;
        }
    }

    private function urlLoaderOpenHandler(e:Event):void {
        //trace("连接已经打开");
    }

    private function urlLoaderProgressHandler(e:ProgressEvent):void {
        var num:uint = (e.bytesLoaded / e.bytesTotal) * 100;
        //trace(" percent ="+num + "%");
    }

    private function urlLoaderSecurityErrorHandler(e:SecurityErrorEvent):void {
        trace(e);
        _callBack = null;
    }

    private function urlLoaderHttpStatusHandler(e:HTTPStatusEvent):void {
        trace(e);
    }

    private function urlLoaderIoErrorHandler(e:IOErrorEvent):void {
        trace(e);
    }

    public static function addHttpService(reuestUrl:String = "", callFun:Function = null, urlVars:URLVariables = null):TavenHttpService {
        var httpt:TavenHttpService = new TavenHttpService();
        httpt.reuqestServer(reuestUrl, callFun, urlVars);
        return httpt;
    }
}
}
