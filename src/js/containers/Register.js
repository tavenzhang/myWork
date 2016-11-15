/**
 * Created by soga on 16/9/23.
 */
import React, { Component } from 'react';
import { connect } from 'react-redux';

import { Banner, RaisedButton, Checkbox, TextField } from '../components';

//actions
import {appAct,fetchData,appAN} from '../actions';

import { REQURL, SERVERADDR } from '../config';
import { encode } from '../utils/util';

class Register extends Component {
    constructor(props){
        super(props);
        this.requestUserInfo = this.requestUserInfo.bind(this);
        this.goLogin         = this.goLogin.bind(this);
    }

    static contextTypes = {
        router: React.PropTypes.object
    };


    handleLogin(e){

        const { dispatch } = this.props;
        const registerCallback = this.requestUserInfo;
        const { Rusername, Rnickname, Rpassword, Rrepassword, RsCode } = this.refs;
        //isConnected ? dispatch(msgAct.disconnect()) : dispatch(msgAct.connect());
        //router.push("/user");
        //dispatch(appAct.login(true));
        Rusername.blur();
        Rnickname.blur();
        Rpassword.blur();
        Rrepassword.blur();
        RsCode.blur();

        let registerData = {
            "username": Rusername.getValue(),
            "nickname": Rnickname.getValue(),
            "password": encode(Rpassword.getValue()),
            "repassword": encode(Rrepassword.getValue()),
            "sCode": RsCode.getValue()
        }
        dispatch(fetchData({
            url : REQURL.register.url,
            requestType : REQURL.register.type,
            requestData : registerData,
            successAction : appAN.LOGIN,
            callback : registerCallback
        }));
    }

    /**
     * 获取验证码图片
     * @returns {*}
     */
    getScodeImg() {
        return `${SERVERADDR}/verfiycode?t=${(new Date()).valueOf()}`;
    }

    /**
     * 切换验证码图片
     */
    changeScode() {
        const {RscodeImg} = this.refs;
        RscodeImg.src = this.getScodeImg();
    }

    /**
     * 请求用户信息
     */
    requestUserInfo() {
        const { dispatch } = this.props;
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

    goLogin() {
        const { location } = this.props;
        const {router} = this.context;

        //关闭对话框
        router.push({
            pathname: '/login',
            query: { from: location.query.from }
        });
    }


    render() {
        const { location } = this.props;
        let scodeImg = this.getScodeImg();

        //设置返回页面
        let back = '/user';
        if(location.query.from) {
            back = location.query.from;
        }

        return (
            <div className="app-main-content">
                <Banner title="注册" back={back} />
                <div className="login">
                    <div className="login-form">
                        <TextField
                            //hintText="Hint Text"
                            floatingLabelText="登录邮箱"
                            fullWidth={true}
                            ref="Rusername"
                            /><br />
                        <TextField
                            //hintText="Hint Text"
                            floatingLabelText="用户昵称"
                            ref="Rnickname"
                            fullWidth={true}
                            /><br />
                        <TextField
                            //hintText="Hint Text"
                            floatingLabelText="登录密码"
                            fullWidth={true}
                            type="password"
                            ref="Rpassword"
                            />
                        <TextField
                            //hintText="Hint Text"
                            floatingLabelText="确认密码"
                            fullWidth={true}
                            type="password"
                            ref="Rrepassword"
                            />
                        <TextField
                            //hintText="Hint Text"
                            floatingLabelText="验证码"
                            fullWidth={true}
                            ref="RsCode"
                            style={{ width:'60%'}}
                            />
                        <img src={scodeImg} className="scodeImg" ref="RscodeImg" onClick={()=>this.changeScode()} />
                        <br /><br /><br /><br />
                        <RaisedButton label="注 册" primary={true} fullWidth={true} onClick={ e => { this.handleLogin(e) } } />
                        <div className="login-form-bottom">已有兰桂坊账号，<a href="javascript:;" onTouchTap={()=>this.goLogin()}>登录</a></div>
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

export default connect(mapStateToProps)(Register);
