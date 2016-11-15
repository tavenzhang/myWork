import React from 'react';
import { render } from 'react-dom';
import { hashHistory, Router, Route } from 'react-router';
import { syncHistoryWithStore } from 'react-router-redux';
import { Provider } from 'react-redux';

//导入状态
import configureStore from './reducers';
const store = configureStore();
const history = syncHistoryWithStore(hashHistory, store);

//import routes
import routes from './routes';

render(
    <Provider store={store}>
        <Router history={history} routes={routes} />
    </Provider>,
    document.getElementById('app')
);
