import React, {Component} from 'react';
import {Router, Route, Link, hashHistory} from 'react-router';
import {bindActionCreators} from 'redux';
import {connect} from 'react-redux';

import {Banner, Tabs, Tab, SwipeableViews, VideoLists, Dialog, FlatButton, RaisedButton} from '../components';
import ActionSearch from 'material-ui/svg-icons/action/search';
import FaAlignJustify from 'react-icons/lib/fa/bars';

//actions
import {appAct, appAN, fetchData, wsAct} from '../actions';

//config
import {REQURL, CONFIG} from '../config';

const logo = require('../../images/logo.png');

class Home extends Component {


    static contextTypes = {
        router: React.PropTypes.object
    };

    constructor(props) {
        super(props)
        this.state = {
            showConfirmDateBox: false
        }
    }

    //加载今日精选数据
    loadVideosRec() {
        const {dispatch} = this.props;

        //https://api.github.com/users/mralexgray/repos
        dispatch(fetchData({
            url: REQURL.getVideoRec.url,
            requestType: REQURL.getVideoRec.type,
            successAction: appAN.UPDATE_VIDEO_LISTS_REC
        }));
    }

    shouldComponentUpdate(nextProps, nextState) {
        if (this.props != nextProps || this.state != nextState) {
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
        const {dispatch} = this.props;
        dispatch(appAct.openDialog(false));
    }

    changeTab(e) {
        const {dispatch} = this.props;
        //设置当期选择的tab值
        dispatch(appAct.setHomeTabIndex(e));
        //加载数据
        if (e == 1) {//大厅
            dispatch(fetchData({
                url: REQURL.getVideoAll.url,
                requestType: REQURL.getVideoAll.type,
                successAction: appAN.UPDATE_VIDEO_LISTS_ALL
            }));
        }
        else if (e == 2) {//大秀场
            dispatch(fetchData({
                url: REQURL.getVideoSls.url,
                requestType: REQURL.getVideoSls.type,
                successAction: appAN.UPDATE_VIDEO_LISTS_SLS
            }));
        }
        else if (e == 3) {//一对一
            dispatch(fetchData({
                url: REQURL.getVideoOrd.url,
                requestType: REQURL.getVideoOrd.type,
                successAction: appAN.UPDATE_VIDEO_LISTS_ORD
            }));
        }
        else {//大厅
            this.loadVideosRec();
        }

    }


    /**
     * 进入房间
     */
    enterRoom(room) {
        const {router} = this.context;
        const {dispatch, isLogin, videoListsOrd} = this.props;

        //设置选中房间号
        dispatch(appAct.setCurrentSelectRoomId(room.uid));
        console.log("room-----------", room);
        if (room.appoint_state && (room.appoint_state == 1 || room.appoint_state == 3)) {

            if (!isLogin) {
                dispatch(appAct.showInfoBox("您尚未登陆,请登陆后 再 进行预约", 'error'))
            }
            else {
                this.lastDateRoom = room;
                this.setState({showConfirmDateBox: true});
            }
        }
        else {

            if (room.tid == 2) {//该房间需要密码才能进入
                dispatch(appAct.openDialog(true));
            }
            else {
                router.push({
                    pathname: '/video/' + room.uid,
                    query: {from: '/'}
                })
            }
        }
    }

    confirmDateRoom = (room) => {
        if (!room) return;
        const {dispatch, videoListsOrd} = this.props;
        dispatch(fetchData({
            url: REQURL.dateTimeRoom.url + `?duroomid=${room.id}&flag=false`,
            requestType: REQURL.dateTimeRoom.type,
            callback: (data) => {
                if (data.code == 1) {
                    for (let item of videoListsOrd) {
                        if (item && (item.id == room.id)) {
                            item.appoint_state = "3";
                            dispatch({type: appAN.UPDATE_VIDEO_LISTS_ORD, data: {rooms: videoListsOrd}});
                        }
                    }
                }
                dispatch(appAct.showInfoBox(data.msg, 'error'));
            }
            // successAction: appAN.UPDATE_VIDEO_LISTS_REC
        }));
        this.setState({showConfirmDateBox: false});
    }

    /**
     * 进入密码房
     */
    enterPasswordRoom(room) {
        const {router} = this.context;
        const {dispatch, currSeleRoomId} = this.props;
        const {roomPwd} = this.refs;
        const rPwd = roomPwd.value.trim();
        roomPwd.blur();

        dispatch(fetchData({
            url: REQURL.checkroompwd.url,
            requestType: REQURL.checkroompwd.type,
            requestData: {
                roomid: currSeleRoomId,
                password: rPwd,
                captcha: ""
            },
            callback: function (res) {
                dispatch(appAct.openDialog(false));
                if (res.code == 1) {
                    //重置输入框数据
                    roomPwd.value = "";

                    //密码验证成功，跳转
                    router.push({
                        pathname: '/video/' + currSeleRoomId,
                        query: {from: '/'}
                    })
                } else {
                    //密码验证失败
                    dispatch(appAct.showInfoBox(res.msg, 'error'))
                }
            }
        }));
    }

    render() {
        const {slideIndex, videoListsAll, videoListsRec, videoListsSls, videoListsOrd, dialogOpen, drawerOpen, dispatch, location} = this.props;
        const {router} = this.context;
        console.log("this.state.showConfirmDateBox---", this.state.showConfirmDateBox)
        return (
            <div className="app-main-content">
                <Banner
                    title="台湾美媚-直播大厅"
                    currentPath="/home"
                    leftIcon={<FaAlignJustify className="menuIcon"/>}
                    leftIconTouch={() => dispatch(appAct.drawerToggle(!drawerOpen))}
                    drawerOpen={drawerOpen}
                    drawerClose={() => dispatch(appAct.drawerClose())}
                    //rightIcon={<ActionSearch />}
                    //rightIconTouch={()=>router.push('/search')}
                />
                <div className="appContent home">
                    <Tabs
                        onChange={ e => this.changeTab(e) }
                        value={ slideIndex }
                        className="tab"
                    >
                        <Tab label="精选" value={0} className={ slideIndex == 0 ? 'tab-selected' : ''}/>
                        <Tab label="全部" value={1} className={ slideIndex == 1 ? 'tab-selected' : ''}/>
                        <Tab label="特色" value={2} className={ slideIndex == 2 ? 'tab-selected' : ''}/>
                        <Tab label="预约" value={3} className={ slideIndex == 3 ? 'tab-selected' : ''}/>
                    </Tabs>
                    <SwipeableViews
                        //animateHeight={true}
                        onChangeIndex={ e => this.changeTab(e) }
                        index={ slideIndex }
                        className="swipHome"
                    >
                        <VideoLists data={videoListsRec} action={(d) => this.enterRoom(d)} key={0}/>
                        <VideoLists data={videoListsAll} action={(d) => this.enterRoom(d)} key={1}/>
                        <VideoLists data={videoListsSls} action={(d) => this.enterRoom(d)} key={2}/>
                        <VideoLists data={videoListsOrd} action={(d) => this.enterRoom(d)} key={3}/>
                    </SwipeableViews>
                </div>
                <Dialog
                    title="系统提示"
                    actions={[
                        <RaisedButton
                            label="确定"
                            primary={true}
                            keyboardFocused={true}
                            onTouchTap={() => this.enterPasswordRoom()}
                            style={{marginRight: 10}}/>,
                        <RaisedButton
                            label="取消"
                            onTouchTap={() => this.closeDialog()}
                        />
                    ]}
                    modal={true}
                    open={dialogOpen}
                    className="video-alertDialog"
                    titleClassName="dialog-title"
                    bodyClassName="dialog-body"
                    actionsContainerClassName="dialog-action">
                    <div className="video-alertDialog-title">该房间需要密码才能进入</div>
                    <input className="video-alertDialog-input" placeholder="请输入房间密码" ref="roomPwd"/>
             </Dialog>
                {
                    this.state.showConfirmDateBox ? <Dialog
                        title="你确定花费钻石进行预约吗?"
                        actions={[
                            <RaisedButton
                                label="确定"
                                primary={true}
                                keyboardFocused={true}
                                onTouchTap={() => {
                                    this.confirmDateRoom(this.lastDateRoom);
                                }}
                                style={{marginRight: 10}}/>,
                            <RaisedButton
                                label="取消"
                                onTouchTap={() => this.setState({showConfirmDateBox: false})}
                            />
                        ]}
                        modal={true}
                        open={true}
                        className="video-alertDialog"
                        titleClassName="dialog-title"
                        bodyClassName="dialog-body"
                        actionsContainerClassName="dialog-action"
                    /> : null
                }
            </div>
             )
    }


    componentDidMount() {
        const {dispatch} = this.props;
        //断开socket链接
        dispatch(wsAct.logout());
        //加载数据
        this.loadVideosRec();
    }
}

const mapStateToProps = state => {
    return {
        isLogin: state.appState.isLogin,
        slideIndex: state.appState.homeSlideIndex,
        videoListsAll: state.appState.videoListsAll,
        videoListsRec: state.appState.videoListsRec,
        videoListsSls: state.appState.videoListsSls,
        videoListsOrd: state.appState.videoListsOrd,
        dialogOpen: state.appState.dialogOpen,//弹出框
        drawerOpen: state.appState.drawerOpen,//菜单
        currSeleRoomId: state.appState.currSeleRoomId,//当前选中的房间号
        dialogDateOpen: state.appState.dialogDateOpen,//预约菜单
    }
}

export default connect(mapStateToProps)(Home);
