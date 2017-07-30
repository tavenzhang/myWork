/**
 * Created by Roger on 2014/11/24.
 */
package com.rover022.vo {
import flash.external.ExternalInterface;
import flash.system.Security;

import ghostcat.manager.RootManager;

public class VideoConfig {
	public static var resAdd:String          = "";
	public static var configXML:XML;
	public static var isBoundleRes:Boolean   = false;  //1 多个文件。 是否将启用 启动资源绑定模式，所有开始资源绑定1个swf
	public static var WIDTH:Number           = 1500;
	public static var HEIGHT:Number          = 700;
	public static var P2P_OPEN:Boolean       = false;
	public static var ENV_XML:XML            = null;
	public static var HTTP:String            = "";
	public static var HOST:String            = "138.68.15.251";
	public static var PORT:int               = 20070;
	public static var connectRTMP:String; //] 115.231.24.252: 连接成功------9007------------------costTime====781
	public static var roomID:int             = 1000000;//rover022 101116443,101116441,101120981,101116395,101116444,101116395
	public static var loginKey:String        = "";

    public static var testUID:String         = "2@163.com";
	public static var testPASS:String        = "aaaaaa";
//	public static var testUID:String         = "thomas1@qq.com";
//	public static var testPASS:String        = "aaaaaa";
	//版本控制
	public static var VERSION:String         = "10.24";
	//编译发布时间
	public static var BUILDTIME:String       = "7月26日10:00";
	public static var giftConfig:XML;
	public static var isShowGameHelp:Boolean = true;



    //网页参数
    public static var netTomcat:String = "";
    public static var nethttpRes:String = "";
    public static var nethttpFunction:String = "";
	public static function get httpTomcat():String {
		if (ExternalInterface.available) {
			return netTomcat;
		} else {
			return configXML.httpTomcat;
		}
	}

	public static function get httpRes():String {
		if (ExternalInterface.available) {
			return nethttpRes
		} else {
			return configXML.httpRes;
		}
	}


	public static function get httpFunction():String {
		if (ExternalInterface.available) {
			return nethttpFunction;
		} else {
			return configXML.httpFunction;
		}
	}


	public static function getRslModulePath(modlueName:String):String {
		return HTTP + "Modules/rslModules/" + modlueName + ".swf";
	}

	public static function getSKinPath(modlueName:String):String {
		return HTTP + "Modules/skin/" + modlueName + ".swf";
	}

	public static function get isValidRtmp():Boolean {
		var result:Boolean = false;
		if (configXML && configXML.isVideoValid == "1") {
			result = true;
		}
		return result;
	}

	public static function get isValidRtmpUp():Boolean {
		var result:Boolean = false;
		if (configXML && configXML.isVideoValidUp == "1") {
			result = true;
		}
		return result;
	}


		public static function get isShowQuality():Boolean {
		var result:Boolean = false;
		if (configXML && configXML.isShowQuality == "1") {
			result = true;
		}
		return result;
	}

	public static function get speedPort():String {
		var port:String = "";
		if (configXML && configXML.httpSpeed !="") {
			port = configXML.httpSpeed  ;
		}
		return port;
	}


}
}
