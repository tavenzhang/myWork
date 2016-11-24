/**
 * Created by soga on 16/10/1.
 */

import React, { Component } from "react";
import { connect } from 'react-redux';

//组件
import { Banner, FlatButton} from '../components';
import { REQURL, CONFIG } from '../config';
import { changeDate } from '../utils/util'
import FaAlignJustify from 'react-icons/lib/fa/bars';

//actions
import { appAct, appAN, fetchData } from '../actions';

class MyMount extends Component{

    constructor(props){
        super(props);
        this.getMount    = this.getMount.bind(this);
    }

    componentDidMount() {
        //加载数据
        const {myMount} = this.props;

        if(!myMount.length) {
            this.getMount();
        }
    }

    static contextTypes = {
        router: React.PropTypes.object
    };

    /**
     * 获取坐骑数据
     */
    getMount() {
        const {dispatch} = this.props;
        dispatch(fetchData({
            url : REQURL.getMyMount.url,
            requestType : REQURL.getMyMount.type,
            successAction : appAN.UPDATE_MYMOUNT
        }));
    }

    /**
     * 装配坐骑
     */
    equip(gid) {
        const {dispatch} = this.props;
        const getMountData = this.getMount;

        dispatch(fetchData({
            url : REQURL.equipMount.url,
            requestType : REQURL.equipMount.type,
            requestData : {
                "handle": "equip",
                "gid": gid
            },
            callback : function(data) {
                if(data.status == 1) {
                    dispatch(appAct.showInfoBox('装配成功'));
                    //重新获取数据
                    getMountData();
                }
            }
        }));
    }

    /**
     * 取消装配
     */
    cancelEquip() {
        const {dispatch} = this.props;
        const getMountData = this.getMount;

        dispatch(fetchData({
            url : REQURL.cancelMount.url,
            requestType : REQURL.cancelMount.type,
            callback : function(data) {
                if(data.status == 1) {
                    //重新获取数据
                    getMountData();
                    dispatch(appAct.showInfoBox('装配取消成功'));
                }
            }
        }));
    }

    /**
     * 去充值页面
     */
    goRecharge() {
        const {router} = this.context;
        router.push({
            pathname: '/recharge',
        });
    }

    render(){
        const {myMount,drawerOpen,dispatch} = this.props;
        return (
            <div className="app-main-content">
                <Banner
                    title="我的道具"
                    currentPath="/myMount"
                    leftIcon={<FaAlignJustify className="menuIcon" />}
                    leftIconTouch={()=>dispatch(appAct.drawerToggle(!drawerOpen))}
                    drawerOpen={drawerOpen}
                    drawerClose={()=>dispatch(appAct.drawerClose())}
                    />
                <div className="appContent">
                    {
                        myMount.map((v,i) => {
                            const edate = changeDate(v.expires);
                            const edateStr = `截止日期：${edate}`;

                            let [status, canEquiped, btnLabel] = ["",false,null];//道具状态

                            if(v.gid < 120001 || v.gid > 121000) {
                                status = "不可装备";
                                btnLabel = <FlatButton
                                    disabled={true}
                                    label="不可装备"
                                    />;
                            }
                            else if(v.expires *1000 < (new Date()).valueOf()) {
                                status = "已过期";
                                btnLabel = <FlatButton
                                        label="前去续费"
                                        primary={true}
                                        onTouchTap={()=>this.goRecharge()}
                                    />;
                            }
                            else {
                                if(v.equip.length == 0) {
                                    status = "未装备";
                                    canEquiped = true;
                                    btnLabel = <FlatButton
                                        label="立即装备"
                                        secondary={true}
                                        onTouchTap={()=>this.equip(v.gid)}
                                        />;
                                }
                                else {
                                    for(var prop in v.equip ) {
                                        if( prop == v.gid ) {
                                            status = "已装备";
                                            btnLabel = <FlatButton
                                                label="取消装备"
                                                onTouchTap={()=>this.cancelEquip()}
                                                />;
                                        }
                                        else {
                                            status = "未装备";
                                            canEquiped = true;
                                            btnLabel = <FlatButton
                                                label="立即装备"
                                                secondary={true}
                                                onTouchTap={()=>this.equip(v.gid)}
                                                />;
                                        }
                                    }
                                }
                            }

                            //坐骑图片地址
                            const imgSrc = `${CONFIG.giftPath + v.gid}.png`;

                            return (
                                <div key={i} className="myMount-panel">
                                    <h3>{v.name}</h3>
                                    <h5 className="expirDate">{edateStr}</h5>
                                    <img src={imgSrc} className="mount" />
                                    <div className="desc">{v.desc}</div>
                                    {btnLabel}
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
        myMount : state.appState.myMount,//我的道具
        drawerOpen: state.appState.drawerOpen,//菜单
    }
}

export default connect(mapStateToProps)(MyMount);