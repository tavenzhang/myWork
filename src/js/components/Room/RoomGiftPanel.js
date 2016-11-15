/**
 * Created by soga on 16/9/29.
 */
import React, {Component,PropTypes} from 'react';
import Idiamond from 'react-icons/lib/fa/diamond';
import { CONFIG } from '../../config';

class RoomGiftPanel extends Component {

    static propTypes = {
        data : PropTypes.any.isRequired,
        selectGift : PropTypes.func.isRequired,
        currentSeleGift : PropTypes.number
    };

    static defaultProps = {
    };

    shouldComponentUpdate(nextProps,nextState) {
        if(this.props.data != nextProps.data || this.props.currentSeleGift != nextProps.currentSeleGift) {
            return true
        }
        else {
            return false
        }
    }

    render() {
        const { data, currentSeleGift } = this.props;
        //console.log(data)
        return (
            <div className="room-gift-panel">
                {data.map(( v, index ) => {
                    const selected = currentSeleGift == v.gid ? 'selected' : '';
                    const roomGiftItem = `room-gift-item ${selected}`;
                    return (
                        <div className={roomGiftItem} key={index} onClick={()=>this.props.selectGift(v.gid)} >
                            <img src={CONFIG.giftPath + v.gid + ".png"} className="giftIcon" /><br />
                            {v.name}<br />
                            <span className="price">{v.price}<Idiamond className="Idiamond" /></span>
                        </div>
                    )
                })}
            </div>
        )
    }};

export default RoomGiftPanel;