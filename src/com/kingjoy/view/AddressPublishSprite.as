/**
 * Created by Administrator on 2015/6/18.
 */
package com.kingjoy.view {
import com.rover022.vo.VideoConfig;

import flash.display.Loader;
import flash.display.MovieClip;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;

import ghostcat.manager.RootManager;

import manger.DataCenterManger;

/**
 * 地址
 */
public class AddressPublishSprite extends MovieClip {
    public function AddressPublishSprite() {
        super();
        var loader:Loader = new Loader();
        loader.load(new URLRequest(VideoConfig.HTTP + "image/other/address.jpg"));
        loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOErrorHandle);
        addChild(loader);
        addEventListener(MouseEvent.CLICK, onClickHandler);
        buttonMode = true;
        x = -8;
        y = 70;
    }

    private function onIOErrorHandle(event:IOErrorEvent):void {
    }

    private function onClickHandler(event:MouseEvent):void {

       // navigateToURL(new URLRequest(VideoConfig.httpFunction+VideoConfig.configXML.addressPublisher))
       // 现在改成 支持后台读取
        navigateToURL(new URLRequest(DataCenterManger.userData.downloadUrl))
    }
}
}
