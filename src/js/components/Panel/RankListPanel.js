/**
 * Created by soga on 16/9/26.
 */
import React, {Component,PropTypes} from 'react';
import Avatar from 'material-ui/Avatar';
import { CONFIG } from '../../config';

class RankListPanel extends Component {

    static propTypes = {
        num : PropTypes.any,
        data : PropTypes.any,
        lvIcons : PropTypes.any,
    };

    static defaultProps = {
    };

    render() {
        const { data, num } = this.props;

        if(this.props.children) {
            return (
                <div className="rankListPanel-item">
                    {this.props.children}
                </div>
            );
        }
        else {
            //头像
            const headimg = data.headimg ? CONFIG.imageServe + data.headimg + "?w=100&h=100" : require('../../../images/avatar_default.png');
            return (
                <div className="rankListPanel-item">
                    <span className={`rankList r${num}`}></span>
                    <Avatar className="avatar" src={headimg} size={60} />
                    {data.name}
                    {this.props.lvIcons}
                </div>
            );
        }

    }};

export default RankListPanel;