/**
 * Created by soga on 16/9/28.
 */
import React, {Component,PropTypes} from 'react';
import Iuser from 'react-icons/lib/fa/user'
import Ilock from 'react-icons/lib/fa/lock'

const defaultVideoBg = require('../../../images/videoBg_default.jpg');

class VideoItem extends Component {

    static propTypes = {
        imgSrc : PropTypes.string,
        name : PropTypes.string.isRequired,
        nums : PropTypes.any.isRequired,
        isLive : PropTypes.any.isRequired,
        onClick : PropTypes.func,
    };

    static defaultProps = {
        imgSrc : defaultVideoBg,
        name : '主播名称',
        nums : 0,
        isLive : false
    };

    render() {
        const {imgSrc,name,nums,isLive,enterRoomlimit,tid} = this.props;

        let [numsDom,liveIcon,lock] = [null,null,null];

        //显示人数
        if(isLive && nums > 0) {
            numsDom = <span className="desc"><Iuser className="vIcon" />{nums}</span>;
        }

        //限制房
        if(enterRoomlimit == 1 && tid == 2) {
            lock = <div className="lockBg"><Ilock className="lockIcon" /></div>
        }

        //显示直播状态
        if(isLive) {
            liveIcon = <span className="live"></span>;
        }

        return (
            <div className="video-item" onTouchTap={()=>this.props.onClick()}>
                {liveIcon}
                {lock}
                <img src={imgSrc} width="100%" height="100%" />
                <div className="infoPanel">
                    {name}
                    {numsDom}
                </div>
            </div>
        )
    }};

export default VideoItem;