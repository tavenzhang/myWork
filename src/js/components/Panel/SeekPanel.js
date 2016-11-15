/**
 * Created by soga on 16/9/21.
 */
import React, {Component,PropTypes} from 'react';

import LinkPanel from './LinkPanel';

class ContentPanel extends Component {

    static propTypes = {
        link : PropTypes.string.isRequired,
        imgSrc : PropTypes.string
    };

    static defaultProps = {
        link : '/',
        imgSrc : ''
    };

    render() {
        return (
            <LinkPanel link={this.props.link} >
                <img src={this.props.imgSrc} className="seek-item-img" />
            </LinkPanel>
        )
    }};

export default ContentPanel;