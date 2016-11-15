/**
 * Created by soga on 16/9/28.
 */import React, {Component,PropTypes} from 'react';
import RankListPanel from '../Panel/RankListPanel';
import { CONFIG } from '../../config';
import Idiamond from 'react-icons/lib/fa/diamond';

const rankTopsPic = require('../../../images/rank_top3.png');

class GiftRank extends Component {

    static propTypes = {
        data : PropTypes.any.isRequired
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
        const { data } = this.props;

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

                    //头像
                    const headimg = v.headimg ? CONFIG.imageServe + v.headimg + "?w=100&h=100" : require('../../../images/avatar_default.png');

                    const temp = <div className={tempClassName}>
                        <img src={headimg} className="avatar" /><br />
                        <span className={nameClassName}>{v.name}</span><br />
                        <span className="desc">{v.score}<Idiamond className="moneyIcon" /></span>
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
                            let lvIcons = <span className="room-rankList-diamond">{anchor.score}<Idiamond className="diamond" /></span>;
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

export default GiftRank;