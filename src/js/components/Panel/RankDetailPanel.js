/**
 * Created by soga on 16/9/25.
 */
import React, {Component,PropTypes} from 'react';
import RankListPanel from './RankListPanel';
//import Divider from 'material-ui/Divider';
import { CONFIG } from '../../config';

import Hourglass from 'react-icons/lib/fa/hourglass-2';

const rankTopsPic = require('../../../images/rank_top3.png');

class RankDetailPanel extends Component {

    static propTypes = {
        data : PropTypes.any.isRequired,
        type : PropTypes.string
    };

    static defaultProps = {
    };

    shouldComponentUpdate(nextProps,nextState) {
        if(this.props.data != nextProps.data) {
            return true
        }
        else {
            return false
        }
    }

    render() {
        const { data, type } = this.props;

        //没有排行榜数据
        if(data.length == 0) {
            return (
                <div className="noContent">
                    <Hourglass className="noContent-icon" />
                    <div>暂无相关内容！</div>
                </div>
            )
        }
        else {

            return (
                <div className="rankDetail">
                    <div className="rank-list">
                        {data.map(( anchor, index ) => {
                            let num = index + 1;

                            //等级icon
                            let lvIcon = null;
                            if(type == 'exp') {//主播排行
                                lvIcon = `hotListImg AnchorLevel${anchor.lv_exp}`;
                            }
                            else {
                                lvIcon = `lvRichIcon r${anchor.lv_rich}`;
                            }

                            //贵族
                            let vipIcon = null;
                            if(anchor.vip > 0) {
                                const vipIconClass = `hotListImg basicLevel${anchor.vip}`;
                                vipIcon = <div className={vipIconClass}></div>;
                            }

                            const lvIcons = <div className="rankIcons">
                                                {vipIcon}
                                                <div className={lvIcon}></div>
                                            </div>;

                            anchor.name =anchor.username;

                            return (
                                <RankListPanel
                                    key={num}
                                    lvIcons={lvIcons}
                                    data={anchor}
                                    num={num} />
                            )
                        })}
                    </div>
                </div>
            )
        }
    }};

export default RankDetailPanel;