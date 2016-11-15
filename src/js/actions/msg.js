export const msgAN  = {
    UPDATE_ACTIVITY_LISTS : "msg/POST_MESSAGE",
    RECEIVE_MESSAGE       : "msg/RECEIVE_MESSAGE",
    SEND_GIFT             : "msg/SEND_GIFT",
    CONNECT               : "msg/CONNECT",
    DISCONNECT            : "msg/DISCONNECT",
    nextChatId            : "msg/nextChatId"
};

//chat item 随机id
let nextChatId = 0;

export const msgAct = {
    //连接
    connect : () => ({
        type: msgAN.CONNECT
    }),

    //断开连接
    disconnect : () => ({
        type: msgAN.DISCONNECT
    }),

    //收
    receiveMessage : message => ({
        type: msgAN.RECEIVE_MESSAGE,
        id: nextChatId++,
        message
    }),

    //发
    postMessage : text => ({
        type: msgAN.POST_MESSAGE,
        id: nextChatId++,
        text
    }),

    //送礼 id为礼物id
    sendGift : giftId => ({
        type: msgAN.SEND_GIFT,
        id: nextChatId++,
        giftId
    })

};
