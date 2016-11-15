/**
 * Created by soga on 16/10/28.
 */
import React, {Component,PropTypes} from 'react';
import Snackbar from 'material-ui/Snackbar';

import './incon.less';

class LvIcon extends Component {

    static propTypes = {
        lv : PropTypes.any,
        type  : PropTypes.string,
    };

    static defaultProps = {
        lv : 0,
        type : 'rich'
    };

    render() {
        const {lv,type} = this.props;

        let className = `lvRichIcon r${lv}`;

        //主播
        if(type == 'exp') {
            className = `hotListImg AnchorLevel${lv}`;
        }

        //贵族
        if(type == 'vip') {
            className = `hotListImg basicLevel${lv}`;
        }

        if((type == 'rich' && lv < 1) || !lv || lv == "0") {
            return null;
        }
        else {
            return (
                <div className={className}></div>
            )
        }
    }};

export default LvIcon;