/**
 * Created by soga on 16/10/3.
 */
import React, {Component,PropTypes} from 'react';
import { CONFIG } from '../../config';

class UserMount extends Component {

    static propTypes = {
        data : PropTypes.any.isRequired,
    };

    static defaultProps = {
    };

    shouldComponentUpdate(nextProps, nextState){
        return this.props.data !== nextProps.data;
        //return false 则不更新组件
    }

    render() {
        const { data } = this.props;
        const driveIcon = <img className="userMount" src={ CONFIG.giftPath + data.car + ".png" } />
        //用户进入房间消息
        let userEnter = <div className="user-entered">
            <span className="user-entered-lv">{driveIcon}</span>
            <span className="text">{data.name}开着坐骑登场</span>
        </div>;
        if(data.car) {
            return (
                <div className="user-enter-block" key={Math.random()}>
                    {userEnter}
                </div>
            )
        }
        else {
            return null;
        }
    }};

export default UserMount;