/**
 * Created by soga on 16/10/1.
 */

import React, { Component } from "react";
import { connect } from 'react-redux';
import FaAlignJustify from 'react-icons/lib/fa/bars';

import { appAct, fetchData } from './../actions'
import { REQURL } from '../config';

//组件
import { Banner, SelectField, MenuItem, RadioButtonGroup, RadioButton, RaisedButton, Dialog, FlatButton } from '../components';

class Recharge extends Component{

    handleRecharge() {
        const {dispatch,payMethod,chargePrice} = this.props;

        window.open("http://"+window.location.host+"/charge/pay/?interface_code="+payMethod+"&price="+chargePrice+"&charge_channel=100050");
        //打开金额确认窗口
        dispatch(appAct.showRechargeDialog(true));

        //设置订单号
        dispatch(appAct.setRechargeOrderid(data.msg.order_id));

        //dispatch(fetchData({
        //    url : REQURL.chargePay.url,
        //    requestType : REQURL.chargePay.type,
        //    requestData : {
        //        'interface_code': payMethod,
        //        'charge_channel': 100050,
        //        'price': chargePrice
        //    },
        //    callback : function(data) {
        //        if(data.status) {
        //            console.log(data.msg.pay_url);
        //            if(data.msg.pay_url) {
        //                //打开金额确认窗口
        //                //dispatch(appAct.showRechargeDialog(true));
        //
        //                //设置订单号
        //                dispatch(appAct.setRechargeOrderid(data.msg.order_id));
        //
        //                //window.open(data.msg.pay_url);
        //                window.location = data.msg.pay_url;
        //            }
        //            else {
        //                dispatch(appAct.showInfoBox('支付失败','error'));
        //            }
        //
        //        }
        //        else {
        //            dispatch(appAct.showInfoBox('支付失败:'+data.msg,'error'));
        //        }
        //    }
        //}));
    }

    confirmRecharge() {
        const {dispatch,rechargeOrderId} = this.props;

        //dispatch(appAct.showRechargeDialog(false));
        dispatch(fetchData({
            url : REQURL.chargeCheck.url,
            requestType : REQURL.chargeCheck.type,
            requestData : {
                'order_id' : rechargeOrderId
            },
            callback : function(data) {
                console.log(data);
                dispatch(appAct.showRechargeDialog(false));
                if(data.status) {//失败
                    dispatch(appAct.showInfoBox('支付失败:'+data.msg,'error'));
                }
            }
        }));
    }

    render(){
        const {drawerOpen,dispatch,payMethod,chargePrice,chargeConfirmDialog} = this.props;
        return (
            <div className="app-main-content">
                <Banner
                    title="钻石充值"
                    currentPath="/recharge"
                    leftIcon={<FaAlignJustify className="menuIcon" />}
                    leftIconTouch={()=>dispatch(appAct.drawerToggle(!drawerOpen))}
                    drawerOpen={drawerOpen}
                    drawerClose={()=>dispatch(appAct.drawerClose())}
                    />
                <div className="appContent appContent-text">
                    <SelectField
                        floatingLabelText="支付方式"
                        floatingLabelStyle={{color: 'white'}}
                        labelStyle={{color: '#cb2064'}}
                        //selectedMenuItemStyle={{color: 'white'}}
                        fullWidth={true}
                        value={payMethod}
                        onChange={(event, index, value) => dispatch(appAct.updatePayMethod(value))}
                        >

                        <MenuItem value={`ZFB`} primaryText="支付宝" />
                        <MenuItem value={`WEIXIN`} primaryText="微信" />
                    </SelectField>
                    <div className="recharge-title">充值金额</div>
                    <RadioButtonGroup
                        name="shipSpeed"
                        defaultSelected={chargePrice}
                        onChange={(e,v) => dispatch(appAct.updateChargePrice(v))}
                        >
                        <RadioButton
                            value="10"
                            label="10元（100砖石）"
                            className="radio"
                            labelStyle={{color:'white'}}
                            />
                        <RadioButton
                            value="50"
                            label="50元（500砖石）"
                            className="radio"
                            labelStyle={{color:'white'}}
                            />
                        <RadioButton
                            value="100"
                            label="100元（1000砖石）"
                            className="radio"
                            labelStyle={{color:'white'}}
                            />
                        <RadioButton
                            value="200"
                            label="200元（2000砖石）"
                            className="radio"
                            labelStyle={{color:'white'}}
                            />
                        <RadioButton
                            value="300"
                            label="300元（3000砖石）"
                            className="radio"
                            labelStyle={{color:'white'}}
                            />
                        <RadioButton
                            value="500"
                            label="500元（5000砖石）"
                            className="radio"
                            labelStyle={{color:'white'}}
                            />

                        <RadioButton
                            value="1000"
                            label="1000元（10000砖石）"
                            className="radio"
                            labelStyle={{color:'white'}}
                            />

                        <RadioButton
                            value="2000"
                            label="2000元（20000砖石）"
                            className="radio"
                            labelStyle={{color:'white'}}
                            />

                    </RadioButtonGroup>
                    <br /><br />
                    <RaisedButton label="充值" primary={true} fullWidth={true} onTouchTap={ () => this.handleRecharge() } />
                </div>
                <Dialog
                    title="系统提示"
                    actions={
                    [
                        <FlatButton
                            label="确定"
                            primary={true}
                            onTouchTap={()=>this.confirmRecharge()}
                        />,
                        //<FlatButton
                        //    label="取消"
                        //    onTouchTap={()=>dispatch(appAct.showRechargeDialog(false))}
                        ///>
                        ]
                    }
                    modal={true}
                    open={chargeConfirmDialog}
                    titleClassName="dialog-title"
                    bodyClassName="dialog-body"
                    actionsContainerClassName="dialog-action"
                    overlayClassName="dialog-overlay"
                    >
                    系统会跳出二维码请使用屏幕截图于微信或支付宝中选（扫一扫）从相册中选取二维码扫描,请完成支付后关闭此窗口。
                </Dialog>
            </div>
        );
    }
}

const mapStateToProps = state => {
    return {
        drawerOpen: state.appState.drawerOpen,//菜单
        payMethod: state.appState.payMethod,//支付方式
        chargePrice: state.appState.chargePrice,//支付金额
        chargeConfirmDialog: state.appState.chargeConfirmDialog,//支付金额
        rechargeOrderId: state.appState.rechargeOrderId,//支付订单号
    }
}

export default connect(mapStateToProps)(Recharge);