/**
 * Created by soga on 16/10/1.
 */

import React, { Component } from "react";
import { connect } from 'react-redux';

//组件
import { Banner, VideoItem } from '../components';
import FaAlignJustify from 'react-icons/lib/fa/bars';

import {CONFIG} from '../config';

import { appAct} from '../actions';


class MyOrd extends Component{
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
        const {myRes,drawerOpen,dispatch} = this.props;

        return (
            <div className="app-main-content">
                <Banner
                    title="我的预约"
                    currentPath="/myOrd"
                    leftIcon={<FaAlignJustify className="menuIcon" />}
                    leftIconTouch={()=>dispatch(appAct.drawerToggle(!drawerOpen))}
                    drawerOpen={drawerOpen}
                    drawerClose={()=>dispatch(appAct.drawerClose())}
                    />
                <div className="appContent">
                    <div className="appContent">
                        {
                            myRes.map((d,i)=>{
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
            </div>
        );
    }
}

const mapStateToProps = state => {
    return {
        myRes: state.appState.myRes,
        drawerOpen: state.appState.drawerOpen,//菜单
    }
}

export default connect(mapStateToProps)(MyOrd);