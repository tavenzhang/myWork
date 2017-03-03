/**
 * Created by soga on 16/9/19.
 */

const hostname = location.hostname;
const protocol = location.protocol;
const mainpath = hostname.substr(hostname.indexOf("."));


let serverADR = "";
let vSever = protocol + "//v" + mainpath;
let pSever = protocol + "//p" + mainpath + "/";

// serverADR = "http://www.taven.com:9000";
// vSever = "http://v.taven.com:9000";
// pSever = "http://p.taven.com:9000/";
if( process.env.NODE_ENV == 'development') {//开发环境
    //serverADR = "http://192.16.137.3";
    // serverADR = "http://www.mm.com";
    // vSever = "http://v.m-front.com";
    // pSever = "http://138.68.15.251/";
    serverADR = "http://www.thomas.com:8000";
    vSever = "http://v.thomas.com:8000";
    pSever = "http://p.thomas.com:8000/";
}

export const SERVERADDR = serverADR;

//接口配置
export const REQURL = {
    getVideoAll         : { url : SERVERADDR + "/videolistall.json?t="+(new Date()).valueOf(), type : 'GET'},//大厅全部数据
    getVideoRec         : { url : SERVERADDR + "/videolistrec.json?t="+(new Date()).valueOf(), type : 'GET'},//今日之星数据
    getVideoSls         : { url : SERVERADDR + "/videolistsls.json?t="+(new Date()).valueOf(), type : 'GET'},//大秀场数据
    getVideoOrd         : { url : SERVERADDR + "/videolistord.json?t="+(new Date()).valueOf(), type : 'GET'},//一对一数据
    getUserInfo         : { url : SERVERADDR + "/indexinfo", type : 'GET'},//用户数据
    getMyRecord         : { url : SERVERADDR + "/member/consumerd?type=json", type : 'GET'},//获取我的消费记录
    getMyMsg            : { url : SERVERADDR + "/member/msglist?type=json", type : 'GET'},//获取我的消息记录
    getMyMount          : { url : SERVERADDR + "/member/scene?type=json", type : 'GET'},//获取我的道具
    equipMount          : { url : SERVERADDR + "/member/scene", type : 'GET'},//装配坐骑
    cancelMount         : { url : SERVERADDR + "/member/cancelscene?type=json", type : 'GET'},//取消坐骑
    login               : { url : SERVERADDR + "/login", type : 'POST'},//登录
    logout              : { url : SERVERADDR + "/logout?type=json", type : 'POST'},//退出
    getShops            : { url : SERVERADDR + "/shop?type=json", type : 'GET'},//获取商品信息
    register            : { url : SERVERADDR + "/reg", type : 'POST'},//注册
    getActivity         : { url : SERVERADDR + "/act?type=json", type : 'GET'},//获取活动信息
    getActivityDetail   : { url : SERVERADDR + "/nac/", type : 'GET'},//获取活动详细信息
    getUid              : { url : SERVERADDR + "/getUid", type : 'GET'},//获取用户id
    payMount            : { url : SERVERADDR + "/member/pay", type : 'POST'},//购买坐骑
    getVIPMount         : { url : SERVERADDR + "/getvipmount", type : 'POST'},//领取VIP坐骑
    openVIP             : { url : SERVERADDR + "/openvip", type : 'GET'},//开通vip
    reSetPassword       : { url : SERVERADDR + "/member/password", type : 'POST'},//重置密码
    editUserInfo        : { url : SERVERADDR + "/member/edituserinfo", type : 'POST'},//编辑个人信息
    search              : { url : SERVERADDR + "/find", type : 'GET'},//编辑个人信息
    checkroompwd        : { url : SERVERADDR + "/checkroompwd", type : 'POST'},//密码房密码验证
    chargeCheck         : { url : SERVERADDR + "/charge/checkCharge", type : 'POST'},//
    chargePay           : { url : SERVERADDR + "/charge/pay", type : 'POST'},//
    dateTimeRoom        : { url : SERVERADDR + "/member/doReservation", type : 'GET'},//预约房间


    getVData            : { url : vSever + "/video_gs/rank/data_ajax", type : 'GET', model : 'jsonp'},//获取排行榜相关数据
    getGifts            : { url : vSever + "/video_gs/conf", type : 'GET', model : 'jsonp'},//获取礼物数据
    getSendGiftsLists   : { url : vSever + "/video_gs/rank/list_gift", type : 'GET', model : 'jsonp'},//获取礼物清单
    socketAddr          : { url : vSever + "/video_gs/mobileServer", type : 'GET', model : 'jsonp'},//获取socket地址


};

//基本配置
export const CONFIG = {
    imageServe : pSever,
    giftPath : "/flash/image/gift_material/",
    //imageServe : "http://p.lgfxiu.com/"
};


//socket配置
export const SOCKET = {
    //host : "138.68.15.251",
    ////host : "192.168.5.196",
    //ports : {//一般请求：20036  聊天：20037  送礼：20038
    //  common : 10016,
    //  chat : 10017,
    //  gift : 10018
    //},
    AES_IV : "0102030405060708",// AES密匙偏移量
    WS_SECTRITY : '35467ug$#6ighegw',//AES加密密匙,通用socket
    WSCHAT_SECTRITY : '985tj@48hgi95353',//AES加密密匙,聊天
    WSGIFT_SECTRITY : '58it^43(&#gig&*7jj'//AES加密密匙,礼物
};
