package video {
import com.bit101.components.ComboBox;
import com.bit101.components.Label;
import com.bit101.components.Style;
import com.greensock.TweenLite;
import com.rover022.CBProtocol;
import com.rover022.ModuleNameType;
import com.rover022.tool.NetPing;
import com.rover022.tool.PingManager;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.media.Camera;
import flash.media.Microphone;
import flash.text.TextFormat;
import flash.utils.setTimeout;

import manger.UserVoDataManger;

import sk.video.videoParam;

import taven.sideGroup.BasePaneUI;
import taven.utils.CCComboBox;

public class VideoParamView extends BasePaneUI {
    private var operaBool:Boolean = false;
    public var videoBox:ComboBox;
    public var soundBox:ComboBox;
    public var lineBox:ComboBox;
    public var videoPlayerView:VideoPlayerView;
    private var _lastChooseRtmp:String = "";
    public var _pane:videoParam = new videoParam();

    public function VideoParamView(_v:VideoPlayerView):void {
        addChild(_pane);
        videoPlayerView = _v;
        _pane.yes_bt.addEventListener(MouseEvent.CLICK, suerClick);
        Style.embedFonts = false;
        Style.fontSize = 12;
        Style.fontName = "宋体";
        Style.setStyle(Style.DARK);
        makeLabel("摄像头:", 50, 64);
        makeLabel("麦克风:", 50, 97);
        videoBox = new ComboBox(this, 105, 64);
        videoBox.setSize(200, 20);
        soundBox = new ComboBox(this, 105, 97);
        soundBox.setSize(200, 20);
        //
        makeLabel("线路:", 50, 132);
        lineBox = new ComboBox(this, 105, 132);
        lineBox.setSize(200, 20);
        for (var i:int = 0; i < 50; i++) {
            lineBox.addItem({label: "测试"});
        }
        super();
    }

    override protected function init():void {
        var i:int = 0;
        for (i = 0; i < Camera.names.length; i++) {
            this.videoBox.addItem({label: Camera.names[i], data: i});
        }
        for (i = 0; i < Microphone.names.length; i++) {
            this.soundBox.addItem({label: Microphone.names[i], data: i});
        }
        videoBox.selectedIndex = 0;
        soundBox.selectedIndex = 0;
        var _arr:PingManager = UserVoDataManger.adminPingManger;
        _arr.addEventListener(PingManager.ITEM_TESTOK, testSeedFinish);
        lineBox.items = _arr.rtmpSortlist;
        lineBox.selectedIndex = 0;
        lineBox.draw();
        _pane.btnTestSpeed.addEventListener(MouseEvent.CLICK, onTestSpeddClick);
    }

    private function makeLabel(s:String, i:int, i2:int):Label {
        var label:Label = new Label(this, i, i2, s);
        label.textField.defaultTextFormat = new TextFormat("宋体", 12, 0xffffff);
        return label;
    }

    public function onTestSpeddClick(evt:Event):void {
        var _arr:PingManager = UserVoDataManger.adminPingManger;
        _arr.startTestSped();
        _pane.btnTestSpeed.visible = false; //只是2秒间隔 点击测速按钮 以免过于频繁
        setTimeout(function ():void {
            _pane.btnTestSpeed.visible = true;
        }, 2000)
    }

    public function testSeedFinish(evt:Event):void {

        trace("testSeedFinish");
        var mage:PingManager = UserVoDataManger.adminPingManger;
        var _select:int = 0;
        for (var i:int = 0; i < mage.rtmpSortlist.length; i++) {
            var object:NetPing = mage.rtmpSortlist[i];
            if (object.rtmp == _lastChooseRtmp) {
                _select = i;
                break;
            }
        }
        lineBox.draw();
        lineBox.selectedIndex = _select;
    }

    /**
     * 点击确认线路后的动作;
     * @param e
     */
    public function suerClick(e:MouseEvent):void {
        _lastChooseRtmp = "";
        if (!lineBox.selectedItem)
            return;
        //
        if (videoPlayerView.isGetMic) {
            videoPlayerView.downMicClick(null);
        }
        //
        operaBool = true;
        videoPlayerView.initUI();
        _lastChooseRtmp = lineBox.selectedItem.rtmp;
        //Cc.log("主播手动选择的线路是:", _lastChooseRtmp);
        videoPlayerView.videoRoom.sendDataObject({"cmd": CBProtocol.startTalkPlay, "rtmp": _lastChooseRtmp});//上麦
        videoPlayerView.onGetMic(null);
        videoPlayerView.reconCount = 0;
        videoPlayerView.isCloseRestConnectRtmp = false;
        //
        closeClick(null);
    }

    public function get cameraValue():int {
        var _v:int = -1;
        if (this.operaBool) {
            _v = this.videoBox.selectedIndex;
        }
        return _v;
    }

    public function get microphoneValue():int {
        var _v:int = -1;
        if (this.operaBool) {
            _v = this.soundBox.selectedIndex;
        }
        return _v;
    }
}
}