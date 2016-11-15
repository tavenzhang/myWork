/**
 * Created by soga on 16/9/21.
 */
import React, {Component,PropTypes} from 'react';
import { Link } from 'react-router';
import RaisedButton from 'material-ui/RaisedButton';
import Idiamond from 'react-icons/lib/fa/diamond';

class ShopGiftPanel extends Component {

    static propTypes = {
        imgSrc : PropTypes.any.isRequired,
        name : PropTypes.any.isRequired,
        price : PropTypes.any.isRequired,
        btnName : PropTypes.string,
        btnClick : PropTypes.func
    };

    static defaultProps = {
        btnName : "购买"
    };

    render() {
        return (
            <div className="shopGift-item">
                <div className="giftBox">
                    <img src={this.props.imgSrc} />
                </div>
                <h5>{this.props.name}</h5>
                <h6>{this.props.price}<Idiamond /> / 月</h6>
                <RaisedButton
                    label={this.props.btnName}
                    primary={true}
                    onTouchTap={()=>this.props.btnClick()}
                    />
            </div>
        )
    }};

export default ShopGiftPanel;