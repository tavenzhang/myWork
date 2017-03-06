import Message from '../utils/Message';
import Gift from '../utils/Gift';

import { msgAN } from '../actions/msg';

const initMessageState = {
    conversation: [],
    status: false
}

//最后一条消息
//const lastAction = ( state = null, action ) => {
//    return action;
//}


//消息列表
//type: 0 文字信息，1 礼物
const msgState = (state = initMessageState, action) => {
    switch (action.type) {
        case msgAN.POST_MESSAGE:
            return Object.assign({}, state, {
                conversation: [
                    ...state.conversation,
                    {
                        text: new Message(action.text),
                        id: action.id,
                        isSelf: 1, //自己
                        type: 0
                    }
                ]
            });

        case msgAN.RECEIVE_MESSAGE:
            return Object.assign({}, state, {
                conversation: [
                    ...state.conversation,
                    {
                        text: new Message(action.message),
                        id: action.id,
                        isSelf: 0, //别人
                        type: 0
                    }
                ]
            });
        // {
        //     text: action.text,
        //     id: action.id,
        //     type: 1 //别人
        // }

        case msgAN.SEND_GIFT:
            return Object.assign({}, state, {
                conversation: [
                    ...state.conversation,
                    {
                        text: new Gift(action.giftId),
                        id: action.id,
                        isSelf: 1,
                        type: 1
                    }
                ]
            });

        case msgAN.CONNECT:
            return {
                conversation: [],
                status: true
            }

        case msgAN.DISCONNECT:
            return {
                conversation: [],
                status: false
            }

        default:
            return state;
    }
}

export default msgState;