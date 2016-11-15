import React, { Component } from 'react';
import { connect } from 'react-redux';

//组件
import { Banner, RankPanel } from '../components';

//actions
import { appAct, fetchData, appAN } from '../actions';

import { REQURL } from '../config';

const rankExpPic = require('../../images/rank_exp.jpg');
const rankRichPic = require('../../images/rank_rich.jpg');

class Rank extends Component {

    componentWillMount() {
        //加载数据
        const {dispatch} = this.props;
        //获取排行榜数据
        dispatch(fetchData({
            url : REQURL.getVData.url,
            requestType : REQURL.getVData.type,
            requestModel : REQURL.getVData.model,
            successAction: appAN.UPDATE_RANK_LISTS
        }));
    }

    shouldComponentUpdate(nextProps,nextState) {
        if(this.props != nextProps) {
            return true
        }
        else {
            return false
        }
    }

    render() {
        let { richLists, expLists, dispatch } = this.props;

        return (
            <div className="app-main-content">
                <Banner title="排行" />
                <div className="appContent rank">
                    <RankPanel
                        iconSrc={rankExpPic}
                        link="/rankExp"
                        data={expLists}
                        />

                    <RankPanel
                        iconSrc={rankRichPic}
                        link="/rankRich"
                        data={richLists}
                        />
                </div>
            </div>
        );
    }

}

const mapStateToProps = (state) => {
    const expLists = state.appState.expLists.day.slice(0, 3);
    const richLists = state.appState.richLists.day.slice(0, 3);
    return {
        rankSlideIndex: state.appState.rankSlideIndex,
        expLists: expLists,
        richLists: richLists
    }
}

export default connect(mapStateToProps)(Rank);
