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
            dispatch(fetchData({
                url : REQURL.getMyPrivateMsg.url,
                requestType : REQURL.getMyPrivateMsg.type,
                successAction : appAN.UPDATE_MY_PRIVATE_MSG
            }));
        }
    }

    sortByField(x, y) {
        let leftStr = x.created.replace(/\s/g,'T').replace(/\//g,'-');
        let rigtStr=y.created.replace(/\s/g,'T').replace(/\//g,'-');

        let leftDate=new Date(leftStr);
        let rightDate = new Date(rigtStr);

          return rightDate.getTime() -leftDate.getTime();
    }

    render(){
        const {myMsg,drawerOpen,dispatch,myPrivateMsg} = this.props;
        let dataMsg=[];
        dataMsg =dataMsg.concat(myMsg);
        dataMsg=dataMsg.concat(myPrivateMsg);
        dataMsg.sort(this.sortByField);
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
                        dataMsg.map((v,i) => {
                            if(v.category==1){//系统邮件
                                return (
                                    <div className="msg-list" key={i}>
                                        <h8>收件日期：{v.created}</h8>
                                        <p>{v.content}</p>
                                        <Divider />
                                    </div>
                                )
                            }
                            else{
                                return (
                                    <div className="msg-list" key={i}>
                                        <h8>收件日期：{v.created} <br/> 发件人: {v.send_user ? v.send_user.nickname:""}</h8>
                                        <p style={{color:"red"}} > 【个人私信】{v.content}</p>
                                        <Divider />
                                    </div>
                                )
                            }

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
        myPrivateMsg:state.appState.myPrivateMsg
    }
}

export default connect(mapStateToProps)(MyMsg);