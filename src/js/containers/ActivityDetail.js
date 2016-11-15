import React, { Component } from "react";
import { connect } from 'react-redux';

import { Banner } from '../components';

import { appAct, fetchData, appAN } from '../actions';

import { REQURL } from '../config';

class ActivityDetail extends Component{

	componentWillMount() {
		//加载数据
		const {dispatch,params} = this.props;
		//dispatch(appAct.updateActivityLists(activityList));
		dispatch(fetchData({
			url : REQURL.getActivityDetail.url + params.id + "?type=json",
			requestType : REQURL.getActivityDetail.type
			//successAction: appAN.UPDATE_ACTIVITY_LISTS
		}));
	}

	render(){

		return (
            <div className="app-main-content">
                <Banner
                    title="活动详情"
                    back={true}
                    />
                <div className="appContent">
				</div>
			</div>
		);
	}
}


const mapStateToProps = state => {
	return {
		activityList: state.appState.activityList
	}
};

export default connect(mapStateToProps)(ActivityDetail);