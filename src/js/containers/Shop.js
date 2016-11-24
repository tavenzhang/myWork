/**
 * Created by soga on 16/9/21.
 */
import React, { Component } from "react";
import { connect } from 'react-redux';
import { Link } from 'react-router';

import { Banner, ShopGiftPanel, Dialog, SwipeableViews, Tabs, Tab, FlatButton, RaisedButton } from '../components';
import Imoney from 'react-icons/lib/fa/cny'

//actions
import { appAct, appAN, fetchData } from '../actions';

import { REQURL } from './../config'

import { isEmptyObj } from '../utils/util'

import FaAlignJustify from 'react-icons/lib/fa/bars';


class Shop extends Component{

    static contextTypes = {
        router: React.PropTypes.object
    };

    constructor(props){
        super(props);
        this.closeDialog    = this.closeDialog.bind(this);
    }

    componentWillMount() {
        //加载数据
        const {dispatch, mounts, vipmount, vipIcons } = this.props;
        if(mounts.length == 0 || vipmount.length == 0 || vipIcons.length == 0) {
            dispatch(fetchData({
                url : REQURL.getShops.url,
                requestType : REQURL.getShops.type,
                successAction: appAN.UPDATE_SHOPS
            }));
        }
    }

    changeTab(e) {
        const {dispatch} = this.props;
        //设置当期选择的tab值
        dispatch(appAct.setShopTabIndex(e));
    }

    showDialog() {
        const { dispatch } = this.props;
        dispatch(appAct.openDialog(true));
    }

    shouldComponentUpdate(nextProps,nextState) {
        if(this.props != nextProps) {
            return true
        }
        else {
            return false
        }
    }

    /**
     * 关闭弹出框
     */
    closeDialog() {
        const { dispatch } = this.props;
        dispatch(appAct.openDialog(false));
    }

    /**
     * 立即登录
     */
    gotologin() {
        const {router} = this.context;
        //this.closeDialog();
        router.push({
            pathname: '/login',
            query: { from: '/shop' },
            state: { fromDashboard: true }
        });
    }

    /**
     * 去充值页
     */
    goRecharge() {
        const {router} = this.context;
        router.push({
            pathname: '/recharge',
        });
    }

    /**
     * 购买坐骑
     */
    buyMounts(gid) {
        const {dispatch} = this.props;
        const closeDia = this.closeDialog;

        dispatch(fetchData({
            url : REQURL.payMount.url,
            requestType : REQURL.payMount.type,
            requestData : {
                gid: gid,
                nums: 1,//数量
                type: 0//0是按月支付，1是包年
            },
            //successAction: appAN.UPDATE_SHOPS
            callback :function(d) {
                //console.log(d)
                //显示信息
                if(d.ret) {//成功
                    dispatch(appAct.showInfoBox(d.info),'success');
                }
                else {
                    dispatch(appAct.showInfoBox(d.info,'error'));
                }
                //关闭弹出框
                closeDia();
            }
        }));
    }

    /**
     * 开通vip
     * @param id
     */
    buyVIP(gid) {
        const {dispatch} = this.props;
        const closeDia = this.closeDialog;

        dispatch(fetchData({
            url : REQURL.openVIP.url,
            requestType : REQURL.openVIP.type,
            requestData : {
                gid: gid,
                roomId: 0//房间id
            },
            callback :function(d) {
                //console.log(d)
                //显示信息
                if(d.code == 0) {//成功
                    dispatch(appAct.showInfoBox(d.info));
                }
                else {
                    dispatch(appAct.showInfoBox(d.msg,'error'));
                }
                //关闭弹出框
                closeDia();
            }
        }));
    }

    //获取vip坐骑
    getVIPMount(gid) {
        const {dispatch} = this.props;
        const closeDia = this.closeDialog;

        dispatch(fetchData({
            url : REQURL.getVIPMount.url,
            requestType : REQURL.getVIPMount.type,
            requestData : {
                mid: gid
            },
            callback :function(d) {
                //显示信息
                if(d.code == 0) {//成功
                    dispatch(appAct.showInfoBox(d.info));
                }
                else {
                    dispatch(appAct.showInfoBox(d.msg,'error'));
                }
                //关闭弹出框
                closeDia();
            }
        }));
    }

    /**
     * 显示坐骑弹出框
     */
    showMountsDialog(mount) {
        const {dispatch} = this.props;
        //设定当前弹出框的值
        dispatch(appAct.shopSelectGift(mount));
        //显示弹出框
        this.showDialog();
    }


    render(){

        let { slideIndex, mounts, vipmount, vipIcons, dialogOpen, userInfo, shopSelectItem, drawerOpen, dispatch } = this.props;

        //取消按钮
        const btnCancl = <FlatButton
                    label="取消"
                    onTouchTap={()=>this.closeDialog()}
                    />;

        //去充值页的button
        let btnGoRecharge = <FlatButton
            label="充值"
            primary={true}
            onTouchTap={()=>this.goRecharge()}
            />;

        //弹出框button
        let actions = [
            <FlatButton
                label="确认"
                primary={true}
                onTouchTap={()=>this.closeDialog()}
                />,
            btnCancl
        ];

        //弹出框内容
        let dialogContent = null;

        //普通坐骑页面
        //if(slideIndex == 0) {
        //    //按钮
        //    actions = [
        //        <FlatButton
        //            label="购买"
        //            primary={true}
        //            onTouchTap={()=>this.buyMounts()}
        //            />,
        //        btnGoRecharge
        //    ];
        //
        //    //内容
        //    dialogContent = this.showMountsDialog()
        //}

        //当选中的产品不为空时
        if(!isEmptyObj(shopSelectItem)) {
            if(slideIndex == 0) {//坐骑页
                actions = [
                    <RaisedButton
                        label="确认"
                        primary={true}
                        onTouchTap={()=>this.buyMounts(shopSelectItem.gid)}
                        />,
                    btnGoRecharge,
                    btnCancl
                ];
                dialogContent = <span>确认购买坐骑<span className="mark">{shopSelectItem.name}</span>?</span>
            }
            else if(slideIndex == 1) {//vip坐骑
                actions = [
                    <RaisedButton
                        label="确认"
                        primary={true}
                        onTouchTap={()=>this.getVIPMount(shopSelectItem.gid)}
                        />,
                    btnCancl
                ];
                dialogContent = <span>确认领取坐骑<span className="mark">{shopSelectItem.name}</span>?</span>
            }
            else {//购买vip
                actions = [
                    <RaisedButton
                        label="确认"
                        primary={true}
                        onTouchTap={()=>this.buyVIP(shopSelectItem.gid)}
                        />,
                    btnGoRecharge,
                    btnCancl
                ];
                dialogContent = <span>确认开通贵族<span className="mark">{shopSelectItem.level_name}</span>?</span>
            }
        }


        //用户没登陆
        if(!userInfo.uid) {
            //弹出框button
            actions = [
                <RaisedButton
                    label="登录"
                    primary={true}
                    onTouchTap={()=>this.gotologin()}
                    />,
                btnCancl
            ];

            dialogContent = "登录后才能操作";
        }



        return (
            <div className="app-main-content">
                <Banner
                    title="道具商城"
                    currentPath="/shop"
                    leftIcon={<FaAlignJustify className="menuIcon" />}
                    leftIconTouch={()=>dispatch(appAct.drawerToggle(!drawerOpen))}
                    drawerOpen={drawerOpen}
                    drawerClose={()=>dispatch(appAct.drawerClose())}
                />
                <div className="appContent activity">
                    <Tabs
                        onChange = { e => this.changeTab(e) }
                        value = { slideIndex }
                        className="tab"
                        >
                        <Tab label="普通坐骑" value={0} className={ slideIndex == 0 ? 'tab-selected' : ''} />
                        <Tab label="贵族专属" value={1} className={ slideIndex == 1 ? 'tab-selected' : ''} />
                        <Tab label="开通贵族" value={2} className={ slideIndex == 2 ? 'tab-selected' : ''} />
                    </Tabs>
                    <SwipeableViews
                        index={ slideIndex }
                        onChangeIndex = { e => this.changeTab(e) }
                        className="swipSubPage"
                        >
                        <div className="shopGift" key={0}>
                            {mounts.map((d,i)=>{
                                const imgSrc = `/flash/image/gift_material/${d.gid}.png`;
                                return <ShopGiftPanel
                                            key={i}
                                            imgSrc={imgSrc}
                                            name={d.name}
                                            price={d.price}
                                            //pid={d.gid}
                                            btnClick={()=>this.showMountsDialog(d)}
                                        />
                            })}
                        </div>
                        <div className="shopGift" key={1}>
                            {vipmount.map((d,i)=>{
                                const imgSrc = `/flash/image/gift_material/${d.gid}.png`;
                                return <ShopGiftPanel
                                            key={i}
                                            imgSrc={imgSrc}
                                            name={d.name}
                                            price={d.price}
                                            btnName="领取"
                                            btnClick={()=>this.showMountsDialog(d)}
                                        />
                            })}
                        </div>
                        <div className="shopGift" key={2}>
                            {vipIcons.map((d,i)=>{
                                const imgSrc = `/flash/image/patrician_l/${d.level_id}.png`;
                                return <ShopGiftPanel
                                            key={i}
                                            imgSrc={imgSrc}
                                            name={d.level_name}
                                            price={d.system.open_money}
                                            btnClick={()=>this.showMountsDialog(d)}
                                        />
                            })}
                        </div>
                    </SwipeableViews>
                    <Dialog
                        title="购买道具"
                        actions={actions}
                        modal={true}
                        open={dialogOpen}
                        titleClassName="dialog-title"
                        bodyClassName="dialog-body"
                        actionsContainerClassName="dialog-action"
                        overlayClassName="dialog-overlay"
                        >
                        {dialogContent}
                    </Dialog>
                </div>
            </div>
        );
    }
}

const mapStateToProps = state => {
    return {
        slideIndex: state.appState.shopSelectIndex,
        mounts: state.appState.mounts,//坐骑
        vipmount: state.appState.vipmount,//贵族坐骑
        vipIcons: state.appState.vipIcons,//贵族勋章
        dialogOpen: state.appState.dialogOpen,//弹出框
        userInfo: state.appState.userInfo,//用户信息
        drawerOpen: state.appState.drawerOpen,//菜单
        shopSelectItem: state.appState.shopSelectItem,//当前选中的产品
    }
}

export default connect(mapStateToProps)(Shop);