/**
 * Created by soga on 16/9/21.
 */
import React, {Component,PropTypes} from 'react';
import { Link } from 'react-router';
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
        const {type, imgSrc, price, btnName, btnClick} = this.props;

        let bottomDesc = <span>{price}<Idiamond /> / 月</span>

        if(type == "myMount") {
            bottomDesc = <span style={{ marginLeft: 4 }}>{price} 截止</span>
        }

        return (
            <div className="shopGift-item">
                <div className="giftBox">
                    <img src={imgSrc} />
                </div>
                <h5>{this.props.name}</h5>
                <div className="bottom">
                    {bottomDesc}
                    { btnClick ? <button onTouchTap={()=>this.props.btnClick()}>{btnName}</button> : null }
                </div>
            </div>
        )
    }};

export default ShopGiftPanel;