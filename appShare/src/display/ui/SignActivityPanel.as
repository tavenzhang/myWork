/**
 * Created by chenbin on 2015/8/22.
 */
package display.ui {
import com.junkbyte.console.Cc;
import com.rover022.IVideoModule;
import com.rover022.IVideoRoom;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

import ghostcat.text.NumberUtil;

import manger.ClientManger;

import net.NetManager;

import tool.VideoTool;

public class SignActivityPanel extends Sprite implements IVideoModule {
    private var view:MovieClip;

    public var points:int;
    public var num:int;//这是第几次领取
    public var topTime:int;

    private var time:String;
    private var systime:String;
    private var systimeDate:Date;
    private var currentButton:MovieClip;
    private var nextClip:MovieClip;
    private var nextClipTime:int;
    public var isAlreadySinal:Boolean = false;
    public var buttonArray:Array = [];

    public var errorArray:Array = [];
    public var pointClip:MovieClip;
    private var tick:Timer;

    public function SignActivityPanel() {
        super();

        view = new getSignActivityMc();
        addChild(view);

        for (var i:int = 0; i < 7; i++) {
            var clip:MovieClip = view["btn" + i];
            clip.buttonMode = true;
            clip.mouseChildren = false;
            clip.addEventListener(MouseEvent.CLICK, clickHandle);
            buttonArray.push(clip);
        }

        view.btnSuper.visible = false;
        view.btnSuper.buttonMode = true;
        view.btnSuper.addEventListener(MouseEvent.CLICK, clickHandle);
        view.btnSuper.gotoAndStop(2);

        x = 60;
        y = 300;
        errorArray[2109] = "未验证安全邮箱";
        errorArray[2110] = "未到签到时间";
        errorArray[2111] = "禁止签到";
        errorArray[2112] = "今日已签到";
        errorArray[2113] = "同一ip每天最多5次签到";

        tick = new Timer(1000, 0);
        tick.addEventListener(TimerEvent.TIMER, onTickHandle);
        tick.start();
    }

    private function onTickHandle(event:TimerEvent):void {
        if (isAlreadySinal == false) {
            topTime--;
            view.timeTxt.text = NumberUtil.toDurTimeString(topTime * 1000);
            if (topTime <= 0) {
                if (time == "" || VideoTool.areSameDay(time, systime) == false) {
                    setCanGetButton(num, true);
                }
                isAlreadySinal = true;
            }
        }

        if (nextClip) {
            nextClipTime--;
            nextClip.messionTxt.text = NumberUtil.toDurTimeString(nextClipTime * 1000);
        }
    }

    public function init(sObject:Object, btnGet:MovieClip):void {
        //second 已经在线时长
        //ret,sign,uid,num,time,points,systime,second
        //0,0 ,0 , 0,1,0,1,1
        pointClip = btnGet;

        topTime = 10 *60;
        if (sObject.ret == 1 || sObject.ret == 2112) {

            points = sObject.points;
            num = sObject.num;

            time = sObject.time;
            systime = sObject.systime;
            systimeDate = VideoTool.getDateByString(systime);
            view.num_txt.text = num.toString();
            view.pointTxt.text = points.toString();
        }
        setCanGetButton(num);
        for (var i:int = 0; i < 7; i++) {
            view["txt" + i].text = "奖励" + sObject.items[i].money + "钻石";
        }
        //

        if (VideoTool.areSameDay(time, systime)) {
            pointClip.pointMc.visible = false;
            view.timeTxt.text = "今日已签到";
            isAlreadySinal = true;

            setNextRunClip();
        } else {
            pointClip.pointMc.visible = true;
        }
    }

    /**
     * 按钮
     * @param num
     * @param isClick
     */
    public function setCanGetButton(num:int, isClick:Boolean = false):void {

        var _realNum:int = num;
        for (var i:int = 0; i < 7; i++) {
            var clip:MovieClip = view["btn" + i];
            clip.mouseEnabled = false;
            clip.gotoAndStop(1);
            clip.messionTxt.text = "";
            if (_realNum > i) {
                clip.messionTxt.text = "已领取";

            } else if (_realNum == i) {
                if (isClick == true) {
                    clip.gotoAndStop(2);
                    clip.mouseEnabled = true;
                } else {
                    clip.messionTxt.text = "未领取";
                }
            } else {
                clip.messionTxt.text = "未领取";
            }
        }
        if (num > 6 && isClick) {
            view.btnSuper.visible = true;
        }
    }


    /**
     * 是否可以签到
     * @return
     */
    private function get isAllOwSignal():Boolean {
        var _signal:Object = loadShareData();
        Cc.log("签到了,", _signal.current);
        if (_signal.current > 5) {
            return false;
        }
        return true;
    }

    public function loadShareData():Object {
        var _signal:Object = VideoTool.getShareObject("MaxSinging");
        if (_signal == null) {
            _signal = {};
            _signal.current = 0;
            _signal.time = new Date();
        } else {
            if (VideoTool.areSameDayByDate(_signal.time, systimeDate) == false) {
                _signal.current = 0;
                _signal.time = new Date();
            }
        }
        return _signal;
    }

    public function saveShareData():void {
        var _signal:Object = loadShareData();
        _signal.current++;
        VideoTool.saveShareObject(_signal, "MaxSinging");
        trace("签到保存成功_signal.current", _signal.current);
    }

    public function clickHandle(e:MouseEvent):void {
        //<results>ret,uid,num,time,points</results>
        //<resultsCat>0,0,0,1,0</resultsCat>
        //是否是游客检查
        if (ClientManger.getInstance().isGuestAndGuestRegister()) {
            trace("是游客不能签到");
            return;
        }
        //一台电脑一天只能签到5
        if (isAllOwSignal == false) {
            Alert.Show("你今天已经用这台电脑签到5次了.请明天再来");
            return;
        }


        currentButton = e.currentTarget as MovieClip;
        var clip:MovieClip = e.currentTarget as MovieClip;
        if (clip.currentFrame == 2) {

            NetManager.getInstance().sendDataObject({"cmd": 24002});

            if (clip.name == "btnSuper") {
                clip.visible = false;
            }
        }
    }

    public function set videoRoom(src:IVideoRoom):void {
    }

    public function get videoRoom():IVideoRoom {
        return null;
    }

    public function listNotificationInterests():Array {
        return [24002];
    }

    public function setNextRunClip():void {
        var sa:Date = new Date();
        nextClipTime = (23 - sa.getHours()) * 3600 + (60 - sa.getMinutes()) * 60 + sa.getSeconds();
        nextClip = buttonArray[num];

    }

    public function handleNotification(src:Object):void {
        switch (src.cmd) {
            case 24002:
                if (src.ret == 1) {
                    //trace("领奖成功");
                    currentButton.messionTxt.text = "已签到";
                    currentButton.gotoAndStop(1);
                    currentButton.mouseEnabled = false;

                    num++;
                    setNextRunClip();

                    view.timeTxt.text = "今日已签到";
                    view.num_txt.text = num.toString();

                    pointClip.pointMc.visible = false;

                    saveShareData();
                    Alert.Show("领奖成功");
                } else {
                    Alert.Show(errorArray[src.ret]);
                }
                break;
        }
    }


}
}
