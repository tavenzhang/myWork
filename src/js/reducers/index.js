
import { combineReducers, createStore, applyMiddleware, compose } from 'redux';
import { routerReducer, routerMiddleware } from 'react-router-redux';
//import thunk from 'redux-thunk';
import fetchMiddleware from './../middleware/fetch';
import webSocketMiddleware from './../middleware/socket';


//import appState from './app';
import appState from './app';
import msgState from './msg';
import fetchState from './fetch';
import wsState from './socket';

/**
 * 所有中间件
 */
let middleware = applyMiddleware(fetchMiddleware,webSocketMiddleware);

/**
 * 所有reducer
 */
let rootReducer = combineReducers({
    appState,
    msgState,
    fetchState,
    wsState,
    routing: routerReducer
});

//debug
//if (module.hot) {
    const devToolsExtension = window.devToolsExtension;

    if (typeof devToolsExtension === 'function') {
        middleware = compose(middleware, devToolsExtension())
    }
//}

//const store = createStore(
//    rootReducer,
//    middleware
//);

export default function configureStore(preloadedState = {}) {
    const store = createStore(
        rootReducer,
        preloadedState,
        middleware
    );

    return store
}
