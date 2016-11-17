/**
 * Created by soga on 16/11/16.
 */
import React, {Component,PropTypes} from 'react';

import LinkPanel from './LinkPanel';

class UserMenuItem extends Component {

    static propTypes = {
    };

    static defaultProps = {
    };

    render() {
        const {icon, title, onTouchTap} = this.props;
        return (
            <div className="menuItem" onTouchTap={()=>onTouchTap()}>
                <img src={icon} className="menuItem-icon" />
                <span className="menuItem-title">{title}</span>
            </div>
        )
    }};

export default UserMenuItem;