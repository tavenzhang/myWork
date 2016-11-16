/**
 * Created by soga on 16/9/24.
 */
import React, {Component,PropTypes} from 'react';
import { Link } from 'react-router';
import { CONFIG } from '../../config';

class RankPanel extends Component {

    static propTypes = {
        link : PropTypes.string.isRequired,
        iconSrc : PropTypes.string.isRequired,
        data : PropTypes.any.isRequired
    };

    static defaultProps = {
        link : '/'
    };

    render() {
        const { link, iconSrc } = this.props;

        return (
            <Link to={link} >
                <img src={iconSrc} className="rank-item-iconImg" />
            </Link>
        )
    }};

export default RankPanel;