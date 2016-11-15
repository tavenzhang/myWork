/**
 * Created by soga on 16/9/25.
 */
import React, { Component } from 'react';
import { connect } from 'react-redux';

import { Banner, RankDetailPanel, Tabs, Tab, SwipeableViews } from '../components';

//actions
import { appAct, fetchData, appAN } from '../actions';
import { REQURL } from '../config';

class RankExp extends Component {

    componentWillMount() {
        //加载数据
        const {dispatch,expLists} = this.props;
        //如果状态基中没有排行榜数据的话，再次请求接口
        //获取排行榜数据
        if(expLists.total.length == 0) {
            dispatch(fetchData({
                url : REQURL.getVData.url,
                requestType : REQURL.getVData.type,
                requestModel : REQURL.getVData.model,
                successAction: appAN.UPDATE_RANK_LISTS
            }));
        }
    }

    render() {

        let { rankSlideIndex, expLists, dispatch } = this.props;

        return (
            <div className="app-main-content">
                <Banner title="主播排行" back={true} />
                <div className="appContent rank">
                    <Tabs
                        onChange={ e =>{ dispatch(appAct.setRankTabIndex(e)) }}
                        value={ rankSlideIndex }
                        className="tab"
                        //animateHeight={true}
                        >
                        <Tab label="日榜" value={0} />
                        <Tab label="周榜" value={1} />
                        <Tab label="月榜" value={2} />
                        <Tab label="总榜" value={3} />
                    </Tabs>
                    <SwipeableViews
                        index={ rankSlideIndex }
                        onChangeIndex={ e =>{ dispatch(appAct.setRankTabIndex(e)) } }
                        className="swipSubPage"
                        >
                        <RankDetailPanel data={expLists.day} type="exp" key={0} />
                        <RankDetailPanel data={expLists.week} type="exp" key={1} />
                        <RankDetailPanel data={expLists.month} type="exp" key={2} />
                        <RankDetailPanel data={expLists.total} type="exp" key={3} />
                    </SwipeableViews>
                </div>
            </div>
        );
    }

}

const mapStateToProps = (state) => {
    return {
        rankSlideIndex: state.appState.rankSlideIndex,
        expLists: state.appState.expLists
    }
}

export default connect(mapStateToProps)(RankExp);