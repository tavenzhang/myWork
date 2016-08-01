package manger {
import com.junkbyte.console.Cc;
import com.rover022.IVideoRoom;
import com.rover022.tool.PingManager;
import com.rover022.vo.PlayerType;
import com.rover022.vo.RespondVo;
import com.rover022.vo.VideoConfig;
import com.rover022.vo.VipInfo;

import control.ControlsManger;

import flash.utils.Dictionary;

/**
 * 用户数据管理中心
 * 保存用户信息资料库
 * 保存RTMP以及好坏信息
 * 保存socket线路好坏信息
 * 保存用户成就信息
 *
 */
public class UserVoDataManger extends Object implements ISocketApp {
    public static var userData:Object;
    public static var userDataFirst:Boolean = true;
    public static var roomData:Object;
    public static var videoOwner:Object;//当前视频对象
    public static var cutoData:Object;//socket切换数据
    //, ,
    /**
     * -1:游客,
     * 0:PLAYER:玩家
     * 1:MASTER:主技人
     * 2:管理:MANAGER
     * 3:主播,ANCHOR
     */
    public static var playerState:int = PlayerType.GUEST;
    public static var roomAdmin:Boolean = false;//是否是房间所有者
    public static var adminPingManger:PingManager = new PingManager();
    public static var vipInfo:VipInfo = new VipInfo();
    public static var userPingManger:PingManager = new PingManager();
    public static var respondDic:Dictionary;
    public static var filterCMDArray:Array = [9999];
    public var view:IVideoRoom;
    public var isVideoPublisher:Boolean = false;
    private static var _instance:UserVoDataManger;
    //特效屏蔽
    private  static var _isShowGiftEffect:Boolean=true;

    /**
     * 是不是这个房间的主播
     * 也就是说是否是主播自己的
     */
    public function get isRoomAdmin():Boolean {
        if (roomData.roomid == userData.uid) {
            return true
        }
        return false;
    }

    /**
     * 是否是贵族
     */
    public function get isGuiZhu():Boolean {
        if (userData && userData.vip > 0) {
            return true;
        }
        return false;
    }

    /**
     * 是否有踢人或者禁言的权限
     */
    public function get canGetMangerCompetence():Boolean {
        if (userData.vip > 100 || userData.ruled == PlayerType.MANAGER || userData.ruled == PlayerType.ANCHOR || userData.ruled == PlayerType.MASTER) {
            return true;
        }
        return false;
    }

    /**
     * 根据ID看看是不是自己
     * @param _id
     */
    public function isSelf(_id:int):Boolean {
        if (userData.uid == _id) {
            return true
        }
        return false;
    }

    public static function getInstance():UserVoDataManger {
        if (_instance == null) {
            _instance = new UserVoDataManger();
        }
        return _instance;
    }

    public function register(_view:IVideoRoom):void {
        view = _view;
        respondDic = new Dictionary();
    }

    public function socketApp(sObject:Object):void {
        if (filterCMDArray.indexOf(sObject.cmd) == -1) {
            Cc.log("<--" + sObject.cmd, JSON.stringify(sObject));
        }
        ControlsManger.handleMessgae(int(sObject.cmd), sObject);
        //defaultHandle(sObject);
        ModuleLoaderManger.getInstance().handleNontice(sObject);
    }

    public function clientSocktApp(sObject:Object):void {
        Cc.log("客户端模拟收包<--" + sObject.cmd, JSON.stringify(sObject));
        socketApp(sObject);
    }

    //格式化视频流
    public static function formatStream(_obj:Object):void {
        if ((videoOwner && _obj && videoOwner.sid == _obj.sid && (_obj.rtmp && _obj.rtmp == videoOwner.rtmp)) || videoOwner == _obj) {
            return;
        }
        if (_obj && roomData) {
            _obj.rname = roomData.name;
        }
        videoOwner = _obj;
        ClientManger.getInstance().playRtmpVideo(videoOwner);
    }

    /** 增加  不经常使用的数据 回调 最后一次有效  避免 daraManager 难以维护*/
    public function createRespondHanld(cmdId:uint, func:Function):void {
        if (cmdId != 0 && func != null) {
            if (respondDic[cmdId] != null) {
                var item:RespondVo = respondDic[cmdId];
                item.destroy();
                delete respondDic[cmdId];
            }
            respondDic[cmdId] = new RespondVo(cmdId, func);
        }
    }

    public static function get isShowGiftEffect():Boolean {
        return _isShowGiftEffect;
    }

    public static function set isShowGiftEffect(value:Boolean):void {
        if(_isShowGiftEffect!=value)
        {
            _isShowGiftEffect = value;
            if(value)
            {
                ClientManger.getInstance().view.showAlert("开启礼物特效成功!");
            }else{
                ClientManger.getInstance().view.showAlert("关闭礼物特效成功!");
            }
            if( ClientManger.getInstance().view["giftPool"])
            {
                ClientManger.getInstance().view["giftPool"].showView.visible= value;
            }
        }

    }
}
}