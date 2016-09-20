package video {
import com.bit101.components.CheckBox;
import com.bit101.components.ComboBox;
import com.bit101.components.Label;
import com.bit101.components.RadioButton;
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

import manger.DataCenterManger;

import sk.video.videoParam;

import taven.sideGroup.BasePaneUI;


public class VideoParamView extends BasePaneUI {
    private var operaBool:Boolean = false;
    public var videoBox:ComboBox;
    public var soundBox:ComboBox;
    public var lineBox:ComboBox;
    public var videoPlayerView:VideoPlayerView;
    private var _lastChooseRtmp:String = "";
    public var _pane:videoParam = new videoParam();
    private var  _highRtn:RadioButton = new RadioButton();
    private var  _normalRtn:RadioButton = new RadioButton();
    private var  _lowRtn:RadioButton = new RadioButton();
    private var _lastOverButton:RadioButton;
    public function VideoParamView(_v:VideoPlayerView):void {
        addChild(_pane);
        videoPlayerView = _v;
        _pane.yes_bt.addEventListener(MouseEvent.CLICK, suerClick);
        _pane.mcTip.visible = false;
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
        _highRtn.label ="高清";
        _normalRtn.label ="默认";
        _lowRtn.label ="流畅";
        _pane.addChild(_highRtn);
        _pane.addChild(_normalRtn);
        _pane.addChild(_lowRtn);
         addChild(_pane.mcTip);
        _highRtn.y =  _normalRtn.y = _lowRtn.y = 50;
        _highRtn.x =90;
        _normalRtn.x = _highRtn.x + _lowRtn.width +50;
        _lowRtn.x =_normalRtn.x +_normalRtn.width+50;
        _highRtn.mouseChildren=_normalRtn.mouseChildren=_lowRtn.mouseChildren=false;
        _normalRtn.selected = true;
        _lastOverButton = _normalRtn;
        _pane.mcTip.txt.autoSize = "left";
        _pane.mcTip.txt.wordWrap = true;
        initAddTips();
    }

    private function  initAddTips():void{
        _highRtn.addEventListener(MouseEvent.ROLL_OVER,onMoveHandle);
        _normalRtn.addEventListener(MouseEvent.ROLL_OVER,onMoveHandle);
        _lowRtn.addEventListener(MouseEvent.ROLL_OVER,onMoveHandle);
//        _highRtn.addEventListener(MouseEvent.ROLL_OUT ,onMoveHandle);
//        _normalRtn.addEventListener(MouseEvent.ROLL_OUT,onMoveHandle);
//        _lowRtn.addEventListener(MouseEvent.ROLL_OUT,onMoveHandle);
        this.addEventListener(MouseEvent.MOUSE_MOVE,onViewRollOver);
    }

    private function  onViewRollOver(evt:MouseEvent):void
    {
        if(evt.target !=_highRtn && evt.target != _normalRtn && evt.target!=_lowRtn)
        {
            _pane.mcTip.visible = false;
        }
    }

    private function onMoveHandle(evt:Event):void
    {
        if(evt.type == MouseEvent.ROLL_OVER)
        {
            _pane.mcTip.visible = true;
            _lastOverButton = evt.currentTarget as RadioButton;
            switch (evt.currentTarget)
            {
                case _highRtn:
                    _pane.mcTip.txt.text="可以有效提高画面清晰度,但是需要稳定的高上传带宽!";
                    _pane.mcTip.x = _highRtn.x+20;
                    _pane.mcTip.y = _highRtn.y -10;
                    break;
                case _normalRtn:
                    _pane.mcTip.txt.text="默认采集参数,在清晰度与流程之前争取平衡。";
                    _pane.mcTip.x = _normalRtn.x+20;
                    _pane.mcTip.y = _normalRtn.y -10;
                    break;
                case _lowRtn:
                    _pane.mcTip.txt.text="优先保障画面流程, 会损失一定的清晰度. 但消耗上传带宽比较小";
                    _pane.mcTip.x = _lowRtn.x+20;
                    _pane.mcTip.y = _lowRtn.y -10;
                    break;
            }
            _pane.mcTip.bg_mc.height =  _pane.mcTip.txt.height + 10;
        }
//        else{
//                _pane.mcTip.visible = false;
//        }
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
        var _arr:PingManager = DataCenterManger.adminPingManger;
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
        var _arr:PingManager = DataCenterManger.adminPingManger;
        _arr.startTestSped();
        _pane.btnTestSpeed.visible = false; //只是2秒间隔 点击测速按钮 以免过于频繁
        setTimeout(function ():void {
            _pane.btnTestSpeed.visible = true;
        }, 2000)
    }

    public function testSeedFinish(evt:Event):void {

        trace("testSeedFinish");
        var mage:PingManager = DataCenterManger.adminPingManger;
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
        var videQtype:int =0;
        if(_highRtn.selected)
        {
            videQtype =2;
        }
        else if(_normalRtn.selected)
        {
            videQtype =1;
        }
        else
        {
            videQtype = 0;
        }
        //Cc.log("主播手动选择的线路是:", _lastChooseRtmp);
        videoPlayerView.videoRoom.sendDataObject({"cmd": CBProtocol.startTalkPlay_20002, "rtmp": _lastChooseRtmp,"qtype":videQtype});//上麦
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