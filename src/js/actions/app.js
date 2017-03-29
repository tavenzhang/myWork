export const appAN  = {
    UPDATE_ACTIVITY_LISTS : "app/UPDATE_ACTIVITY_LISTS",
    SEARCH_VIDEO          : "app/SEARCH_VIDEO",
    UPDATE_CURRSELEROOMID : "app/UPDATE_CURRSELEROOMID",
    TOGGLE_DRAWER         : "app/TOGGLE_DRAWER",
    CLOSE_DRAWER          : "app/CLOSE_DRAWER",
    CLOSE_GIFT_DIALOG     : "app/CLOSE_GIFT_DIALOG",
    UPDATE_MYRECORD       : "app/UPDATE_MYRECORD", //更新我的消费记录
    UPDATE_MYMSG          : "app/UPDATE_MYMSG", //更新我的消息
    UPDATE_MY_PRIVATE_MSG : "app/UPDATE_MY_PRIVATE_MSG", //更新我的私信
    UPDATE_MYMOUNT        : "app/UPDATE_MYMOUNT", //更新我的道具
    OPEN_GIFT_DIALOG      : "app/OPEN_GIFT_DIALOG",
    UPDATE_GIFT_LIST      : "app/UPDATE_GIFT_LIST",
    UPDATE_USERINFO       : "app/UPDATE_USERINFO",
    UPDATE_DIALODSTATUS   : "app/UPDATE_DIALODSTATUS",
    UPDATE_SHOPSELECT     : "app/UPDATE_SHOPSELECT",
    SWITCH_HOME_TAB_INDEX : "app/SWITCH_HOME_TAB_INDEX",
    SWITCH_MENU_TAB_INDEX : "app/SWITCH_MENU_TAB_INDEX",
    SWITCH_SHOP_TAB_INDEX : "app/SWITCH_SHOP_TAB_INDEX",
    UPDATE_VIDEO_LISTS_ALL: "app/UPDATE_VIDEO_LISTS_ALL",
    UPDATE_VIDEO_LISTS_REC: "app/UPDATE_VIDEO_LISTS_REC",
    UPDATE_VIDEO_LISTS_SLS: "app/UPDATE_VIDEO_LISTS_SLS",
    UPDATE_VIDEO_LISTS_ORD: "app/UPDATE_VIDEO_LISTS_ORD",
    SWITCH_RANK_TAB_INDEX : "app/SWITCH_RANK_TAB_INDEX",
    SWITCH_VIDEO_TAB_INDEX: "app/SWITCH_VIDEO_TAB_INDEX",
    UPDATE_RANK_LISTS     : "app/UPDATE_RANK_LISTS",
    UPDATE_SHOPS          : "app/UPDATE_SHOPS",
    SHOW_INFOBOX          : "app/SHOW_INFOBOX",
    CLOSE_INFOBOX         : "app/CLOSE_INFOBOX",
    UPDATE_UID            : "app/UPDATE_UID",
    UPDATE_PAY_METHOD     : "app/UPDATE_PAY_METHOD",
    UPDATE_CHARGE_PRICE   : "app/UPDATE_CHARGE_PRICE",
    SHOW_RECHARGE_DIALOG  : "app/SHOW_RECHARGE_DIALOG",
    SET_RECHARGE_ORDERID  : "app/SET_RECHARGE_ORDERID",
    EDIT_USERINFO         : "app/EDIT_USERINFO",//编辑用户信息
    LOGOUT                : "app/LOGOUT",
    LOGIN                 : "app/LOGIN"
};

export const appAct = {
    //更新活动列表
    updateActivityLists : activityList => ({
        type: appAN.UPDATE_ACTIVITY_LISTS,
        activityList
    }),

    //查询视频
    searchVideos : videos => ({
        type: appAN.SEARCH_VIDEO,
        searchVideoLists
    }),

    //drawer toggle
    drawerToggle : isOpen => ({
        type: appAN.TOGGLE_DRAWER,
        isOpen
    }),

    //drawer close
    drawerClose : () => ({
        type: appAN.CLOSE_DRAWER
    }),

    //打开礼物对话框
    openGiftDialog : () => ({
        type: appAN.OPEN_GIFT_DIALOG,
        giftDialogIsOpen: true
    }),

    //gift dialog close
    closeGiftDialog : () => ({
        type: appAN.CLOSE_GIFT_DIALOG,
        giftDialogIsOpen: false
    }),

    //gift update list
    updateGiftList : giftList => ({
        type: appAN.UPDATE_GIFT_LIST,
        giftList
    }),

    updatePayMethod : data => ({
        type: appAN.UPDATE_PAY_METHOD,
        data
    }),

    updateChargePrice : price => ({
        type: appAN.UPDATE_CHARGE_PRICE,
        price
    }),

    showRechargeDialog : status => ({
        type: appAN.SHOW_RECHARGE_DIALOG,
        status
    }),

    //home tabs index
    setHomeTabIndex : slideIndex => ({
        type: appAN.SWITCH_HOME_TAB_INDEX,
        slideIndex
    }),

    //menu tabs index
    setMenuTabIndex : slideIndex => ({
        type: appAN.SWITCH_MENU_TAB_INDEX,
        slideIndex
    }),

    setRechargeOrderid : orderId => ({
        type: appAN.SET_RECHARGE_ORDERID,
        orderId
    }),

    //shop tabs index
    setShopTabIndex : slideIndex => ({
        type: appAN.SWITCH_SHOP_TAB_INDEX,
        slideIndex
    }),

    //home video lists
    //updateHomeVideoLists : videoLists => ({
    //    type: appAN.UPDATE_VIDEO_LISTS_ALL,
    //    videoLists
    //}),

    //rank tabs index
    setRankTabIndex : slideIndex => ({
        type: appAN.SWITCH_RANK_TAB_INDEX,
        slideIndex
    }),

    setVideoTabIndex : slideIndex => ({
        type: appAN.SWITCH_VIDEO_TAB_INDEX,
        slideIndex
    }),

    //更新排行榜数据
    updateRankAnchorLists : anchorLists => ({
        type: appAN.UPDATE_RANK_LISTS,
        anchorLists
    }),

    //登陆
    login : value => ({
        type: appAN.LOGIN,
        value
    }),

    //退出
    logout : () => ({
       type: appAN.LOGOUT
    }),

    //显示提示信息
    showInfoBox : (msg, style='success') => ({
        type: appAN.SHOW_INFOBOX,
        msg,
        style
    }),

    //关闭信息框
    closeInfoBox : () => ({
        type: appAN.CLOSE_INFOBOX,
    }),

    //更新用户id
    updateUID : uid => ({
        type: appAN.UPDATE_UID,
        uid
    }),

    //是弹出dialog
    openDialog : status => ({
        type: appAN.UPDATE_DIALODSTATUS,
        status
    }),

    //编辑用户信息
    editUserInfo : data => ({
       type: appAN.EDIT_USERINFO,
        data
    }),

    //是弹出dialog
    shopSelectGift : data => ({
        type: appAN.UPDATE_SHOPSELECT,
        data
    }),

    //设置当前选中的房间
    setCurrentSelectRoomId: roomid => ({
        type: appAN.UPDATE_CURRSELEROOMID,
        roomid: roomid
    })
};
