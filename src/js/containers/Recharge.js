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

    constructor(props){
        super(props);
        this.state = {
            orderId: '',
        };
    }

    componentWillMount() {
        const {dispatch,payMethod,chargePrice} = this.props;

        dispatch(fetchData({
            url : "http://wytj.9vpay.com/PayBank.aspx",
            requestType : "GET",
            requestData : {
                'interface_code': payMethod,
                'charge_channel': 100049,
                'price': chargePrice
            },
            callback : function(data) {
                console.log("=======",data)
            }
        }));
    }

    handleRecharge() {
        const {dispatch,payMethod,chargePrice} = this.props;
        const state = this.state;

        dispatch(fetchData({
            url : REQURL.chargePay.url,
            requestType : REQURL.chargePay.type,
            requestData : {
                'interface_code': payMethod,
                'charge_channel': 100049,
                'price': chargePrice
            },
            callback : function(data) {
                console.log('0000',data);
                if(!data.status) {
                    //state.username = data.msg.order_id;

                    console.log('1111',data);
                    dispatch(fetchData({
                        url : data.msg.pay_url,
                        requestType : "GET",
                        requestData : data.msg.post_data,
                        callback : function(data) {
                            console.log('2222',data);

                            //显示弹出框
                            dispatch(appAct.showRechargeDialog(true));

                            window.open(data);
                        }
                    }));
                }
                else {
                    dispatch(appAct.showInfoBox('支付失败:'+data.msg,'error'));
                }
            }
        }));
    }

    confirmRecharge() {
        const {dispatch} = this.props;
        const {orderId} = this.state;

        dispatch(fetchData({
            url : REQURL.chargeCheck.url,
            requestType : REQURL.chargeCheck.type,
            requestData : {
                'order_id' : orderId
            },
            callback : function(data) {
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
                    title="砖石充值"
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
                        <MenuItem value={`WEIXINWAP`} primaryText="微信" />
                        <MenuItem value={`ZFBWAP`} primaryText="支付宝" />
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
                    title="充值确认"
                    actions={
                    [
                        <FlatButton
                            label="确认"
                            primary={true}
                            onTouchTap={()=>this.confirmRecharge()}
                        />,
                        <FlatButton
                            label="取消"
                            onTouchTap={()=>dispatch(appAct.showRechargeDialog(false))}
                        />
                        ]
                    }
                    modal={true}
                    open={chargeConfirmDialog}
                    titleClassName="dialog-title"
                    bodyClassName="dialog-body"
                    actionsContainerClassName="dialog-action"
                    overlayClassName="dialog-overlay"
                    >
                    您已充值{chargePrice}元！
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
    }
}

export default connect(mapStateToProps)(Recharge);