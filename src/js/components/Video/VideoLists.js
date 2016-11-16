
/**
 * Created by soga on 16/9/28.
 */
import React, {Component,PropTypes} from 'react';
import { CONFIG } from '../../config';
import { VideoItem } from './../';

class VideoLists extends Component {

    static propTypes = {
        data : PropTypes.any.isRequired
    };

    static defaultProps = {
    };

    shouldComponentUpdate(nextProps,nextState) {
        if(this.props.data != nextProps.data) {
            return true
        }
        else {
            return false
        }
    }

    render() {
        return (
            <div className="home-item">
                {
                    this.props.data.map((d,i)=>{
                        let headImg = d.headimg ? CONFIG.imageServe + d.headimg + "?w=356&h=266" : require('../../../images/videoBg_default.jpg');
                        return (
                            <VideoItem
                                key={i}
                                name={d.username}
                                imgSrc={headImg}
                                nums={d.total}
                                isLive={d.live_status}
                                enterRoomlimit={d.enterRoomlimit}
                                liveTime={d.live_time}
                                tid={d.tid}
                                onClick={()=>this.props.action({
                                    uid:d.uid,
                                    enterRoomlimit:d.enterRoomlimit,
                                    tid:d.tid,
                                })}
                                />
                        )
                    })
                }
            </div>
        )
    }};

export default VideoLists;