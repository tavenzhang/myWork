/**
 * Created by soga on 16/9/21.
 */

import { wsAN } from '../actions/socket';
import { dd } from '../utils/util';

const initSockState = {
    socketConnect  : false,//是否链接socket服务
    moneyTotal     : 0,//主播本日总计砖石数
    hoster         : {
        name : "主播还未进入房间"
    },//主播信息
    showVideo      : true,//是否显示视频框
    userMount      : {},//有坐骑的用户进入
    audiences      : [],//观众列表数据
    admins         : [],//管理员
    messages       : [],//聊天信息
    todayGifts     : [],//当日礼物贡献
    historyGifts   : [],//历史礼物贡献
    roomMsg        : [],//房间信息（包含系统消息）
    openGiftDialog : false,//是否开启礼物弹出框
    videoUrls      : [],//主播下播地址
    seleVideoSrc   : [],//当前选择的主播资源地址
    currentSeleGift: 0,//当前选中的礼物值
    slideGiftIndex : 0,//礼物选择项
    alertDialog    : {
        show : false,
        content : null,//警告内容
        title: "系统提示",
        type : 1, //1=普通警告弹出框，9=登录提示弹出框,5=无操作提醒框,6动态内容窗口
    },//弹出框
    sendGifts      : {},//送出的礼物
    gifts          : [],//礼物数据
    sendGiftsLists : [],//礼物清单数据
    isVisitable:true  //是否可以访问当前房间
};

//过滤送礼数据
const filterGiftSend = (his,data) => {
    if(his.length >= 6) {
        his.shift();
    }
    return [...his,data];
}

//更新今日贡献数据
const updatTodayGifts = (his,data) => {
    //判断data是对象还是数组
    if(data instanceof Array) {
        return data;
    }
    else {
        if(his.length == 0) {
            return [...his,data];
        }
        else {
            //先判断新增量是否在元数据中存在，存在的话更新值，不存在的话在追加
            let isIndata = false;//数据在是否在历史记录中
            his.map((v,i)=>{
                if(v.uid == data.uid) {
                    isIndata = true;
                    v.score = data.score;//重新赋值
                }
            });

            if(!isIndata) {
                his.push(data);
            }

            let len = his.length;

            // 冒泡排序
            for (let i = 0; i < len - 1; i++) {
                let tmp = his[i];
                for (var j = i + 1; j < len; j++) {
                    if (his[i].score < his[j].score) {
                        let newData = his[i];
                        his[i] = his[j];
                        his[j] = newData;
                    }
                }
            }
            return [...his];
        }

    }
};

const wsState = (state = initSockState, action) => {
    switch (action.type) {

        case wsAN.USER_LEAVES_ROOM:
            if(action.data.ruled == 2 || action.data.ruled == 3) {//主播或者管理员
                return Object.assign({}, state, {
                    admins: state.admins.filter(user => user.uid !== action.data.uid)
                });
            }
            else {//观众
                return Object.assign({}, state, {
                    audiences: state.audiences.filter(user => user.uid !== action.data.uid)
                });
            }
        case wsAN.USER_JOINS_ROOM:

            let userMount = {}; //带坐骑用户

            if(action.data.car) {//是否有坐骑
                userMount = action.data;
            }

            if(state.messages)
            {
                while(state.messages.length>25)
                {
                    state.messages.shift();
                }
            }
            if(action.data.ruled == 2 || action.data.ruled == 3) {//主播或者管理员
                return Object.assign({}, state, {
                    admins: [...state.audiences, action.data],
                    messages: [...state.messages, action.data],
                    userMount: userMount
                });
            }
            else {//观众
                return Object.assign({}, state, {
                    audiences: [...state.audiences, action.data],
                    messages: [...state.messages, action.data],
                    userMount: userMount
                });
            }

        case wsAN.CHAT_MESSAGE:
            if(state.messages)
            {
                while(state.messages.length>25)
                {
                    state.messages.shift();
                }
            }
            return Object.assign({}, state, {
                messages: [...state.messages, action.data]
            });

        case wsAN.GET_AUDIENCES:
            return Object.assign({}, state, {
                audiences: action.data
            });

        case wsAN.UPDATE_ROOMMSGS:
            return Object.assign({}, state, {
                roomMsg: [...state.roomMsg, action.data]
            });

        case wsAN.UPDATE_GIFTS:
            return Object.assign({}, state, {
                gifts: action.data
            });

        case wsAN.UPDATE_TODAYGIFTS:
            return Object.assign({}, state, {
                todayGifts: updatTodayGifts(state.todayGifts,action.data)
            });

        case wsAN.UPDATE_HISTORYGIFTS:
            return Object.assign({}, state, {
                historyGifts: action.data
            });

        //case wsAN.ADD_GIFTSDATA:
        //    return Object.assign({}, state, {
        //        todayGifts: updatTodayGifts(state.todayGifts,action.data)
        //    });

        case wsAN.OPEN_GIFTDIALOG:
            return Object.assign({}, state, {
                openGiftDialog: action.status
            });

        case wsAN.SWITCH_GIFT_TAB_INDEX:
            return Object.assign({}, state, {
                slideGiftIndex: action.slideIndex
            });

        case wsAN.UPDATE_VIDEOURLS:
            const urls = action.data.split(",");
            return Object.assign({}, state, {
                videoUrls: urls
            });

        case wsAN.ADD_ADMIN:
            return Object.assign({}, state, {
                audiences: state.audiences.filter(user => user.uid !== action.data.uid),
                admins: [...state.admins, action.data]
            });

        case wsAN.DELETE_ADMIN:
            return Object.assign({}, state, {
                audiences: [...state.audiences, action.data],
                admins: state.admins.filter(user => user.uid !== action.data.uid)
            });

        case wsAN.UPDATE_ADMINS:
            return Object.assign({}, state, {
                admins: action.data
            });

        case wsAN.SET_SELEGIFT:
            return Object.assign({}, state, {
                currentSeleGift: action.data
            });

        case wsAN.UPDATE_HOSTER:
            return Object.assign({}, state, {
                hoster: action.data
            });

        case wsAN.SHOW_ALERTDIALOG:
            return Object.assign({}, state, {
                alertDialog : {
                    show : action.status,
                    content : action.content,//警告内容
                    title : action.title,//警告内容
                    type : action.dialogType, //1=普通警告弹出框，9=登录提示弹出框
                },
            });

        case wsAN.RESET_STATE:
            return Object.assign({}, state, initSockState);

        case wsAN.SOCKET_SUCCESS:
            return Object.assign({}, state, {
                socketConnect : true
            });

        case wsAN.SEND_GIFTEFFECT:
            return Object.assign({}, state, {
                //sendGifts : filterGiftSend(state.sendGifts,action.data)
                sendGifts : action.data
            });

        case wsAN.UPDATE_VIDEOURL:
            return Object.assign({}, state, {
                seleVideoSrc : action.data
            });

        case wsAN.SHOW_VIDEO:
            return Object.assign({}, state, {
                showVideo : action.value
            });

        case wsAN.CLOSE_VIDEO:
            return Object.assign({}, state, {
                seleVideoSrc : []
            });

        case wsAN.UPDATE_MONEYTOTAL:
            return Object.assign({}, state, {
                moneyTotal : action.data
            });

        case wsAN.UPDATE_SENDGIFTLISTS:
            return Object.assign({}, state, {
                sendGiftsLists : [...action.data,...state.sendGiftsLists]
            });
        case wsAN.GOTO_HOME:
            return {...state,isVisitable:action.data};
        default:
            return state;
    }
}

export default wsState

