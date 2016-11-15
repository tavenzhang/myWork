/**
 * Created by soga on 16/9/21.
 */


import React, {Component,PropTypes} from 'react';

class ContentPanel extends Component {

    static propTypes = {
        className : PropTypes.string
    };

    static defaultProps = {
        className : ''
    };

    render() {
        const className = `contentPanel ${this.props.className}`;
        return (
            <div className={className}>
                {this.props.children}
            </div>
        )
    }};

export default ContentPanel;
