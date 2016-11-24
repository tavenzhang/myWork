/**
 * Created by soga on 16/10/1.
 */

import React, { Component } from "react";
import { connect } from 'react-redux';

//组件
import { Banner, Divider } from '../components';
import { REQURL, CONFIG } from '../config';
import FaAlignJustify from 'react-icons/lib/fa/bars';


//actions
import { appAct, appAN, fetchData } from '../actions';

class MyMsg extends Component{
    componentDidMount() {
        //加载数据
        const {dispatch,myMsg} = this.props;

        if(!myMsg.length) {
            dispatch(fetchData({
                url : REQURL.getMyMsg.url,
                requestType : REQURL.getMyMsg.type,
                successAction : appAN.UPDATE_MYMSG
            }));
        }
    }

    render(){
        const {myMsg,drawerOpen,dispatch} = this.props;
        return (
            <div className="app-main-content">
                <Banner
                    title="我的信箱"
                    currentPath="/myMsg"
                    leftIcon={<FaAlignJustify className="menuIcon" />}
                    leftIconTouch={()=>dispatch(appAct.drawerToggle(!drawerOpen))}
                    drawerOpen={drawerOpen}
                    drawerClose={()=>dispatch(appAct.drawerClose())}
                    />
                <div className="appContent">
                    {
                        myMsg.map((v,i) => {
                            return (
                                <div className="msg-list" key={i}>
                                    <h5>收件日期：{v.created}</h5>
                                    <p>{v.content}</p>
                                    <Divider />
                                </div>
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
        myMsg : state.appState.myMsg,//消息
        drawerOpen: state.appState.drawerOpen,//菜单
    }
}

export default connect(mapStateToProps)(MyMsg);