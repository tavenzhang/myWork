package video {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.JPEGEncoderOptions;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.media.Video;
import flash.utils.ByteArray;

import ghostcat.fileformat.jpg.JPGEncoder;

import sk.ideo.videoShot;

public class VideoShotView extends videoShot {

    public var video_mc:Video = new Video(480, 360);//视频控件
    public var headJepgData:ByteArray;
    private var shotVideo_mc:Sprite;

    private var bitmap:Bitmap;

    public function VideoShotView():void {
        this.bitmap = new Bitmap(null);
        this.bitmap.x = 295;
        this.bitmap.y = 45;
        this.addChild(this.bitmap);

        this.shotVideo_mc = new Sprite;
        this.shotVideo_mc.x = 15;
        this.shotVideo_mc.y = 15;
        this.shotVideo_mc.addChild(this.video_mc);
        this.addChildAt(this.shotVideo_mc, 2);
        this.shotVideo_mc.width = 350;
        this.shotVideo_mc.height = 260;

        this.photo_bt.addEventListener(MouseEvent.CLICK, _photoClickEvent);
        this.rephoto_bt.addEventListener(MouseEvent.CLICK, _photoClickEvent);
        this.updata_bt.addEventListener(MouseEvent.CLICK, _photoUPDataClickEvent);
        this.cancel_bt.addEventListener(MouseEvent.CLICK, _photoCancelClickEvent);
    }

    private function _photoClickEvent(e:MouseEvent):void {
        this.photo_bt.visible = false;
        this.rephoto_bt.visible = true;
        this.bitmap.scaleX = this.bitmap.scaleY = 1;
        if (!this.bitmap.bitmapData) {
            this.bitmap.bitmapData = new BitmapData(480, 360, false, 0xFFFFFF);
        }
        this.bitmap.bitmapData.draw(this.shotVideo_mc);
        this.bitmap.width = 170;
        this.bitmap.height = 130;
    }

    public function rePhoto():void {
        this.photo_bt.visible = true;
        this.rephoto_bt.visible = false;
        if (this.bitmap.bitmapData) {
            this.bitmap.bitmapData.dispose();
            this.bitmap.bitmapData = null;
        }
        this.headJepgData = null;
    }

    public function _photoUPDataClickEvent(e:MouseEvent):void {
        if (this.bitmap.bitmapData) {
            try {
                this.headJepgData = this.bitmap.bitmapData.encode(this.bitmap.bitmapData.rect, new JPEGEncoderOptions(80));
            } catch (e:*) {
            }
            if (!headJepgData) {
                try {
                    var JPG:JPGEncoder = new JPGEncoder(100);
                    this.headJepgData = JPG.encode(this.bitmap.bitmapData);
                } catch (e:*) {
                }
            }
        }
        this.dispatchEvent(new Event("shotCompleteEvent"));
    }

    private function _photoCancelClickEvent(e:MouseEvent):void {
        this.rePhoto();
        this.dispatchEvent(new Event("shotCompleteEvent"));
    }
}
}