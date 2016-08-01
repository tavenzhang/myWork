/**
 * Created by roger on 2016/5/21.
 */
package tool {
import com.junkbyte.console.Cc;
import com.rover022.vo.VideoConfig;

import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.navigateToURL;

public class GoogleAdSence extends Sprite {
    public var url:String = "/indexinfo?_=";
    private var loader:URLLoader;
    private var type:int = 1;
    private var linkUrl:String;
    private var imageLoader:Loader;
    private var bgImage:Loader;
    public var showClip:DisplayObject;
    private var d_jsObje:Object;

    public function GoogleAdSence() {
        super();
        bgImage = new Loader();
        bgImage.load(new URLRequest(VideoConfig.HTTP + "image/video_bg.jpg"));
        addChild(bgImage);
        imageLoader = new Loader();
        imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoaded);
        imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onImageIOError);
        var sprite:Sprite = new Sprite();
        addChild(sprite);
        sprite.addChild(imageLoader);
        sprite.addEventListener(MouseEvent.CLICK, onImageClick);
        //
        buttonMode = true;
    }

    private function onImageIOError(event:IOErrorEvent):void {
        Cc.log("广告图片地址读取错误", d_jsObje.gg.video_ad.img);
    }

    private function onImageClick(event:MouseEvent):void {
        if (showClip && showClip.visible) {
            Cc.log("can not jump");
        } else {
            Cc.log("jump");
            navigateToURL(new URLRequest(linkUrl));
        }
    }

    private function onImageLoaded(event:Event):void {
        imageLoader.content.width = 480;
        imageLoader.content.height = 360;
    }

    public function loadAdData(src:String, _type:int):void {
        //
        type = _type;
        loader = new URLLoader();
        var webUrl = src + url + Math.random();
        Cc.log("webUrl=="+webUrl);
        loader.load(new URLRequest(webUrl));
        loader.addEventListener(Event.COMPLETE, onComplete);
        loader.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
        //
        //imageLoader.unload();
    }

    private function onIoError(event:IOErrorEvent):void {
        Cc.log("广告地址读取错误");
    }

    private function onComplete(event:Event):void {
        //d_jsObje.gg.video_ad = {};
//        var s:String = '{"ret":true,"info":{"uid":100003,"nickname":"test20","headimg":"http:\/\/10.1.100.194:4869\/60e62fbce46a2243ddde8c09597212af?w=180&h=180","points":616002287,"roled":3,"rid":100003,"vip":1105,"vip_end":"2016-06-17 12:40:35","lv_rich":28,"lv_exp":13,"safemail":"ronnie@wisdominfo.my","mails":2,"icon_id":0,"hidden":0},"myfav":[{"rid":100003,"lv_type":1,"lv_exp":13,"live_status":0,"total":0,"uid":100003,"tid":1,"username":"test20","headimg":"\/video_gs\/video\/img\/get_cover?uid=100003&v=1464234552961","live_time":"\u672a\u5f00\u64ad","attens":"6","new_user":0,"enterRoomlimit":0},{"rid":100011,"lv_type":1,"lv_exp":7,"live_status":0,"total":0,"uid":100011,"tid":1,"username":"qq321","headimg":"\/video_gs\/video\/img\/get_cover?uid=100011&v=1455612212497","live_time":"\u672a\u5f00\u64ad","attens":"2","new_user":0,"enterRoomlimit":1},{"rid":100010,"lv_type":1,"lv_exp":14,"live_status":0,"total":2,"uid":100010,"tid":1,"username":"qq122","headimg":"","live_time":"\u672a\u5f00\u64ad","attens":"3","new_user":0,"enterRoomlimit":0},{"rid":100002,"lv_type":1,"lv_exp":19,"live_status":1,"total":2,"uid":100002,"tid":1,"username":"test10","headimg":"\/video_gs\/video\/img\/get_cover?uid=100002&v=1464234674352","live_time":"43\u5206\u949f4\u79d2","attens":"3","new_user":0,"enterRoomlimit":0}],"myres":[],"img_url":"http:\/\/10.1.100.194:4869","js_url":"http:\/\/v.r.com","room_url":"\/video_gs\/room\/","downloadUrl":"\/download\/1room_newaddress.zip","gg":{"login_ad":{"title":"\u4f60\u59b9\u7684","link":"http:\/\/www.r.com\/click?id=MzE=&tp=a&url=http://www.baidu.com","img":"http:\/\/p1.1room1.co\/public\/images\/staticad\/20160531172533_574d588dcedca.jpg"}}}'
        Cc.log("loader.data=="+loader.data);
//        d_jsObje = JSON.parse(loader.data);
//        //
//        if (d_jsObje.gg.video_ad != null) {
//            linkUrl = d_jsObje.gg.video_ad.link;
//            var image_url:String = d_jsObje.gg.video_ad.img;
//            imageLoader.load(new URLRequest(image_url));
//            //imageLoader.visible = true;
//        } else {
//            Cc.log("无广告数据;", loader.data);
//            //imageLoader.visible = false;
//        }
    }
}
}
