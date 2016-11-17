/**
 * Created by soga on 16/9/19.
 */

import React, {Component,PropTypes} from 'react';
import CircularProgress from 'material-ui/CircularProgress';

import './loading.less';

class Loading extends Component {

    static propTypes = {
        show : PropTypes.bool
    };

    static defaultProps = {
        show : false
    };

    render() {
        if(this.props.show) {
            return (
                <div className="loading">
                    <div className="loading-main">
                        <CircularProgress />
                    </div>
                </div>
            )
        }
        else {
            return null;
        }

    }};

export default Loading;


//<CircularProgress />