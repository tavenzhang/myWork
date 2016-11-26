/**
 * Created by soga on 16/9/25.
 */
import React, { Component } from 'react';
import { connect } from 'react-redux';

import { Banner, RankDetailPanel, SwipeableViews, Tabs, Tab } from '../components';

//actions
import { appAct, fetchData, appAN } from '../actions';
import { REQURL } from '../config';

class RankGame extends Component {

    componentWillMount() {
        //加载数据
        const {dispatch,gameLists} = this.props;
        //如果状态基中没有排行榜数据的话，再次请求接口
        //获取排行榜数据
        if(gameLists.total.length == 0) {
            dispatch(fetchData({
                url : REQURL.getVData.url,
                requestType : REQURL.getVData.type,
                requestModel : REQURL.getVData.model,
                successAction: appAN.UPDATE_RANK_LISTS
            }));
        }
    }

    render() {

        let { rankSlideIndex, gameLists, dispatch } = this.props;

        return (
            <div className="app-main-content">
                <Banner title="赌圣排行" back={true} />
                <div className="appContent rank">
                    <Tabs
                        onChange={ e =>{ dispatch(appAct.setRankTabIndex(e)) }}
                        value={ rankSlideIndex }
                        className="tab"
                        >
                        <Tab label="日榜" value={0} className={ rankSlideIndex == 0 ? 'tab-selected' : ''} />
                        <Tab label="周榜" value={1} className={ rankSlideIndex == 1 ? 'tab-selected' : ''} />
                        <Tab label="月榜" value={2} className={ rankSlideIndex == 2 ? 'tab-selected' : ''} />
                        <Tab label="总榜" value={3} className={ rankSlideIndex == 3 ? 'tab-selected' : ''} />
                    </Tabs>
                    <SwipeableViews
                        index={ rankSlideIndex }
                        onChangeIndex={ e =>{ dispatch(appAct.setRankTabIndex(e)) } }
                        className="swipSubPage"
                        >
                        <RankDetailPanel data={gameLists.day} type="rich" />
                        <RankDetailPanel data={gameLists.week} type="rich" />
                        <RankDetailPanel data={gameLists.month} type="rich" />
                        <RankDetailPanel data={gameLists.total} type="rich" />
                    </SwipeableViews>
                </div>
            </div>
        );
    }

}

const mapStateToProps = (state) => {
    return {
        rankSlideIndex: state.appState.rankSlideIndex,
        gameLists: state.appState.gameLists
    }
}

export default connect(mapStateToProps)(RankGame);