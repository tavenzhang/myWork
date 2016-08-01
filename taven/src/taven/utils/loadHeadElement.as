/**
 * Created by ws on 2015/6/18.
 */
package taven.utils {
import even.loadMaterialMc;

import flash.display.Bitmap;
import flash.display.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;
import flash.system.LoaderContext;

public class loadHeadElement extends loadMaterialMc {
    //public var logo_mc:MovieClip;
    //public var loading_mc:MovieClip;
    //public var mask_mc:MovieClip;
    private var _loader:Loader = null;
    private var _loaderContext:LoaderContext = new LoaderContext(true);
    private var _url:String = "";//判断图片加载路径是否一致
    public function loadHeadElement():void {
        this.logo_mc.visible = false;
        this.loading_mc.visible = false;
        this.loading_mc.stop();
        this._loader = new Loader;
        this._loader.x = this.mask_mc.x;
        this._loader.y = this.mask_mc.y;
        this._loader.mask = this.mask_mc;
        this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE, _onCompleteEvent);
        this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _onErrorEvent);
        this.addChildAt(this._loader, this.getChildIndex(this.mask_mc));
        this._loader.visible = false;
    }

    public function loadHead(_url:String, _bool:Boolean = false):void {
        if (this._url != _url || _bool) {//bool:强制更新
            this._loader.visible = false;
            this.logo_mc.visible = false;
            this.loading_mc.play();
            this.loading_mc.visible = true;
            try {
                this._loader.unloadAndStop();
                this._loader.unload();
            } catch (e:*) {
            }
            this._loader.load(new URLRequest(_url), this._loaderContext);
            this._url = _url;
        }
    }

    //------------------------load;
    private function _onCompleteEvent(e:Event):void {
        try {
            var bitmap:Bitmap = Bitmap(e.target.content);
            if (bitmap) {
                bitmap.smoothing = true;
                bitmap.width = this.mask_mc.width;
                bitmap.height = this.mask_mc.height;
            }
        } catch (e:*) {
        }
        this.logo_mc.visible = false;
        this.loading_mc.visible = false;
        this.loading_mc.stop();
        this._loader.visible = true;
    }

    private function _onErrorEvent(e:IOErrorEvent = null):void {
        this.loading_mc.stop();
        this.loading_mc.visible = false;
        this.logo_mc.visible = true;
        this._loader.visible = false;
    }
}
}