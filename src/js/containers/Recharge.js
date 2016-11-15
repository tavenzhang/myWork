/**
 * Created by soga on 16/10/1.
 */

import React, { Component } from "react";
import { connect } from 'react-redux';

//组件
import { Banner} from '../components';

class Recharge extends Component{

    render(){

        return (
            <div className="app-main-content">
                <Banner title="充值" back={true} />
                <div className="appContent appContent-text">
                    <p className="textLine">尊敬的各位玩家，目前移动端不支持充值功能，给大家带来不便敬请谅解~</p>
                    <p className="textLine">要充值的用户请登录电脑端网站充值，或者加QQ联系美女客服可可进行人工充值，可可的QQ号：<mark>3543088613</mark></p>
                </div>
            </div>
        );
    }
}

const mapStateToProps = state => {
    return {
    }
}

export default connect(mapStateToProps)(Recharge);