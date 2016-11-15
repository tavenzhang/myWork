/**
 * Created by soga on 16/9/24.
 */
import React, {Component,PropTypes} from 'react';
import Iangleright from 'react-icons/lib/fa/angle-right';
import { Link } from 'react-router';

import './linkPanel.less';

class LinkPanel extends Component {

    static propTypes = {
        link : PropTypes.string.isRequired
    };

    static defaultProps = {
        link : '/'
    };

    render() {
        return (
            <Link to={this.props.link}>
                <div className="panel-item">
                    {this.props.children}
                    <Iangleright className="panel-item-rightIcon" />
                </div>
            </Link>
        )
    }};

export default LinkPanel;