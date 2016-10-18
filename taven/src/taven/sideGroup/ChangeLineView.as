/**
 * Created by ws on 2015/7/5.
 */
package taven.sideGroup {
import com.bit101.components.Label;
import com.bit101.components.Style;
import com.junkbyte.console.Cc;
import com.rover022.IPlayer;
import com.rover022.ModuleNameType;
import com.rover022.tool.NetPing;
import com.rover022.tool.PingManager;

import display.BaseModule;
import display.ui.Alert;

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextFormat;
import flash.utils.setTimeout;

import manger.ModuleLoaderManger;
import manger.DataCenterManger;

import net.NetManager;

import taven.utils.CCComboBox;
import taven.utils.DisplayUtils;
import taven.videoParamClient;

public class ChangeLineView extends BasePaneUI {
    private var _viewBtn:MovieClip;
    public var lineBox:CCComboBox;
    private var _module:BaseModule;
    private var _rtmpManage:PingManager;
    private var _lastChooseRtmp:String = "";
    public var _pane:videoParamClient = new videoParamClient();

    public function ChangeLineView(view:MovieClip, vidoRoom:BaseModule):void {
        addChild(_pane);
        _viewBtn = view;
        _module = vidoRoom;
        _viewBtn.addEventListener(MouseEvent.CLICK, closeClick);
        _pane.yes_bt.addEventListener(MouseEvent.CLICK, suerClick);
        _pane.mcTip.visible =false;
        Style.embedFonts = false;
        Style.fontSize = 12;
        Style.fontName = "宋体";
        Style.setStyle(Style.DARK);
        //
        makeLabel("线路:", 50, 100);
        lineBox = new CCComboBox(this, 105, 100);
        lineBox.setSize(150, 20);
        for (var i:int = 0; i < 50; i++) {
            lineBox.addItem({label: "wait..."});
        }
        _pane.btnTestSpeed.x = lineBox.x + lineBox.width + 5;
        _pane.btnTestSpeed.y = lineBox.y - 2;
        addEventListener(Event.ADDED_TO_STAGE,onAddtoStageHandle);
        super();
    }

    private function onAddtoStageHandle(evt:Event):void
    {
        if(_lastChooseRtmp=="")
        {
            firstOpenLineBox();
        }
    }


    private function makeLabel(s:String, i:int, i2:int):Label {
        var label:Label = new Label(this, i, i2, s);
        label.textField.defaultTextFormat = new TextFormat("宋体", 12, 0xffffff);
        return label;
    }

    private function firstOpenLineBox():void {
        if (_module.videoRoom.getDataByName(ModuleNameType.USERROOMDATA)) {
            _rtmpManage = DataCenterManger.userPingManger;
            _lastChooseRtmp = DataCenterManger.userData.lastRtmp;
            _lastChooseRtmp = (_lastChooseRtmp == null) ? "" : _lastChooseRtmp;
            _rtmpManage.addEventListener(PingManager.ITEM_TESTOK, testSeedFinish);
            //页面刚进入是时候已经完成了一次速度测试
            lineBox.items = _rtmpManage.rtmpSortlist;
            lineBox.selectedIndex = 0;
            _pane.btnTestSpeed.addEventListener(MouseEvent.CLICK, onTestSpeddClick)
        }
    }

    private function onTestSpeddClick(evt:Event):void {
        _rtmpManage.startTestSped();
        _pane.btnTestSpeed.visible = false; //只是2秒间隔 点击测速按钮 以免过于频繁
        setTimeout(function ():void {
            _pane.btnTestSpeed.visible = true;
        }, 2000)
    }

    private function testSeedFinish(evt:Event):void {
        try
        {
            var _select:int = 0;
            var sortList:Array = _rtmpManage.rtmpSortlist;
            lineBox.items = sortList;
            for (var i:int = 0; i < sortList.length; i++) {
                var object:NetPing = sortList[i];
                if (object.rtmp == _lastChooseRtmp) {
                    _select = i;
                    break;
                }
            }
            lineBox.draw();
            lineBox.selectedIndex = _select;
        }
        catch (e:*)
        {
           Cc.log("testSeedFinish lineBox error --"+e.toString());
        }

    }

    public function suerClick(e:MouseEvent):void {
        DisplayUtils.removeFromParent(this);
        if (!lineBox.selectedItem)
            return;
        if (DataCenterManger.videoOwner == null) {
            Alert.Show("后台小弟遗憾的告诉你:当前房间主播还没有上麦,或者刚下麦.", "系统消息");
            return;
        }
        if (NetManager.getInstance().socketClient.connected == false) {
            Alert.Show("后台socket没有连接...", "系统消息");
            return;
        }
        if (_lastChooseRtmp == "") {
            _module.videoRoom.sendDataObject({"cmd": 20001, "rtmp": lineBox.selectedItem.rtmp});//通知服务器 切换播放线路
            _lastChooseRtmp = lineBox.selectedItem.rtmp;
        }
        else {
            if (_lastChooseRtmp != lineBox.selectedItem.rtmp) {
                // _module.videoRoom.sendDataObject({"cmd": 20001, "rtmp": lineBox.selectedItem.data});//通知服务器 切换播放线路 客户端优化 不用通知服务器 直接切换即可。 主播因为需要广播 必须发消息
                _lastChooseRtmp = lineBox.selectedItem.rtmp;
                var iPlay:IPlayer = ModuleLoaderManger.getInstance().getModule(ModuleNameType.VIDEOPLAYER) as IPlayer;
                iPlay.playRTMP(DataCenterManger.videoOwner.sid, _lastChooseRtmp);
            }
            else {
                _module.videoRoom.showAlert("您当前正在使用此线路，请切换其他线路试试!", "");
            }
        }
    }
}
}
