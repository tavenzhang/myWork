/**
 * Created by Roger on 2014/11/24.
 */
package com.kingjoy.view {
import com.greensock.events.LoaderEvent;
import com.greensock.loading.LoaderMax;
import com.greensock.loading.SWFLoader;
import com.greensock.loading.XMLLoader;
import com.junkbyte.console.Cc;
import com.rover022.display.UserIconMovieClip;
import com.rover022.tool.SocketPingManager;
import com.rover022.vo.VideoConfig;

import display.ui.Alert;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.external.ExternalInterface;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;

import ghostcat.manager.RootManager;

import manger.ClientManger;

import tool.VideoTool;

/**
 * 适合用于资源加载的容器
 * 这类容器一般会先加载一些资源类然后在初始化
 *
 * 功能1 加载配置
 * 功能2 加载资源
 */
public class BaseResRoom extends MovieClip {
    public var tavenContext:LoaderContext;
    //UI
    public var stageSpr:Sprite;
    public var alertVE:Sprite;
    //*loading
    private var _loaderMax:LoaderMax;
    //socket检测 是否已经完成
    private var _isTestingSocket:Boolean = false;

    public function BaseResRoom() {
        tavenContext = new LoaderContext(false, new ApplicationDomain(ApplicationDomain.currentDomain));
    }

    //所有的js函数注册都在这里
    public function regAS_JsFuntion():void {
        //刷新页面时由 js调用关闭rtmp 链接
        ExternalInterface.addCallback("closeRtmp", closeRtmpHandle);
        //开通vip贵族是 由js调用
        ExternalInterface.addCallback("openVipSuccess", function (src:* = null):void {
            ClientManger.getInstance().openVipNotice(src);
        });
    }

    /**
     * 获取页面参数
     */
    public function getParameters():void {
        VideoConfig.VERSION = "v1_0";
        var testStr:String ="6lOh20Km7QI4PuX8oh8UuyYKpVBA5zRdSzk4VZZYT2XWaLkL2z4XYpcVRmUFciWF+n58cIb9VqghFnVwXAYn3w==";
        var sss:String = VideoTool.decodeAseString("hg%43*&^56ig$g38",testStr);
        trace("sssss="+sss);
        var param:Object = this.stage.loaderInfo.parameters;
        if (param) {
            if (param["v"] != null) {
                VideoConfig.VERSION = param["v"];
            }
            if (param["rid"] != null) {
                VideoConfig.roomID = param["rid"];
            }
            if (param["http"] != null) {
                VideoConfig.HTTP = param["http"];
                UserIconMovieClip.AROOT = VideoConfig.HTTP;
            }
            if (param["httpTomcat"] != null) {
                VideoConfig.netTomcat = param["httpTomcat"];
            }
            if (param["httpFunction"] != null) {
                VideoConfig.nethttpFunction = param["httpFunction"];
            }
            if (param["httpRes"] != null) {
                VideoConfig.nethttpRes = param["httpRes"];
            }
            if (ExternalInterface.available) {
                regAS_JsFuntion();
                var crptyStr:String = ExternalInterface.call("getRoomKey");
                var keyStr:String = VideoTool.decodeAseString(VideoTool.KEY2,crptyStr);
                var data:Array = keyStr.split("|");
                var consoleKey:String = data[1];
                consoleKey  = consoleKey==(null || "") ? "7777888":consoleKey;
                Cc.startOnStage(RootManager.stage,consoleKey); // "`" - change for password. This will start hidden
                var socketList:Array = (data[0] as String).split(",");
                _isTestingSocket = true;
                onSocketListResult(socketList);
            }

            this.loadConfigData();//加载配置
        }
    }

    //返回ip列表并进行测速
    private function onSocketListResult(ipList:Array):void {
        //  trace("start encode============"+VideoTool.buildAseString(HttpService.AES_KEY,HttpService.sockt_SERVICE,HttpService.AES_IV))
        //   var result:String = VideoTool.decodeAseString(TavenHttpService.AES_KEY, data, TavenHttpService.AES_IV);
        Cc.log("onSocketListResult-----==" + ipList);
        if (ipList == null || ipList.length == 0) {
            Cc.log("onSocketList error ");
            return;
        }
        var socketPingManager:SocketPingManager = new SocketPingManager();
        socketPingManager.addEventListener(SocketPingManager.PING_SUCCESS, function (evt:Event):void {
                    VideoConfig.HOST = socketPingManager.bestHost.split(":")[0];
                    VideoConfig.PORT = socketPingManager.bestHost.split(":")[1];
                    Cc.log("最优 socket地址:", VideoConfig.HOST, VideoConfig.PORT);
                    _isTestingSocket = false;
                    readyConnectSocket();
                }
        );
        socketPingManager.testSocktList(ipList);
    }

    public function closeRtmpHandle():void {
    }

    /**
     * 加载配置资源
     */
    public function loadConfigData():void {
        LoadUI.setLoadInfo("加载视频配置...", 30);
        //
        var queue:LoaderMax = new LoaderMax({
            auditSize: false,
            onComplete: completeHandler
        });
        queue.append(new XMLLoader(VideoConfig.HTTP + "xml/env.xml?time=" + Math.random(), {name: "envXML"}));
        queue.append(new XMLLoader(VideoConfig.HTTP + "xml/videoConfig.xml?time=" + Math.random(), {name: "configXML"}));
        queue.load();
        function completeHandler(e:Event = null):void {
            //处理配置与模块
            VideoConfig.configXML = LoaderMax.getContent("configXML");
            //把env 的变量 读入VideoConfig  进行适配 ===========================================================
            var envXML:XML = LoaderMax.getContent("envXML") as XML;
            VideoConfig.ENV_XML = envXML;
            var valueStr:String = VideoConfig.configXML.httpGetCover;
            VideoConfig.configXML.httpGetCover = valueStr.replace("{0}", envXML.httpGetCover);
            valueStr = VideoConfig.configXML.head.@url;
            VideoConfig.configXML.head.@url = valueStr.replace("{1}", envXML.head.@url);
            //是否开启p2p
            VideoConfig.P2P_OPEN = ( VideoConfig.ENV_XML && VideoConfig.ENV_XML.p2pRtmp == "1");
            //把env 的变量 读入VideoConfig  进行适配 ====================================================================
            VideoConfig.resAdd = VideoConfig.httpRes + VideoConfig.configXML.head.@giconurl.toString();
            //Alert
            var _alert:MovieClip = VideoTool.getMovieClipInstance("display.ui.Alert");
            _alert.txt.selectable = true;
            RootManager.stage.addChild(_alert);
            startAssetLoad();//继续loading//加载素材的同时
            if (!_isTestingSocket) //如果不是正在测试socket 说明host 已经准备好
            {
                readyConnectSocket();// 加载素材的同时已经开始连接socket;
            }
        }
    }

    public function readyConnectSocket():void {
        if (VideoConfig.HOST != "") {//新模式
            VideoConfig.configXML.socket.@url = VideoConfig.HOST;
            VideoConfig.configXML.socket.@port = VideoConfig.PORT;
            Cc.log("新模式从页面获取socket地址");
        } else {
            VideoConfig.HOST = VideoConfig.configXML.socket.@url;
            VideoConfig.PORT = VideoConfig.configXML.socket.@port;
            Cc.log("老模式从xml获取socket地址");
        }
        Cc.log("连接服务器", VideoConfig.HOST, VideoConfig.PORT);
        connectService();
    }

    public var count:int = 0;

    public function onChildComplete(e:Event):void {
        count++;
        var _num:int = 30 + int(count / _loaderMax.getChildren().length * 69);
        LoadUI.setLoadInfo("加载视频资源...", _num);
    }

    public function onCompelet(e:Event):void {
        if (count == _loaderMax.getChildren().length) {
            VideoConfig.giftConfig = LoaderMax.getContent("giftConfig");
            initApp();
        }
    }

    private function initApp():void {
        initModules();
    }

    /**
     * 加载素材资源
     */
    public function startAssetLoad():void {
        LoadUI.setLoadInfo("加载视频资源...", 32);
        _loaderMax = new LoaderMax({auditSize: false});
        _loaderMax.maxConnections = 1;
        _loaderMax.skipFailed = false;
        _loaderMax.addEventListener(LoaderEvent.CHILD_COMPLETE, onChildComplete);
        _loaderMax.addEventListener(LoaderEvent.COMPLETE, onCompelet);
        _loaderMax.addEventListener(LoaderEvent.CHILD_FAIL, onFail);
        //VideoConfig.HTTP = 'http://s.the1room.net/flash/';
        //公共模块
        _loaderMax.append(new SWFLoader(VideoConfig.HTTP + "Modules/shareElement.swf" + "?version=" + VideoConfig.VERSION, {name: "shareModule"}));
        //roger 模块
        _loaderMax.append(new SWFLoader(VideoConfig.HTTP + "Modules/GiftModule.swf" + "?version=" + VideoConfig.VERSION, {name: "giftModule"}));
        _loaderMax.append(new SWFLoader(VideoConfig.HTTP + "Modules/ChatRoomModule.swf" + "?version=" + VideoConfig.VERSION, {name: "chat2Module"}));
        //taven 模块
        _loaderMax.append(new SWFLoader(VideoConfig.HTTP + "Modules/TavenModule.swf" + "?version=" + VideoConfig.VERSION, {
            name: "tavenModule",
            context: tavenContext
        }));
        _loaderMax.append(new SWFLoader(VideoConfig.HTTP + "Modules/VideoModule.swf" + "?version=" + VideoConfig.VERSION, {
            name: "videoModule",
            context: tavenContext
        }));
        _loaderMax.append(new XMLLoader(VideoConfig.HTTP + "xml/giftConfig.xml" + "?version=" + VideoConfig.VERSION, {name: "giftConfig"}));
       // _loaderMax.append(new XMLLoader(VideoConfig.HTTP + "xml/ActiveInfo.xml" + "?version=" + VideoConfig.VERSION, {name: "ActiveInfo"}));
        _loaderMax.load();
    }

    private function onFail(event:LoaderEvent):void {
        Alert.Show("文件加载错误,请刷新页面重试...", "文件加载错误");

    }

    public function initModules():void {
    }

    public function resetModule():void {
    }

    public function connectService():void {
    }
}
}
