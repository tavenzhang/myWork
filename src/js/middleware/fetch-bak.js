/**
 * Created by soga on 16/9/19.
 */
import fetch from 'isomorphic-fetch'
//import request from 'superagent'
import { fetchAN } from './../actions/fetch'
import { appAN } from './../actions/app'

const getData = url => {
    return fetch(url).then(response => response.json())
}

function fetchMiddleware(extraArgument) {
    return ({ dispatch, getState }) => next => action => {
        //console.log(new Date());
        //console.log(action.type);
        let requestType = action.requestType || 'POST';
        let requestData = action.requestData || {};
        if( action.type === fetchAN.FETCH_REQUEST ) {
            fetch(action.url, {
                    method: requestType,
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    },
                    body: requestData
                }
            ).then(response => response.json())
                .then(data => {
                    //更改请求状态
                    next({
                        type:fetchAN.FETCH_SUCCEED
                    });
                    //错误，显示错误信息
                    if(data && data.status == 0) {
                        next({
                            type:appAN.SHOW_INFOBOX,
                            msg:data.msg || "操作错误~",
                            style:'error'
                        })
                    }
                    else {
                        //设置数据
                        next({
                            type:action.successAction,
                            data:data
                        })
                    }
                })
                .catch(e => {
                    console.log("Oops, error", e);
                    next({
                        type:fetchAN.FETCH_FAILED
                    });
                    next({
                        type:appAN.SHOW_INFOBOX,
                        data:e || "请求错误~",
                        style:'error'
                    });
                })
        }

        if (typeof action === 'function') {

            return action(dispatch, getState, extraArgument);
        }

        return next(action);
    };
}

const fetchObject = fetchMiddleware();
fetchObject.withExtraArgument = fetchMiddleware;

export default fetchObject;
