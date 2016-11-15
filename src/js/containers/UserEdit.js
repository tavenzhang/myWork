import React, { Component } from "react";
import { connect } from 'react-redux';

//组件
import { Banner, TextField, RaisedButton } from '../components';
import { SERVERADDR, REQURL } from '../config';

import { fetchData, appAct, appAN } from '../actions';

class UserEdit extends Component{

    /**
     * 保存个人信息
     * @param e
     */
    save(e){

        const nickname = this.refs.UEnickname.getValue();
        const description = this.refs.UEdescription.getValue();

        const { dispatch } = this.props;

        if( nickname == "") {
            dispatch(appAct.showInfoBox('用户名不能为空','error'));
        }
        else {
            dispatch(fetchData({
                url : REQURL.editUserInfo.url,
                requestType : REQURL.editUserInfo.type,
                requestData : {
                    "nickname": nickname,
                    "description": description
                },
                callback : function(data) {
                    if(data.ret) {
                        dispatch(appAct.editUserInfo({
                            nickname : nickname,
                            description : description
                        }))
                    }
                    else {
                        dispatch(appAct.showInfoBox(data.info,'error'))
                    }
                }
            }));
        }
    }

    render(){
        const { userInfo } = this.props;

        return (
            <div className="app-main-content">
                <Banner title="个人信息" back={true} />
                <div className="appContent appContent-text">
                    <div className="login-form">
                        <TextField
                            //hintText="Hint Text"
                            floatingLabelText="昵称"
                            fullWidth={true}
                            defaultValue={userInfo.nickname}
                            ref="UEnickname"
                            />
                        <TextField
                            //hintText="Message Field"
                            floatingLabelText="签名"
                            multiLine={true}
                            fullWidth={true}
                            defaultValue={userInfo.description}
                            rows={2}
                            ref="UEdescription"
                            />
                        <br /><br /><br /><br />
                        <RaisedButton label="保 存" primary={true} fullWidth={true} onClick={ e => { this.save(e) } } />
                    </div>
                </div>
            </div>
        );
    }
}

//<SelectField
//    value={userInfo.sex}
//    fullWidth={true}
//    floatingLabelText="性别"
//    //onChange={this.handleChange}
//    autoWidth={true}
//    >
//    <MenuItem value={0} primaryText="女" />
//    <MenuItem value={1} primaryText="男" />
//</SelectField>

const mapStateToProps = state => {
    return {
        userInfo : state.appState.userInfo
    }
}

export default connect(mapStateToProps)(UserEdit);