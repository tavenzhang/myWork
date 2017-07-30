/**
 * Created by zhangxinhua on 16/8/18.
 */
package manger {
import com.rover022.vo.VideoConfig;

import flash.external.ExternalInterface;

import flash.net.URLRequest;
import flash.net.navigateToURL;

import tool.VideoTool;

public class HttpLinkManger{


//    通用跳转页面,打开其他页面
  public static function  gotoCommonLinkOther(linkUrl:String):void
 {
    navigateToURL(new URLRequest(linkUrl),"_blank");
 }

    //    通用跳转页面,打开其他页面
    public static function  gotoCommonLinkSelf(linkUrl:String):void
    {
        navigateToURL(new URLRequest(linkUrl),"_self");
    }

//    跳转到首页
    public static function  gotoIndex():void
    {
        navigateToURL(new URLRequest(VideoConfig.httpFunction),"_self");
    }

 //   跳转到下载页面
    public static function  gotoDownloadUrl():void
    {
        navigateToURL(new URLRequest(DataCenterManger.userData.downloadUrl))
    }

    // 跳转排行榜
    public static function  gotoRank():void
    {
        //navigateToURL(new URLRequest(VideoConfig.httpFunction+"/ranking"), "_blank");
        navigateToURL(new URLRequest(VideoConfig.httpFunction+"/ranking"));
    }

    //调整到商城
    public static function  gotoShop():void
    {
        //navigateToURL(new URLRequest(VideoConfig.httpFunction+"/ranking"), "_blank");
        navigateToURL(new URLRequest(VideoConfig.httpFunction+"/shop"));
    }

    /**
     * 游客注册
     */
    public static function guestRegister():void {
        try {
            if (ExternalInterface.available) {
                var funcName:String = VideoConfig.configXML.js.@reg;
                var timeOver:int    = VideoTool.isOverTime();
                ExternalInterface.call(funcName, timeOver);
            }
        } catch (e:*) {
        }
    }

}


}
