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
	public static var HOST:String            = "116.31.99.233";
	public static var PORT:int               = 9001;
	public static var connectRTMP:String;
	public static var roomID:int             = 2057120;//rover022 101116443,101116441,101120981,101116395,101116444,101116395
	public static var loginKey:String        = "m5oqjfkc4iieoiaotdhcendjr0";
	public static var testUID:String         = "zxhua@163.com";
	public static var testPASS:String        = "shallay";
	//版本控制
	public static var VERSION:String         = "1.0.28";
	//编译发布时间
	public static var BUILDTIME:String       = "7月26日10:00";
	public static var giftConfig:XML;
	public static var isShowGameHelp:Boolean = true;
	//是否显示游戏帮助
	public static function get httpStaticPic():String {
		return configXML.httpGetCover;
	}

	public static function get httpTomcat():String {
		if (ExternalInterface.available) {
			return RootManager.getValue("httpTomcat")
		} else {
			return configXML.httpTomcat;
		}
	}

	public static function get localHttpAddress():String {
		if (HTTP.length > 1) {
//            var index:int = HTTP.indexOf("/flash");
			return HTTP.substr(0, HTTP.length - 6);
		} else {
			return "";
		}
	}

	public static function get httpRes():String {
		if (ExternalInterface.available) {
			return RootManager.getValue("httpRes")
		} else {
			return configXML.httpRes;
		}
	}

	public static function get httpFunction():String {
		if (ExternalInterface.available) {
			return RootManager.getValue("httpFunction");
		} else {
			return configXML.httpFunction;
		}
	}

	public function VideoConfig() {
	}

	public static function getRslModulePath(modlueName:String):String {
		return HTTP + "Modules/rslModules/" + modlueName + ".swf";
	}

	public static function get isValidRtmp():Boolean {
		var result:Boolean = false;
		if (configXML && configXML.isVideoValid == "1") {
			result = true;
		}
		return result;
	}
}
}
