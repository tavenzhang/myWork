import { fetchAN } from './../actions/fetch';

const initFetchState = {
    requesting : false,
    faild: false,
    success: true
}

const fetchState = (state = initFetchState, action) => {
    switch (action.type){
        case fetchAN.FETCH_REQUEST :
            return Object.assign({}, state, {
                requesting: true,
                faild: false,
                success: false
            });
        case fetchAN.FETCH_FAILED :
            return Object.assign({}, state, {
                requesting: false,
                faild: true,
                success: false
            });
        case fetchAN.FETCH_SUCCEED :
            return Object.assign({}, state, {
                requesting: false,
                faild: false,
                success: true
            });
        default:
            return state;
    }
}

export default fetchState;