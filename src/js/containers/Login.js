import React, { Component } from 'react';
import { connect } from 'react-redux';

import { Banner, RaisedButton, Checkbox, TextField } from '../components';

//actions
import {appAct,fetchData,appAN} from '../actions';

import { REQURL } from '../config';
import { encode } from '../utils/util';

class Login extends Component {
    constructor(props){
        super(props);
        this.requestUserInfo = this.requestUserInfo.bind(this);
        this.goRegister      = this.goRegister.bind(this);

    }

    static contextTypes = {
        router: React.PropTypes.object
    };

    //登陆
    handleLogin(e){

        const { dispatch } = this.props;
        const loginCallback = this.requestUserInfo;
        const { Luname, Lpassword } = this.refs;

        //去除input焦点
        Luname.blur();
        Lpassword.blur();

        let loginData = {
            "uname": Luname.getValue(),
            "password": encode(Lpassword.getValue()),
            "sCode": '',
            "v_remember": 0
        };
        //登录
        dispatch(fetchData({
            url : REQURL.login.url,
            requestType : REQURL.login.type,
            requestData : loginData,
            successAction: appAN.LOGIN,
            callback : loginCallback
        }));
    }

    /**
     * 请求用户信息
     */
    requestUserInfo() {
        const { dispatch, location } = this.props;
        const { router } = this.context;

        //请求用户信息
        dispatch(fetchData({
            url : REQURL.getUserInfo.url,
            requestType : REQURL.getUserInfo.type,
            successAction: appAN.UPDATE_USERINFO,
            callback : function() {
                let backUrl = '/user';

                if(location.query.from) {
                    backUrl = location.query.from;
                }
                router.push(backUrl);
            }
        }));
    }

    /**
     * 返回注册
     */
    goRegister() {
        const { location } = this.props;
        const {router} = this.context;

        //关闭对话框
        router.push({
            pathname: '/register',
            query: { from: location.query.from }
        });
    }

    render() {
        const { location } = this.props;

        //设置返回页面
        let back = '/user';
        if(location.query.from) {
            back = location.query.from;
        }

        return (
            <div className="app-main-content" ref="login">
                <Banner title="登录" back={back} />
                <div className="login">
                    <div className="login-form">
                        <TextField
                            //hintText="Hint Text"
                            floatingLabelText="登录邮箱"
                            fullWidth={true}
                            ref="Luname"
                        /><br />
                        <TextField
                            //hintText="Hint Text"
                            floatingLabelText="登录密码"
                            fullWidth={true}
                            type="password"
                            ref="Lpassword"
                        /><br />
                        <Checkbox
                            label="记住密码"
                            className="login-checkbox"
                        /><br/>
                        <RaisedButton label="登 录" primary={true} fullWidth={true} onTouchTap={ () => this.handleLogin() } />
                        <div className="login-form-bottom">没有兰桂坊账号？<a href="javascript:;" onTouchTap={()=>this.goRegister()}>注册新用户</a></div>
                    </div>
                </div>
            </div>

        );

    }

}

const mapStateToProps = state => {
    return {
        isConnected: state.msgState.status
    }
}

export default connect(mapStateToProps)(Login);
