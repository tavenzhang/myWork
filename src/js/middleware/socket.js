/**
 * Created by soga on 16/9/22.
 */

import { wsAN } from '../actions/socket';
import { getCookie, log } from '../utils/util';
import CryptoJS from 'crypto-js';
import { SOCKET } from '../config';
import { appAN } from './../actions/app'
import {wsAct} from './../actions'

//房间密匙加密方法
//data 是准备加密的字符串,key是你的密钥,iv是偏移量
const encryption = (data, key, iv) => {
    let skey  = CryptoJS.enc.Latin1.parse(key);
    let siv   = CryptoJS.enc.Latin1.parse(iv);
    //加密
    let encrypted = CryptoJS.AES.encrypt(
        data,
        skey,
        {iv:siv,mode:CryptoJS.mode.CBC,padding:CryptoJS.pad.Pkcs7
        });

    return encrypted.toString();
    //解密
    //var decrypted = CryptoJS.AES.decrypt(encrypted,key,{iv:iv,padding:CryptoJS.pad.ZeroPadding});
};

let EXTCK = null; //聊天送礼加密key，用户唯一标示
let USERID = 0; //当前用户id

let [socket,socketMsg,socketGift] = [null,null,null];

//登陆命令
const loginCMD = '{"cmd":10000}';

class WS {
    constructor(url) {
        this.websocket = new WebSocket(url);
        this.socketName=url;
        this.websocket.onmessage = function(event) {
            //log(event.data);
        }

        this.websocket.onopen = function(event) {
            log( this.socketName+"----WS OPEN");
        }

        this.websocket.onerror = function(error) {
            log( this.socketName+"-----WS ERR: " + error);
        }

    }

    onOpenState(func) {
        this.websocket.onopen = function() {
            log( this.socketName+"WS OPEN");
            func();
        }
    }

    getMsg() {
        this.websocket.onmessage = function(event) {
            return event.data;
        }
    }

    postMessage(text) {
        this.websocket.send(text);
        log(this.socketName+'--->',text)
    }

    close() {
        this.websocket.close();
        log(this.socketName+'----WS close');
    }
}

const webSocketMiddleware = store => next => action => {

    const closeCosket = () => {
     //   log("WS close");
        if(null !== socket) {//断开普通socket
            socket.close();
        }

        if(null !== socketMsg) {//断开聊天socket
            socketMsg.close();
        }

        if(null !== socketGift) {//断开送礼socket
            socketGift.close();
        }
    }

    if(wsAN.CONNECT === action.type) { //连接socke
        if(action.data && action.data.type == "chat") {
            if(socketMsg) { //关闭之前的链接
                socketMsg.close();
                socketMsg = null;
            }
            if(null == socketMsg) {
                //优化显示socket信息
                next({
                    type:wsAN.CHAT_MESSAGE,
                    data:{
                        cmd : 1, //系统连接信息
                        content : "正在连接服务器..."
                    }
                });

                //链接socket
                socketMsg = new WS(action.uri);
                socketMsg.socketName="m:"
                //登录
                socketMsg.onOpenState(function(){
                    //优化显示socket信息
                    next({
                        type:wsAN.CHAT_MESSAGE,
                        data:{
                            cmd : 1, //系统连接信息
                            content : "正在登陆服务器..."
                        }
                    });
                    socketMsg.postMessage(loginCMD); //登陆
                    socketMsg.websocket.onmessage = function(event) {
                        let data = JSON.parse(event.data);
                        log('m:<------:'+data.cmd,data);

                        switch(data.cmd) {
                            case 10000 ://登陆密匙
                                //登陆房间
                                if(action.data.extck) {
                                    let userlimitStr = action.data.extck + SOCKET.WSCHAT_SECTRITY;
                                    let userlimit = encryption(userlimitStr,data.limit,SOCKET.AES_IV);
                                    socketMsg.postMessage(JSON.stringify({
                                        cmd : 10001,//登陆房间
                                        roomLimit : userlimit,//返回的密匙
                                    }));
                                }


                                break;
                            case 10001 ://登陆成功后
                                //通用socket登陆后，根据返回的extck值
                                if(action.data && action.data.callback) {
                                    action.data.callback(EXTCK);
                                }
                                //优化显示socket信息
                                next({
                                    type:wsAN.CHAT_MESSAGE,
                                    data:{
                                        cmd : 1, //系统连接信息
                                        content : "连接成功，您可以进行聊天了"
                                    }
                                });
                                break;

                            case 30001 : //聊天//type=3的时候是系统消息
                                if(data.type == 3) {
                                    next({
                                        type:wsAN.UPDATE_ROOMMSGS,
                                        data:{
                                            type: data.type,//类型为1是主播房间消息，3是系统消息
                                            msg: data.content
                                        }
                                    });
                                }

                                next({
                                    type:wsAN.CHAT_MESSAGE,
                                    data:{
                                        cmd : data.cmd,
                                        content : data.content,
                                        date : data.date,
                                        richLv : data.richLv,
                                        sendName : data.sendName,
                                        sendUid : data.sendUid,
                                        icon : data.icon,
                                        type : data.type,
                                        vip : data.vip,
                                        lv : data.lv
                                    }
                                });

                                break;

                            case 500 ://登陆错误
                            case 15555 : //错误提示
                                next({
                                    type:appAN.SHOW_INFOBOX,
                                    msg:data.msg || "操作错误~",
                                    style:'error'
                                });
                                break;

                            default :
                        }

                    }
                });
            }
        }
        else if(action.data && action.data.type == "gift") {
            if(socketGift) { //关闭之前的链接
                socketGift.close();
                socketGift=null;
            }
            if(null == socketGift) {

                //链接socket
                socketGift = new WS(action.uri);
                socketGift.socketName="g:"
                //登录
                socketGift.onOpenState(function(){
                    socketGift.postMessage(loginCMD); //登陆
                    socketGift.websocket.onmessage = function(event) {
                        let data = JSON.parse(event.data);
                        log('g:<------ ',data);

                        switch(data.cmd) {
                            case 10000 ://登陆密匙
                                //登陆房间
                                if(action.data.extck) {
                                    let userlimitStr = action.data.extck + SOCKET.WSGIFT_SECTRITY;
                                    let userlimit = encryption(userlimitStr,data.limit,SOCKET.AES_IV);

                                    socketGift.postMessage(JSON.stringify({
                                        cmd : 10001,//登陆房间
                                        roomLimit : userlimit,//返回的密匙
                                    }));
                                }

                                break;

                            case 10001:
                                //通用socket登陆后，根据返回的extck值
                                if(action.data && action.data.callback) {
                                    action.data.callback(EXTCK);
                                }
                                break;

                            case 40001 : //用户送礼信息
                                //消息列表显示
                                next({
                                    type:wsAN.CHAT_MESSAGE,
                                    data:{
                                        cmd : data.cmd, //系统连接信息
                                        sendName : data.sendName,//赠送人
                                        sendUid : data.sendUid,//赠送人id
                                        gid: data.gid,//礼物id
                                        gnum: data.gnum,//礼物数
                                        price: data.price,//价格
                                        recName: data. recName //收礼人
                                    }
                                });

                                //追加礼物清单
                                next({
                                    type:wsAN.UPDATE_SENDGIFTLISTS,
                                    data:[{
                                        name : data.sendName,//赠送人
                                        gid: data.gid,//礼物id
                                        num: data.gnum,//礼物数
                                        created: data.created,//时间
                                        richLv: data.richLv,//等级
                                        vipLv: data.icon,//vip
                                    }]
                                });

                                //动画效果显示
                                next({
                                    type:wsAN.SEND_GIFTEFFECT,
                                    data:{
                                        sendName : data.sendName,//赠送人
                                        headimg : data.headimg,//赠送人头像
                                        gid: data.gid,//礼物id
                                        goodCategory: data.goodCategory,//礼物种类
                                        price: data.price,//价格
                                        //created: data.created,//创建时间
                                        gnum: data.gnum//礼物数
                                    }
                                });
                                break;

                            case 500 ://登陆错误
                            case 15555 : //错误提示
                                let errMsg = data.msg;

                                switch (data.errorCode) {
                                    case 2120:
                                        errMsg ="当前房间禁止聊天";
                                        break;

                                    default :
                                        errMsg = "操作错误~";
                                }

                                next({
                                    type:appAN.SHOW_INFOBOX,
                                    msg:errMsg,
                                    style:'error'
                                });
                                break;

                            default :
                        }

                    }
                });
            }
        }
        else {
            if(socket) { //关闭之前的链接
                socket.close();
                socket=null;
            }

            if(null == socket) {
                const socketAction = () => {
                    socket.postMessage(loginCMD); //登陆
                    socket.websocket.onmessage = function(event) {
                        let data = JSON.parse(event.data);
                        log("comm:<------ "+data.cmd,data);
                        const appSt = store.getState().appState;

                        switch(data.cmd) {
                            case 10000 ://登陆密匙
                                //登陆房间
                                let roomid = action.data.roomid;
                                let phpSession = getCookie('PHPSESSID') || '';
                                let userlimitStr = phpSession + roomid + SOCKET.WS_SECTRITY;
                                let userlimit = encryption(userlimitStr,data.limit,SOCKET.AES_IV);

                                socket.postMessage(JSON.stringify({
                                    cmd : 10001,//登陆房间
                                    key : phpSession,//sessionid
                                    roomid : roomid,//房间号
                                    pass : '',
                                    roomLimit : userlimit,//返回的密匙
                                    isPulish : false,
                                    pulishUrl : '',
                                    sid : ''
                                }));
                                break;

                            case 10001 ://登陆成功后

                                EXTCK = data.extck;
                                USERID = data.uid;
                                // 如果保存状态与 服务器不一致  强制把登陆状态置回去
                                if(data.ruled<0&&store.getState().appState.isLogin)
                                {
                                    next({
                                        type: appAN.LOGOUT,
                                    });
                                }

                                next({
                                    type:wsAN.SOCKET_SUCCESS
                                });

                                //请求观众数据
                                socket.postMessage(JSON.stringify({
                                    cmd : 11001,
                                    start : 0,
                                    end : 10
                                }));

                                //获取日贡献数据
                                socket.postMessage(JSON.stringify({
                                    cmd : 15001
                                }));

                                //请求下播地址
                                socket.postMessage(JSON.stringify({
                                    cmd : 80002
                                }));

                                //获取管理员列表
                                socket.postMessage(JSON.stringify({
                                    cmd : 11008
                                }));

                                break;

                            case 10002 : //房间信息
                                next({
                                    type:wsAN.UPDATE_HOSTER,
                                    data:data
                                });
                                break;

                            case 10003 : //房间内主播公告
                                next({
                                    type:wsAN.UPDATE_ROOMMSGS,
                                    data:{
                                        type: 1,//类型为1是主播房间消息，3是系统消息
                                        msg: data.content
                                    }
                                });
                                break;

                            case 10005 : //模式
                                break;

                            case 10008 : //广播经验
                                break;

                            case 10009 : //广播剩余点卷
                                break;

                            case 10011 : //返回用户进入房间限制条件
                                break;

                            case 10012 : //主播手动开关用户进入房间限制条件
                                break;

                            case 10013 : //获取用户房间内权限配置（用户权限或贵族权限），在用户进房间、用户等级变化、贵族等级变化(需要js调用flash来拉一次18001)时发送给flash
                                if(data.forbidChat) { //"forbidChat":0(允许聊天) "forbidChat":1(禁止聊天)
                                    //房间显示弹出警告框
                                    next({
                                        type:wsAN.SHOW_ALERTDIALOG,
                                        status:true,
                                        content:"当前房间禁止聊天",
                                        dialogType:5
                                    });
                                }
                                if(parseInt(data.allowvisitroom)==1)// 如果是0 无限制 1有限制
                                {
                                    if(parseInt(data.limitRoomCount)<=0)//大于0表示可以访问
                                    {
                                        next({
                                            type:wsAN.GOTO_HOME,
                                            data:false
                                        });
                                    }
                                }
                                next({
                                    type:wsAN.LIMIT_INFO,
                                    data:data
                                });

                                break;

                            case 10014 : //当用户进入限制房间时，如果不满足限制房间条件，可根据后台配置的用户等级进限制房间次数，进入限制房间，同一个房间不重复计数
                                break;

                            case 11001 : //玩家列表
                                if(data.items) {
                                    next({
                                        type:wsAN.GET_AUDIENCES,
                                        data:data.items
                                    });
                                }
                                break;

                            case 11002 : //进入房间
                                //通用socket登陆后，根据返回的extck值，登陆聊天和送礼socket
                                if(action.data && action.data.callback && USERID == data.uid) {
                                    action.data.callback(EXTCK);
                                }

                                //排除游客的用户,id小于50000的是游客
                                if(data.uid >= 50000 && data.ruled != 3) {//排除主播
                                    //人员进入添加欢迎消息到聊天内容中,加入观众列表
                                    next({
                                        type:wsAN.USER_JOINS_ROOM,
                                        data:data
                                    });
                                }
                                break;

                            case 11003 : //退出房间
                                //删除离开用户在观众列表的数据
                                //排除游客的用户,id小于50000的是游客
                                if(data.uid >= 50000) {
                                    next({
                                        type:wsAN.USER_LEAVES_ROOM,
                                        data:data
                                    });
                                }
                                break;

                            case 11004 : //模糊查询玩家列表
                                break;

                            case 11006 : //增加管理员
                                next({
                                    type:wsAN.ADD_ADMIN,
                                    data:data
                                });

                                //新增的管理员是当前用户的话，消息提示
                                //信息通知
                                if(appSt.isLogin && appSt.userInfo.uid ==  data.uid) {
                                    next({
                                        type:appAN.SHOW_INFOBOX,
                                        msg:"恭喜您被房主提升为管理员~~",
                                        style:'success'
                                    });
                                }

                                break;

                            case 11007 : //删除管理员
                                next({
                                    type:wsAN.DELETE_ADMIN,
                                    data:data
                                });

                                //删除的管理员是当前用户的话，消息提示
                                //信息通知
                                if(appSt.isLogin && appSt.userInfo.uid ==  data.uid) {
                                    next({
                                        type: appAN.SHOW_INFOBOX,
                                        msg: "sorry，您被房主取消了管理员资格",
                                        style: 'error'
                                    });
                                }
                                break;

                            case 11008 : //管理员列表
                                next({
                                    type:wsAN.UPDATE_ADMINS,
                                    data:data.items
                                });
                                break;

                            case 12006 : //主播下播推荐其他房间id
                                break;

                            case 12007 : //还剩多少时间可以聊天
                                break;

                            case 13001 : //邀请主播一对一
                                break;

                            case 13004 : //拒绝用户一对一请求
                                break;

                            case 14001 : //座位
                                break;

                            case 14002 : //抢座位
                                break;

                            case 15001 : //本日贡献
                                if(data.items) {
                                    next({
                                        type:wsAN.UPDATE_TODAYGIFTS,
                                        data:data.items
                                    });
                                }
                                break;

                            case 15002 : //增量更新本日贡献
                                    next({
                                        type:wsAN.UPDATE_TODAYGIFTS,
                                        data:data
                                    });
                                break;

                            case 15004 : //魅力之星活动排名
                                break;

                            case 15005 : //本场礼物排行榜，总计
                                next({
                                    type:wsAN.UPDATE_MONEYTOTAL,
                                    data:data.total
                                });
                                break;

                            case 18001 : //用户在主播房间内开通贵族后，提醒主播，并广播给房间内所有用户的公屏，并返回该贵族等级对应的房间内权限配置
                                break;

                            case 18002 : //贵宾席,isSingle=1表示更新一条，isSingle=0表示更新整个榜
                                break;

                            case 18005 : //(贵族)禁言及踢人
                                break;

                            case 20001 : //获取当前房间内已上麦的主播列表
                                next({
                                    type:wsAN.UPDATE_VIDEOURL,
                                    data:data.items
                                });
                                break;

                            case 20002 : //开始直播
                                break;

                            case 20003 : //下麦
                                break;

                            case 21001 : //电影flv
                                break;

                            case 23001 : //申请连麦
                                break;

                            case 23002 : //同意申请连麦
                                break;

                            case 23004 : //放弃连麦
                                break;

                            case 23005 : //断开主播视频流上传
                                break;

                            case 24001 : //获取签到任务
                                break;

                            case 24002 : //做签到任务
                                break;

                            case 30003 : //发送弹窗消息
                                break;

                            case 40002 : //礼物轮播
                                break;

                            case 40003 : //房间跑道，豪华礼物
                                break;

                            case 50001 : //主播房间列表
                                break;

                            case 50002 : //主播房间列表
                                break;

                            case 50004 : //主播房间列表
                                break;

                            case 50005 : //主播房间预约列表
                                break;

                            case 50006 : //用户消息列表数目
                                break;

                            case 62001 : //中间消息提示

                                next({
                                    type:wsAN.SHOW_ALERTDIALOG,
                                    title:data.title,
                                    status:true,
                                    content:data,
                                    dialogType:6
                                });
                                break;

                            case 80002 : //主播下播地址
                                if(data.hls) {
                                    next({
                                        type:wsAN.UPDATE_VIDEOURLS,
                                        data:data.hls
                                    });
                                }
                                else {//主播不在直播
                                    next({
                                        type:wsAN.SHOW_ALERTDIALOG,
                                        status:true,
                                        content:"当前主播暂未开播~",
                                        dialogType:5
                                    });
                                }
                                break;
                            case 500 ://登陆错误
                                let alertDialogType = 1;
                                //断开socket
                                if(null !== socket) {
                                    closeCosket();
                                }

                                //退出登陆
                                if(data.errorCode == 1001) {
                                    next({
                                        type:appAN.LOGOUT
                                    });
                                    //重复登陆提示
                                    alertDialogType = 5;
                                    //断开视频流
                                    next({
                                        type:wsAN.CLOSE_VIDEO
                                    });
                                }

                                //房间显示弹出警告框
                                next({
                                    type:wsAN.SHOW_ALERTDIALOG,
                                    status:true,
                                    content:data.msg,
                                    dialogType:alertDialogType
                                });

                                break;

                            case 15555 : //错误提示
                                let errMsg = data.msg;

                                switch (data.errorCode) {
                                    //case 20002:
                                    //    errMsg ="已在麦上";
                                    //    break;
                                    //
                                    //case 1515:
                                    //    errMsg ="点歌不能超过两首";
                                    //    break;

                                    //case 1701:
                                    //    errMsg ="麦序歌曲不存在，切歌失败";
                                    //    break;
                                    //
                                    //case 1512:
                                    //    errMsg ="调麦失败";
                                    //    break;

                                    case 1008:
                                        errMsg ="您已被系统禁言";
                                        break;

                                    //case 1514:
                                    //case 1516:
                                    //    errMsg ="您不是房主不能踢人";
                                    //    break;

                                    case 1543:
                                        errMsg ="被踢出过,10分钟内不能进入房间";
                                        break;

                                    case 1003:
                                        errMsg ="余额不足";
                                        break;


                                    case 2005:
                                        errMsg ="游客不能进入";
                                        break;

                                    //case 2007:
                                    //    errMsg ="钱不够不能发喇叭";
                                    //    break;
                                    //
                                    //case 2012:
                                    //    errMsg ="钱不足抢坐";
                                    //    break;
                                    //
                                    //case 2014:
                                    //    errMsg ="没主播不能抢坐";
                                    //    break;
                                    //
                                    //case 2015:
                                    //    errMsg ="主播不能抢坐";
                                    //    break;

                                    case 2016:
                                        errMsg ="主播未开播不能送礼";
                                        break;

                                    //case 2101:
                                    //    errMsg ="已经是管理员";
                                    //    break;
                                    //
                                    //case 2102:
                                    //    errMsg ="超过40个管理员";
                                    //    break;


                                    case 4001:
                                        errMsg ="普通用户不能赠送贵族礼物";
                                        break;

                                    case 1814:
                                        errMsg ="没有权限,请充值升级你的贵族等级";
                                        break;

                                    default :
                                        errMsg = "操作错误~";
                                }

                                next({
                                    type:appAN.SHOW_INFOBOX,
                                    msg:errMsg,
                                    style:'error'
                                });
                                break;

                            default :
                        }

                    }
                };

                //链接socket
                socket = new WS(action.uri);
                socket.socketName="comm"

                //登录
                socket.onOpenState(socketAction);
            }
        }

    }

    if(wsAN.SEND_MESSAGE === action.type) { //发送信息
        if(null !== socketMsg) {
            socketMsg.postMessage(JSON.stringify({
                cmd : 30001,
                type: 0,
                content: action.data,
                recUid: 0
            }))
        }
        else {
            next({
                type:appAN.SHOW_INFOBOX,
                msg:"聊天服务器连接失败~",
                style:'error'
            });
        }
    }

    if(wsAN.HEART === action.type) {//心跳链接
        if(action.wsType == 'gift') {//礼物socket
            socketGift.postMessage(JSON.stringify({
                cmd : 9999,
                type: action.wsType
            }))
        }
        else if(action.wsType == 'chat') {
            socketMsg.postMessage(JSON.stringify({
                cmd : 9999,
                type: action.wsType
            }))
        }
        else if(action.wsType == 'comm') {
            socket.postMessage(JSON.stringify({
                cmd : 9999,
                type: action.wsType
            }))
        }
    }

    if(wsAN.SEND_GIFT === action.type) { //送礼物
        if(null !== socketGift) {
            socketGift.postMessage(JSON.stringify(action.data))
        }
        else {
            next({
                type:appAN.SHOW_INFOBOX,
                msg:"送礼服务器连接失败~",
                style:'error'
            });
        }
    }

    //获取直播地址
    if(wsAN.GET_VIDEOURL === action.type) { //送礼物
        if(null !== socket) {
            socket.postMessage(JSON.stringify({
                cmd : 20001,
                rtmp: action.url,
            }))
        }
        else {
            next({
                type:appAN.SHOW_INFOBOX,
                msg:"连接失败~",
                style:'error'
            });
        }
    }

    if(wsAN.LOGOUT === action.type) { //发送信息
        closeCosket();
        //清空历史数据
        next({
            type:wsAN.RESET_STATE
        });
    }

    next(action)
}

export default webSocketMiddleware