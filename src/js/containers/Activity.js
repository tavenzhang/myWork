import React, { Component } from "react";
import { connect } from 'react-redux';
import { Link } from 'react-router';

import { Banner, ActivityPanel } from '../components';


//actions
import { appAct, fetchData, appAN } from '../actions';

import { REQURL } from '../config';

class Activity extends Component{

    componentWillMount() {
        //加载数据
        const {dispatch,activityList} = this.props;
        if(!activityList.length) {
            dispatch(fetchData({
                url : REQURL.getActivity.url,
                requestType : REQURL.getActivity.type,
                successAction: appAN.UPDATE_ACTIVITY_LISTS
            }));
        }
    }

    render(){

        let { activityList } = this.props;
        let actContent = <div className="noContent">暂无活动~</div>;

        if(activityList.length) {
            actContent = <div className="activity-list">
                            {activityList.map((item, index) => (
                                <ActivityPanel key={index} data={item} />
                            ))}
                        </div>
        }

        return (
            <div className="app-main-content">
                <Banner title="活动中心" back={true} />
                <div className="appContent activity">
                    {actContent}
                </div>
            </div>
        );
    }
}

const mapStateToProps = state => {
    return {
        activityList: state.appState.activityList
    }
}

export default connect(mapStateToProps)(Activity);