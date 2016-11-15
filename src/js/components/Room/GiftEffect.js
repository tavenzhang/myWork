/**
 * Created by soga on 16/10/3.
 */
import React, {Component,PropTypes} from 'react';
import { CONFIG } from '../../config';
import { rnd,log } from '../../utils/util'

class GiftEffect extends Component {

    constructor(props){
        super(props);
        this.state = {
            giftEffNum : 0
        }
    }

    static propTypes = {
        data : PropTypes.any.isRequired,
    };

    static defaultProps = {
    };

    shouldComponentUpdate(nextProps, nextState){
        return this.props.data !== nextProps.data;
        //return false 则不更新组件
    }

    getEffectName() {
        const giftEffectArray = ['swap','rotateDown','rotateLeft','rotateRight','rotateUp','puffIn','vanishIn','bombLeftOut','twisterInDown','twisterInUp','holeOut','swashIn'];
        return giftEffectArray[rnd(0,12)];
    }

    render() {
        const { data } = this.props;

        const giftIcon = `${CONFIG.giftPath + data.gid}.png`;

        let giftNumObj = <div className="giftNum">x<span className="num">{data.gnum}</span></div>

        //普通礼物，大于10个时的动画效果
        if(data.gnum >= 10) {
            giftNumObj = <div className="giftNum">
                            <div className="giftNumBlock effect1">x<span className="num">{data.gnum-2}</span></div>
                            <div className="giftNumBlock effect2">x<span className="num">{data.gnum-1}</span></div>
                            <div className="giftNumBlock effect3">x<span className="num">{data.gnum}</span></div>
                        </div>
        }


        //默认动画效果
        let effectCompent = <div className="user-sendGift-block" key={Math.random()}>
                                <div className='user-sendGift amin32s'>
                                    <div className="contentBox">
                                        <img src={CONFIG.imageServe + data.headimg} className="avatar" />
                                        <div className="senderBox">
                                            <div className="sender">{data.sendName}</div>
                                        </div>

                                    </div>
                                    <img src={giftIcon} className="gift" />
                                    {giftNumObj}
                                </div>
                            </div>;

        let effectName = this.getEffectName() || 'vanishIn';
        //log(effectName)
        //豪华动画效果
        //log(data.price)
        if(data.goodCategory == 3 || data.goodCategory == 4 || data.goodCategory == 5 || (data.price >= 200 && data.gnum == 1)) {
            giftNumObj = <div className="giftNum">x<span className="num">{data.gnum}</span></div>;
            effectCompent = <div className={`bigGift magictime ${effectName}`} key={Math.random()}>
                                { data.gnum>1 ? giftNumObj : null}
                                <img src={giftIcon} className="giftBig" />
                            </div>;
        }

        if(data.gid) {
            return effectCompent
        }
        else {
            return null;
        }
    }};

export default GiftEffect;
