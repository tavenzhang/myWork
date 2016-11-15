/**
 * Created by soga on 16/10/1.
 */

import React, { Component } from "react";
import { connect } from 'react-redux';

//组件
import { Banner, VideoItem} from '../components';
import {CONFIG} from '../config';

class MyFav extends Component{

    static contextTypes = {
        router: React.PropTypes.object
    };

    /**
     * 进入房间
     */
    enterRoom(roomid) {
        const { router } = this.context;
        router.push({
            pathname: '/video/'+roomid,
            query: { from: 'myFav' }
        })
    }

    render(){
        const {myFav} = this.props;

        return (
            <div className="app-main-content">
                <Banner title="我的关注" back="/user" />
                <div className="appContent">
                    {
                        myFav.map((d,i)=>{
                            return (
                                <VideoItem
                                    key={i}
                                    name={d.username}
                                    imgSrc={CONFIG.imageServe + d.headimg}
                                    nums={d.total}
                                    isLive={d.live_status}
                                    onClick={()=>this.enterRoom(d.uid)}
                                    />
                            )
                        })
                    }
                </div>
            </div>
        );
    }
}

const mapStateToProps = state => {
    return {
        myFav: state.appState.myFav
    }
}

export default connect(mapStateToProps)(MyFav);