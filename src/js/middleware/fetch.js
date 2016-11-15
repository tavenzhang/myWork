/**
 * Created by soga on 16/9/19.
 */
//import fetch from 'isomorphic-fetch'
import request from 'superagent'
import jsonp from 'superagent-jsonp'
//import { ajax } from '../utils/util'
import { fetchAN } from './../actions/fetch'
import { appAN } from './../actions/app'
import { log } from './../utils/util'

const getData = url => {
    return fetch(url).then(response => response.json())
}

function fetchMiddleware(extraArgument) {
    return ({ dispatch, getState }) => next => action => {
        let requestType = action.requestType || 'POST';
        let requestData = action.requestData || {};

        if( action.type === fetchAN.FETCH_REQUEST ) {

            if(action.requestModel == 'jsonp') {
                request(requestType, action.url)
                    .use(jsonp)
                    .query(requestData)
                    .end(function (e, res) {
                        //更改请求状态
                        next({
                            type:fetchAN.FETCH_SUCCEED
                        });
                        if(res) {
                            const data = res.body;
                            log('fetchjsonp',data);
                            //错误，显示错误信息
                            if((data && data.status == 0) || (data && data.ret == 0) ) {
                                next({
                                    type:appAN.SHOW_INFOBOX,
                                    msg:data.msg || "操作错误~",
                                    style:'error'
                                })
                            }
                            else {
                                //设置数据
                                if(action.successAction) {
                                    next({
                                        type:action.successAction,
                                        data:data
                                    })
                                }
                                //callback
                                if(action.callback) {
                                    action.callback(data)
                                }
                            }
                        }
                    });
            }else {
                request(requestType, action.url)
                    .withCredentials()
                    .query(requestData)
                    .end(function (e, res) {
                        if(res && res.ok) {
                            //const data = res.body;
                            const data = JSON.parse(res.text);
                            log('fetch',data);
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
                                if(action.successAction) {
                                    next({
                                        type:action.successAction,
                                        data:data
                                    })
                                }
                                //callback
                                if(action.callback) {
                                    action.callback(data)
                                }
                            }
                        }
                        else {

                            let errorMsg = "链接错误，请重新刷新页面~";
                            if(res && res.text) errorMsg = res.text;

                            next({
                                type:fetchAN.FETCH_FAILED
                            });
                            next({
                                type:appAN.SHOW_INFOBOX,
                                msg:errorMsg,
                                style:'error'
                            });
                        }
                    });
            }
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
