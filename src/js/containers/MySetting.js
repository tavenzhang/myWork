/**
 * Created by soga on 16/10/1.
 */

import React, { Component } from "react";
import { connect } from 'react-redux';

//组件
import { Banner, TextField, RaisedButton } from '../components';
import { SERVERADDR, REQURL } from '../config';
import FaAlignJustify from 'react-icons/lib/fa/bars';


import { fetchData, appAct } from '../actions';

class MySetting extends Component{

    /**
     * 重置密码
     * @param e
     */
    reSetPassword(e){

        const password = this.refs.MSpassword.getValue();
        const password1 = this.refs.MSpassword1.getValue();
        const password2 = this.refs.MSpassword2.getValue();
        const captcha = this.refs.MSsCode.getValue();

        const { dispatch } = this.props;

        if( password == "" || password1 == "" || password2 == "" || captcha == "" ) {
            dispatch(appAct.showInfoBox('字段不能为空','error'));
        }
        else {
            dispatch(fetchData({
                url : REQURL.reSetPassword.url,
                requestType : REQURL.reSetPassword.type,
                requestData : {
                    "password": password,
                    "password1": password1,
                    "password2": password2,
                    "captcha": captcha
                },
                //successAction : appAN.LOGIN,
                //callback : registerCallback
            }));
        }
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
        const {MSscodeImg} = this.refs;
        MSscodeImg.src = this.getScodeImg();
    }

    render(){
        const {drawerOpen,dispatch} = this.props;
        let scodeImg = this.getScodeImg();

        return (
            <div className="app-main-content">
                <Banner
                    title="设置"
                    currentPath="/mySetting"
                    leftIcon={<FaAlignJustify className="menuIcon" />}
                    leftIconTouch={()=>dispatch(appAct.drawerToggle(!drawerOpen))}
                    drawerOpen={drawerOpen}
                    drawerClose={()=>dispatch(appAct.drawerClose())}
                    />
                <div className="appContent appContent-text">
                    <div className="login-form">
                        <TextField
                            //hintText="Hint Text"
                            className="input"
                            floatingLabelText="现在的密码"
                            fullWidth={true}
                            floatingLabelFixed={true}
                            type="password"
                            ref="MSpassword"
                            /><br />
                        <TextField
                            //hintText="Hint Text"
                            className="input"
                            floatingLabelText="设置新密码"
                            fullWidth={true}
                            floatingLabelFixed={true}
                            type="password"
                            ref="MSpassword1"
                            />
                        <TextField
                            //hintText="Hint Text"
                            className="input"
                            floatingLabelText="重复新密码"
                            fullWidth={true}
                            floatingLabelFixed={true}
                            type="password"
                            ref="MSpassword2"
                            />
                        <TextField
                            //hintText="Hint Text"
                            className="input"
                            floatingLabelText="验证码"
                            fullWidth={true}
                            floatingLabelFixed={true}
                            ref="MSsCode"
                            style={{ width:'60%'}}
                            />
                        <img src={scodeImg} className="scodeImg" ref="MSscodeImg" onClick={()=>this.changeScode()} />
                        <br /><br /><br /><br />
                        <RaisedButton label="保存设置" primary={true} fullWidth={true} onClick={ e => { this.reSetPassword(e) } } />
                    </div>
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

export default connect(mapStateToProps)(MySetting);