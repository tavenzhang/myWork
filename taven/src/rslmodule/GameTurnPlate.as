/**
 * Created by Thomas on 2016/10/30.
 */
package rslmodule {
import com.greensock.BlitMask;
import com.greensock.TweenLite;
import com.greensock.TweenMax;
import com.rover022.CBProtocol;

import control.ControlsManger;
import control.MsgHandleVo;

import display.BaseRslModule;
import display.ui.Alert;

import flash.events.MouseEvent;
import flash.utils.setTimeout;

import ghostcat.util.easing.Circ;

import ghostcat.util.easing.Elastic;

import manger.DataCenterManger;

import net.NetManager;

public class GameTurnPlate extends BaseRslModule {
    private var gameView:taven_turnPlate;
    private var _timesFree:int=0;
    private var _isAnimationIng:Boolean = false;
    private var _initHistoryX:int =0;
    private   var blitMask1:BlitMask;
    private var _curAwardDetail:String;
    private var _curHistory:String="";

    override public function initView():void {
        gameView = new taven_turnPlate();
        gameView.x = 100;
        gameView.y = 400;
        _initHistoryX = gameView.txtHistory.x;
        gameView.btnHistoryRight.visible = gameView.btnHistoryLeft.visible=false;
        blitMask1 = new BlitMask(gameView.txtHistory,gameView.txtHistory.x,gameView.txtHistory.y,330,gameView.txtHistory.height,true,true,0xffffff,true);
        this.addChild(gameView);

    }

    override public function addEventListeners():void {
        gameView.addEventListener(MouseEvent.MOUSE_DOWN , onGameViewClick);
        gameView.addEventListener(MouseEvent.MOUSE_UP, onGameViewUp);
        regMsg();
    }

    function regMsg():void{
        ControlsManger.regMessgae(new MsgHandleVo(CBProtocol.moneyChange2,updateView));
        ControlsManger.regMessgae(new MsgHandleVo(CBProtocol.GAME_PLATE_62002,handleMessgae));
        ControlsManger.regMessgae(new MsgHandleVo(CBProtocol.GAME_PLATE_62004,handleMessgae));
    }
     public function handleMessgae(data:*):void {
        switch (data.cmd) {
            case CBProtocol.GAME_PLATE_62002: //更新数据
                _timesFree=int(data.drawTimes);
                _curHistory="";
                var historyList:Array = data.items;
                    if(historyList && historyList.length>0)
                    {
                        for each (var item:* in historyList)
                        {
                            _curHistory+=item.winDetail+"       ";
                        }
                    }
                updateView();
                break;
            case CBProtocol.GAME_PLATE_62004://抽奖结果
                if(!isAnimationIng){
                    isAnimationIng = true;
                    _curAwardDetail=data.detail;
                    startCJ(data.sortnum);
                }
                break;
        }
    }
    private function  onGameViewUp(e:MouseEvent):void {
        this.stopDrag();
    }

    private function onGameViewClick(e:MouseEvent):void {
        switch (e.target) {
            case gameView.btnClose:
                this.hide();
                break;
            case gameView.btnCJ:
                    if(DataCenterManger.myMony<100&&_timesFree<=0)
                    {
                        Alert.Show("您身上的钻石不够，请充值后继续抽奖！","友情提升");
                    }
                    else
                    {
                        NetManager.sendDataObject({"cmd": CBProtocol.GAME_PLATE_62004});//开始抽奖
                        gameView.btnCJ.mouseEnabled = false;
                        setTimeout(function () {
                        if(!_isAnimationIng)
                            gameView.btnCJ.mouseEnabled = true;
                        },1500);
                    }
                break;
            default:
                this.startDrag();
                break;
        }
    }

    override public function show():void {
        super.show();
        updateView();
        NetManager.sendDataObject({"cmd": CBProtocol.GAME_PLATE_62002});//获取抽奖信息
    }

    function startCJ(awardIndex:int):void {
        gameView.mcViewCJ.rotation = gameView.mcViewCJ.rotation % 360;
        trace("start rotation ===" + gameView.mcViewCJ.rotation + "----awardIndex=" + awardIndex);
        var targetT:int = (awardIndex * 45) - Math.random() * 33 - 5;
        var nowT:int = gameView.mcViewCJ.rotation;
        nowT = nowT < 0 ? (360 + nowT) : nowT;
        var dim:int = targetT - nowT;
        TweenLite.to(gameView.mcViewCJ, 10, {
            ease: Elastic.easeOut, "rotation": gameView.mcViewCJ.rotation + dim + 720, onComplete: function ():void {
                isAnimationIng=false;
                //通知抽奖结果 广播
                switch(awardIndex)
                {
                    case 4:
                        Alert.Show("再接再厉,越抽越猛！","很遗憾");
                        break;
                    case 3:
                    case 7:
                        Alert.Show("祝贺您 抽到了【"+_curAwardDetail+"】!","恭喜");
                        break;
                    case 1:
                    case 2:
                        Alert.Show("中大奖了 您抽到了【"+_curAwardDetail+"】!","福星高照");
                        NetManager.sendDataObject({"cmd": CBProtocol.GAME_PLATE_62005_NOTICE});//开始抽奖
                        break;
                    case 8:
                    case 6:
                        Alert.Show("恭喜小红手 您抽到了【"+_curAwardDetail+"】!","小红手");
                        NetManager.sendDataObject({"cmd": CBProtocol.GAME_PLATE_62005_NOTICE});//开始抽奖
                        break;
                    case 5:
                        Alert.Show("特等奖 恭喜您抽到了【"+_curAwardDetail+"】!","独步天下");
                        NetManager.sendDataObject({"cmd": CBProtocol.GAME_PLATE_62005_NOTICE});//开始抽奖
                        break;
                }
                updateView();
            }
        });
        TweenLite.to(gameView.mcCircle, 8, {"rotation": gameView.mcCircle.rotation - 720});
    }

    private  function updateView(data:*=null){
        if(!isAnimationIng)
        {
            gameView.txtTime.text = _timesFree +" 次";
            gameView.txtTime.textColor = _timesFree<=0 ? 0xFF0000:0x99FF00;
            gameView.txtMoeney.text = DataCenterManger.myMony.toString();
            gameView.txtMoeney.textColor =  DataCenterManger.myMony<=0 ? 0xFF0000:0x99FF00;
            gameView.txtHistory.text=_curHistory;
            gameView.txtHistory.width =  gameView.txtHistory.textWidth+4;
            TweenMax.killTweensOf(gameView.txtHistory);
            blitMask1.update(null, true);
            TweenMax.to(gameView.txtHistory,20*(gameView.txtHistory.textWidth/330),{x:gameView.txtHistory.x-gameView.txtHistory.textWidth*1, repeat:-1, yoyo:true, repeatDelay:1});
        }
    }

    public function get isAnimationIng():Boolean {
        return _isAnimationIng;
    }

    public function set isAnimationIng(value:Boolean):void {
        _isAnimationIng = value;
         gameView.btnCJ.mouseEnabled = !_isAnimationIng;
    }
}
}
