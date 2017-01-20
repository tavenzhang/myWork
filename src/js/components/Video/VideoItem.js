/**
 * Created by soga on 16/9/28.
 */
import React, {Component,PropTypes} from 'react';
import Iuser from 'react-icons/lib/fa/user'
import Ilock from 'react-icons/lib/fa/lock'
import {FlatButton,RaisedButton} from "../"

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
        const {imgSrc,name,nums,isLive,enterRoomlimit,tid,liveTime,lv_type,appoint_state} = this.props;

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
        else {
            liveIcon = <span className="live reset"></span>;
        }
        //1: 未预约 2: 约会中3: 已被预约
        let dateBtn=null;

        if(lv_type==3)
        {
            switch(appoint_state){
                case 1:
                    dateBtn= <RaisedButton label="立即预约" primary={true} />
                    break;
                case 2:
                    dateBtn=<RaisedButton label="约会中" primary={true}  disabled={true} />
                    break;
                case 3:
                    dateBtn= <RaisedButton label="已被预约" primary={true} disabled={true}/>
                    break;
            }
        }

        return (
            <div className="video-item" onTouchTap={()=>this.props.onClick()}>
                {liveIcon}
                <img src={imgSrc} className="avatar" />
                <div className="infoPanel">
                    <div className="rightTop">{liveIcon} {liveTime}</div>
                    <div className="title">主播</div>
                    <div className="name">{name}</div>
                    <div  className="videoItem"> {dateBtn}</div>
                </div>
            </div>
        )
    }};

export default VideoItem;