/**
 * Created by soga on 16/10/1.
 */

import React, { Component } from "react";
import { connect } from 'react-redux';
import FaAlignJustify from 'react-icons/lib/fa/bars';

import { appAct } from './../actions'
//组件
import { Banner} from '../components';

class Recharge extends Component{

    render(){
        const {drawerOpen,dispatch} = this.props;
        return (
            <div className="app-main-content">
                <Banner
                    title="砖石充值"
                    currentPath="/recharge"
                    leftIcon={<FaAlignJustify className="menuIcon" />}
                    leftIconTouch={()=>dispatch(appAct.drawerToggle(!drawerOpen))}
                    drawerOpen={drawerOpen}
                    drawerClose={()=>dispatch(appAct.drawerClose())}
                    />
                <div className="appContent appContent-text">
                    <p className="textLine">尊敬的各位玩家，目前移动端还不支持充值功能，给大家带来不便敬请谅解！</p>
                </div>
            </div>
        );
    }
}

const mapStateToProps = state => {
    return {
        drawerOpen: state.appState.drawerOpen,//菜单
    }
}

export default connect(mapStateToProps)(Recharge);