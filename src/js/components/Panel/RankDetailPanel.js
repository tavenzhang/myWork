/**
 * Created by soga on 16/9/25.
 */
import React, {Component,PropTypes} from 'react';
import RankListPanel from './RankListPanel';
//import Divider from 'material-ui/Divider';
import { CONFIG } from '../../config';

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
        console.log("222222")
        const top3 = data.slice(0,3);
        const others = data.slice(3);

        //没有排行榜数据
        if(top3.length == 0) {
            return (
                <div className="noContent">暂无数据~</div>
            )
        }
        else {
            //top3数组数据
            let top3p = [];

            top3.map((v,index) => {
                if(v && v.uid) {
                    const tempClassName = `rankDetail-top3-item p${index}`;
                    const nameClassName = `name p${index}`;

                    //等级icon
                    let lvIcon = null;
                    if(type == 'exp') {//主播排行
                        lvIcon = `hotListImg AnchorLevel${v.lv_exp}`;
                    }
                    else {
                        lvIcon = `lvRichIcon r${v.lv_rich}`;
                    }

                    //贵族
                    let vipIcon = null;
                    if(v.vip > 0) {
                        const vipIconClass = `hotListImg basicLevel${v.vip}`;
                        vipIcon = <div className={vipIconClass}></div>;
                    }

                    //头像
                    const headimg = v.headimg ? CONFIG.imageServe + v.headimg + "?w=100&h=100" : require('../../../images/avatar_default.png');

                    const temp = <div className={tempClassName}>
                                    <img src={headimg} className="avatar" /><br />
                                    <span className={nameClassName}>{v.username}</span><br />
                                    {vipIcon}<div className={lvIcon}></div>
                                </div>;
                    top3p.push(temp);
                }
            });

            return (
                <div className="rankDetail">
                    <div className="rankDetail-top3">
                        {top3p[1]}
                        {top3p[0]}
                        {top3p[2]}
                        <img src={rankTopsPic} className="top3-platform" />
                    </div>
                    <div className="rank-list">
                        {others.map(( anchor, index ) => {
                            let num = index + 4;
                            if(num < 10) num = "0"+num;

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