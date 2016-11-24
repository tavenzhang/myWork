import React, { Component } from "react";
import { connect } from 'react-redux';
import { Link } from 'react-router';

import { Banner, ActivityPanel } from '../components';


//actions
import { appAct, fetchData, appAN } from '../actions';

import FaAlignJustify from 'react-icons/lib/fa/bars';

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

        let { activityList, drawerOpen, dispatch } = this.props;
        let actContent = <div className="noContent"></div>;

        if(activityList.length) {
            actContent = <div className="activity-list">
                            {activityList.map((item, index) => (
                                <ActivityPanel key={index} data={item} />
                            ))}
                        </div>
        }

        return (
            <div className="app-main-content">
                <Banner
                    title="活动中心"
                    currentPath="/activity"
                    leftIcon={<FaAlignJustify className="menuIcon" />}
                    leftIconTouch={()=>dispatch(appAct.drawerToggle(!drawerOpen))}
                    drawerOpen={drawerOpen}
                    drawerClose={()=>dispatch(appAct.drawerClose())}
                    />
                <div className="appContent activity">
                    {actContent}
                </div>
            </div>
        );
    }
}

const mapStateToProps = state => {
    return {
        activityList: state.appState.activityList,
        drawerOpen: state.appState.drawerOpen,//菜单
    }
}

export default connect(mapStateToProps)(Activity);