/**
 * Created by zhangxinhua on 16/8/18.
 */
package manger {
import com.rover022.vo.VideoConfig;

import flash.external.ExternalInterface;

import flash.net.URLRequest;
import flash.net.navigateToURL;

import tool.VideoTool;

public class NavigatorManager {
//    跳转到首页
    public static function  gotoIndex()
    {
        navigateToURL(new URLRequest(VideoConfig.httpFunction),"_self");
    }

 //   跳转到下载页面
    public static function  gotoDownloadUrl()
    {
        navigateToURL(new URLRequest(UserVoDataManger.userData.downloadUrl))
    }

    // 跳转排行榜
    public static function  gotoRank()
    {
        //navigateToURL(new URLRequest(VideoConfig.httpFunction+"/ranking"), "_blank");
        navigateToURL(new URLRequest(VideoConfig.httpFunction+"/ranking"));
    }

    //调整到商城
    public static function  gotoShop()
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
