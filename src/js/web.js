import React from 'react';
import { render } from 'react-dom';
import { hashHistory, Router, Route } from 'react-router';
import { syncHistoryWithStore } from 'react-router-redux';
import { Provider } from 'react-redux';

import App from './containers/web/App'

//导入状态
import configureStore from './reducers';
const store = configureStore();

render(
	<Provider store={store}>
		<App />
	</Provider>,
    document.getElementById('root')
);

