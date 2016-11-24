/**
 * Created by soga on 16/10/1.
 */

import React, { Component } from "react";
import { connect } from 'react-redux';

//组件
import { Banner, List, ListItem, Divider, Avatar} from '../components';
import { REQURL, CONFIG } from '../config';
import FaAlignJustify from 'react-icons/lib/fa/bars';


import Idiamond from 'react-icons/lib/fa/diamond';

//actions
import { appAct, appAN, fetchData } from '../actions';

class MyRecord extends Component{
    componentDidMount() {
        //加载数据
        const {dispatch,myRecord} = this.props;

        if(!myRecord.length) {
            dispatch(fetchData({
                url : REQURL.getMyRecord.url,
                requestType : REQURL.getMyRecord.type,
                successAction : appAN.UPDATE_MYRECORD
            }));
        }
    }

    render(){
        const {myRecord,drawerOpen,dispatch} = this.props;
        return (
            <div className="app-main-content">
                <Banner
                    title="消费记录"
                    currentPath="/myRecord"
                    leftIcon={<FaAlignJustify className="menuIcon" />}
                    leftIconTouch={()=>dispatch(appAct.drawerToggle(!drawerOpen))}
                    drawerOpen={drawerOpen}
                    drawerClose={()=>dispatch(appAct.drawerClose())}
                    />
                <div className="appContent">
                    <List className="myRecord-list">
                        {
                            myRecord.map((v,i) => {
                                const giftIcon = `${CONFIG.giftPath + v.gid}.png`;
                                const desc = <p>
                                                数量：{v.gnum} <span className="price">价格：{v.points}<Idiamond className="Idiamond" /></span><br/>
                                                消费日期：{v.cr_time}
                                            </p>;

                                return (
                                    <div key={i}>
                                        <ListItem
                                            leftAvatar={<Avatar src={giftIcon} size={50} />}
                                            primaryText={v.name}
                                            secondaryText={desc}
                                            secondaryTextLines={2}
                                            />
                                        <Divider inset={true} />
                                    </div>
                                )
                            })
                        }
                    </List>
                </div>
            </div>
        );
    }
}

const mapStateToProps = state => {
    return {
        myRecord : state.appState.myRecord,//消费记录
        drawerOpen: state.appState.drawerOpen,//菜单
    }
}

export default connect(mapStateToProps)(MyRecord);