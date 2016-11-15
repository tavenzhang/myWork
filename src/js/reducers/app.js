/**
 * Created by soga on 16/9/16.
 */

import { appAN } from './../actions/app';

const initAppState = {
    isLogin         : false,//是否登陆
    uid             : 0,//用户id
    currSeleRoomId  : 0,//当前选中的房间id
    dialogOpen      : false, //弹出框是否开启
    myRecord        : [],//我的消费记录
    myMsg           : [],//我的消息
    myMount         : [],//我的道具
    userInfo        : { //用户信息
        nickname: "您是游客，请登录兰桂坊~~",
    },
    infoBox : {
        show : false, //是否显示
        msg  : "",//显示内容
        style: 'success'//success成功，error错误
    },
    menuSelectIndex : 0,//菜单选择项
    shopSelectIndex : 0,//商户选择项
    activityList    : [], //活动列表
    searchVideoLists: [], //查询视频列表
    drawerOpen      : false, //侧边菜单框
    giftDialogIsOpen: false, //礼物弹出框
    giftList        : [], //礼物列表
    homeSlideIndex  : 0,//主页tab选中项
    videoSlideIndex : 0,//房间tab选择项
    videoListsAll   : [], //主页大厅视频数据
    videoListsRec   : [], //主页今日精选视频数据
    videoListsSls   : [], //主页大秀场视频数据
    videoListsOrd   : [], //主页一对一视频数据
    myFav           : [],//我的关注
    myRes           : [],//我的预约
    rankSlideIndex  : 0,//榜单tab选中项
    expLists        : {  //主播排行数据
        day: [],
        week: [],
        month: [],
        total: []
    },
    richLists        : {  //富豪排行数据
        day: [],
        week: [],
        month: [],
        total: []
    },
    mounts: [],//坐骑
    vipmount: [],//贵族坐骑
    vipIcons: [],//贵族勋章
    shopSelectItem: {}//商店当前选中的产品
};

//过滤一些主播的数据
const filterUserData = data => {
    let newDatas = [];
    //console.log(data)
    data.rooms.map((d,i)=>{
        let nd = {
            username : d.username,//主播名字
            headimg : d.headimg,//头像地址
            live_status : d.live_status,//直播状态
            total : d.total,//房间在线人数
            enterRoomlimit : d.enterRoomlimit,//限制房间
            tid : d.tid,//
            uid : d.uid//主播id
        }
        newDatas.push(nd);
    })
    return newDatas;
}

//过滤我的记录字段
const filterMyRecord = data => {
    let newDatas = [];
    //console.log(data)
    data.map((d,i)=>{
        let nd = {
            gid : d.gid,//礼物id
            name : d.goods.name,//礼物名
            gnum : d.gnum,//礼物数量
            points : d.points,//礼物价格
            cr_time : d.goods.create_time//送出时间
        }
        newDatas.push(nd);
    })
    return newDatas;
}

//过滤我的道具字段
const filterMyMount = data => {
    let newDatas = [];
    //console.log(data)
    data.data.data.map((d,i)=>{
        let nd = {
            gid : d.gid,//礼物id
            expires : d.expires,//过期时间
            name : d.mount_group.name,//道具名称
            desc : d.mount_group.desc,//道具描述
            equip : data.equip,//装配
        }
        newDatas.push(nd);
    })
    return newDatas;
}

const appState = (state = initAppState, action) => {
    switch (action.type){
        case appAN.UPDATE_ACTIVITY_LISTS:
            return Object.assign({}, state, {
                activityList : action.data
            });

        case appAN.SEARCH_VIDEO:
            return Object.assign({}, state, {
                searchVideoLists : action.data.data
            });

        case appAN.OPEN_GIFT_DIALOG:
        case appAN.CLOSE_GIFT_DIALOG:
            return Object.assign({}, state, {
                giftDialogIsOpen: action.giftDialogIsOpen
            });

        case appAN.UPDATE_GIFT_LIST:
            return Object.assign({}, state, {
                giftList: action.giftList
            });

        case appAN.SWITCH_MENU_TAB_INDEX:
            return Object.assign({}, state, {
                menuSelectIndex: action.slideIndex
            });

        case appAN.SWITCH_HOME_TAB_INDEX:
            return Object.assign({}, state, {
                homeSlideIndex: action.slideIndex
            });

        case appAN.SWITCH_VIDEO_TAB_INDEX:
            return Object.assign({}, state, {
                videoSlideIndex: action.slideIndex
            });

        case appAN.SWITCH_SHOP_TAB_INDEX:
            return Object.assign({}, state, {
                shopSelectIndex: action.slideIndex
            });

        case appAN.UPDATE_VIDEO_LISTS_ALL:
            return Object.assign({}, state, {
                videoListsAll: filterUserData(action.data)
            });

        case appAN.UPDATE_VIDEO_LISTS_REC:
            return Object.assign({}, state, {
                videoListsRec: filterUserData(action.data)
            });

        case appAN.UPDATE_VIDEO_LISTS_SLS:
            return Object.assign({}, state, {
                videoListsSls: filterUserData(action.data)
            });

        case appAN.UPDATE_VIDEO_LISTS_ORD:
            return Object.assign({}, state, {
                videoListsOrd: filterUserData(action.data)
            });

        case appAN.SWITCH_RANK_TAB_INDEX:
            return Object.assign({}, state, {
                rankSlideIndex: action.slideIndex
            });

        case appAN.UPDATE_SHOPS:
            return Object.assign({}, state, {
                mounts: action.data.lists,//坐骑
                vipmount: action.data.vipmount,//贵族坐骑
                vipIcons: action.data.group//贵族勋章
            });

        case appAN.UPDATE_RANK_LISTS:
            return Object.assign({}, state, {
                expLists: {
                    day: action.data.rank_exp_day,
                    week: action.data.rank_exp_week,
                    month: action.data.rank_exp_month,
                    total: action.data.rank_exp_his
                },
                richLists: {
                    day: action.data.rank_rich_day,
                    week: action.data.rank_rich_week,
                    month: action.data.rank_rich_month,
                    total: action.data.rank_rich_his
                }
            });

        case appAN.LOGIN:
            return Object.assign({}, state, {
                isLogin: true
            });

        case appAN.UPDATE_UID:
            return Object.assign({}, state, {
                uid: action.uid
            });

        case appAN.LOGOUT:
            return Object.assign({}, state, {
                isLogin: false,
                userInfo        : { //用户信息
                    nickname: "您是游客，请登录兰桂坊~~",
                    uid     : 0
                },
            });

        case appAN.SHOW_INFOBOX:
            return Object.assign({}, state, {
                infoBox: {
                    show : true,
                    msg  : action.msg,
                    style : action.style
                }
            });

        case appAN.CLOSE_INFOBOX:
            return Object.assign({}, state, {
                infoBox: {
                    show : false,
                    msg  : '',
                    style : ''
                }
            });

        case appAN.UPDATE_USERINFO:
            return Object.assign({}, state, {
                userInfo : action.data.info,
                myFav    : action.data.myfav,
                myRes    : action.data.myres
            });

        case appAN.UPDATE_DIALODSTATUS:
            return Object.assign({}, state, {
                dialogOpen : action.status
            });

        case appAN.UPDATE_SHOPSELECT:
            return Object.assign({}, state, {
                shopSelectItem : action.data
            });

        case appAN.UPDATE_MYRECORD:
            return Object.assign({}, state, {
                myRecord : filterMyRecord(action.data.data.data)
            });

        case appAN.UPDATE_MYMSG:
            return Object.assign({}, state, {
                myMsg : action.data.data
            });

        case appAN.UPDATE_MYMOUNT:
            return Object.assign({}, state, {
                myMount : filterMyMount(action.data)
            });

        case appAN.UPDATE_CURRSELEROOMID:
            return Object.assign({}, state, {
                currSeleRoomId : action.roomid
            });

        case appAN.EDIT_USERINFO:
            let users = state.userInfo;
            users.name = action.data.nickname;
            users.description = action.data.description;
            return Object.assign({}, state, {
                userInfo : users
            });

        default:
            return state;
    }
}

export default appState;