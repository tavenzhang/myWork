/**
 * Created by soga on 16/9/21.
 */
import React, {Component,PropTypes} from 'react';
import Iangleright from 'react-icons/lib/fa/angle-right';
import { Link } from 'react-router';

import { CONFIG } from '../../config';

class ActivityPanel extends Component {

    static propTypes = {
        data : PropTypes.any
    };

    static defaultProps = {

    };

    render() {
        const { data } = this.props;

        let status = `status`;

        let [startDate,endDate,nowDate] = [Date.parse(new Date(data.start_time)),Date.parse(new Date(data.end_time)),(new Date()).valueOf()];

        //活动进行中
        if(nowDate > startDate && nowDate <= endDate) {
            status = `status start`;
        }

        //活动结束
        if(nowDate > endDate) {
            status = `status end`;
        }

        return (
            <div className="activity-item">
                <div className="title">活动主题：{data.title}</div>
                <div className={status}></div>
                <img className="activityPic" src={CONFIG.imageServe + data.temp_name }  />
                <Link to={`/activity/${data.url}`}>
                    <div className="activityDetailBtn">查看详情>>></div>
                </Link>
            </div>

        )
    }};

export default ActivityPanel;
