/**
 * Created by soga on 16/9/21.
 */

//import WSInstance from './../utils/WS';

export const wsAN  = {
    USER_LEAVES_ROOM     : 'ws/USER_LEAVES_ROOM',
    USER_JOINS_ROOM      : 'ws/USER_JOINS_ROOM',//用户进房间
    CHAT_MESSAGE         : 'ws/CHAT_MESSAGE',
    SEND_MESSAGE         : 'ws/SEND_MESSAGE',//发送聊天信息
    SEND_GIFT            : 'ws/SEND_GIFT',//发送礼物
    GET_AUDIENCES        : 'ws/GET_AUDIENCES',//获取观众列表
    LOGOUT               : 'ws/LOGOUT',
    UPDATE_ROOMMSGS      : 'ws/UPDATE_ROOMMSGS',//房间信息
    CONNECT              : 'ws/CONNECT',
    UPDATE_GIFTS         : 'ws/UPDATE_GIFTS',//获取礼物数据
    UPDATE_TODAYGIFTS    : 'ws/UPDATE_TODAYGIFTS',//获取当日贡献
    UPDATE_HISTORYGIFTS  : 'ws/UPDATE_HISTORYGIFTS',//获取历史贡献
    ADD_GIFTSDATA        : 'ws/ADD_GIFTSDATA',//增量更新贡献数据
    OPEN_GIFTDIALOG      : 'ws/OPEN_GIFTDIALOG',//是否打开送礼弹出框
    SWITCH_GIFT_TAB_INDEX: 'ws/SWITCH_GIFT_TAB_INDEX',//选择tab选项值
    UPDATE_VIDEOURLS     : 'ws/UPDATE_VIDEOURLS',//更新主播下播地址
    ADD_ADMIN            : 'ws/ADD_ADMIN',//新增管理员
    DELETE_ADMIN         : 'ws/DELETE_ADMIN',//删除管理员
    UPDATE_ADMINS        : 'ws/UPDATE_ADMINS',//更新管理员列表
    SET_SELEGIFT         : 'ws/SET_SELEGIFT',//设置当前选中的礼物值
    UPDATE_HOSTER        : 'ws/UPDATE_HOSTER',//更新主播信息
    SHOW_ALERTDIALOG     : 'ws/SHOW_ALERTDIALOG',//显示弹出框
    RESET_STATE          : 'ws/RESET_STATE',//初始化状态基
    SOCKET_SUCCESS       : 'ws/SOCKET_SUCCESS',//设置socket链接状态
    SEND_GIFTEFFECT      : 'ws/SEND_GIFTEFFECT',//送礼效果
    GET_VIDEOURL         : 'ws/GET_VIDEOURL',
    UPDATE_VIDEOURL      : 'ws/UPDATE_VIDEOURL',//更新最新选择的url信息
    SHOW_VIDEO           : 'ws/SHOW_VIDEO',//显示视频
    CLOSE_VIDEO          : 'ws/CLOSE_VIDEO',//断开视频流
    UPDATE_MONEYTOTAL    : 'ws/UPDATE_MONEYTOTAL',//总计砖石数
    UPDATE_SENDGIFTLISTS : 'ws/UPDATE_SENDGIFTLISTS',//礼物清单数据
    HEART                : 'ws/HEART',//心跳
};

export const wsAct = {
    //连接
    //extck是聊天，送礼要的字段，根据第一次socket返回的值
    connect : (uri, data) => ({
        type: wsAN.CONNECT,
        uri,
        data
    }),
    //断开连接
    logout : () => ({
        type: wsAN.LOGOUT
    }),
    //接受信息
    receiveMessage : message => ({
        type: wsAN.RECEIVE_MESSAGE,
        message
    }),
    //发送信息
    postMessage : data => ({
        type: wsAN.SEND_MESSAGE,
        data
    }),

    //送礼物
    sendGift : data => ({
        type: wsAN.SEND_GIFT,
        data
    }),

    //是否打开礼物弹框
    openGiftDialog : status => ({
        type: wsAN.OPEN_GIFTDIALOG,
        status
    }),

    //设置礼物tab选择键
    setGiftTabIndex : slideIndex => ({
        type: wsAN.SWITCH_GIFT_TAB_INDEX,
        slideIndex
    }),

    //设置当前选中的礼物值
    setSeleGift : data => ({
        type: wsAN.SET_SELEGIFT,
        data
    }),

    //获取直播地址
    getVideoUrl : url => ({
        type: wsAN.GET_VIDEOURL,
        url
    }),

    //显示视频
    showVideo : value => ({
        type: wsAN.SHOW_VIDEO,
        value
    }),

    resetWsState : () => ({
       type: wsAN.RESET_STATE
    }),

    //显示警告框，默认普通错误提示
    showAlertDialog : (status,content,dialogType=1) => ({
        type: wsAN.SHOW_ALERTDIALOG,
        status,
        content,
        dialogType
    }),

    heart : wsType => ({
        type: wsAN.HEART,
        wsType,
    })
};
