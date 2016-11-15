/**
 * Created by soga on 16/9/24.
 */
import React, {Component,PropTypes} from 'react';
import LinkPanel from './LinkPanel';
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
        const { data, link } = this.props;

        return (
            <LinkPanel link={link} >
                <img src={this.props.iconSrc} className="rank-item-iconImg" />
                <div className="rank-item-content">
                    {data.map((v,index) => {
                        const itemClasName = `item item${index}`;

                        //等级icon
                        let lvIcon = null;
                        if(link == '/rankExp') {//主播排行
                            lvIcon = `lvIcon hotListImg AnchorLevel${v.lv_exp}`;
                        }
                        else {
                            lvIcon = `lvIcon lvRichIcon r${v.lv_rich}`;
                        }

                        let headImg = v.headimg ? CONFIG.imageServe + v.headimg + "?w=100&h=100" : require('../../../images/avatar_default.png');

                        return <div key={index} className={itemClasName} >
                                    <span className="num">{index+1}.</span>
                                    <img src={headImg} className="avatar" />
                                    <span className="name">{v.username}</span>
                                    <div className={lvIcon}></div>
                                </div>
                    })}
                </div>
            </LinkPanel>
        )
    }};

export default RankPanel;