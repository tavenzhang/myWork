import React, { Component } from 'react';
import { Router, Route, Link, hashHistory } from 'react-router';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import { Banner, Tabs, Tab, SwipeableViews, VideoLists, Dialog, FlatButton } from '../components';
import ActionSearch from 'material-ui/svg-icons/action/search';
import FaAlignJustify from 'react-icons/lib/fa/bars';

//actions
import { appAct, appAN, fetchData, wsAct } from '../actions';

//config
import { REQURL, CONFIG } from '../config';

const logo = require('../../images/logo.png');

class Home extends Component {

    componentDidMount() {
        const {dispatch} = this.props;

        //断开socket链接
        dispatch(wsAct.logout());
        //加载数据
        this.loadVideosRec();
    }

    static contextTypes = {
        router: React.PropTypes.object
    };

    //加载今日精选数据
    loadVideosRec() {
        const {dispatch} = this.props;

        //https://api.github.com/users/mralexgray/repos
        dispatch(fetchData({
            url : REQURL.getVideoRec.url,
            requestType : REQURL.getVideoRec.type,
            successAction : appAN.UPDATE_VIDEO_LISTS_REC
        }));
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

    changeTab(e) {
        const {dispatch} = this.props;
        //设置当期选择的tab值
        dispatch(appAct.setHomeTabIndex(e));
        //加载数据
        if( e == 1 ) {//大厅
            dispatch(fetchData({
                url : REQURL.getVideoAll.url,
                requestType : REQURL.getVideoAll.type,
                successAction : appAN.UPDATE_VIDEO_LISTS_ALL
            }));
        }
        else if( e == 2 ) {//大秀场
            dispatch(fetchData({
                url : REQURL.getVideoSls.url,
                requestType : REQURL.getVideoSls.type,
                successAction : appAN.UPDATE_VIDEO_LISTS_SLS
            }));
        }
        else if( e == 3 ) {//一对一
            dispatch(fetchData({
                url : REQURL.getVideoOrd.url,
                requestType : REQURL.getVideoOrd.type,
                successAction : appAN.UPDATE_VIDEO_LISTS_ORD
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
        const { router } = this.context;
        const { dispatch } = this.props;

        //设置选中房间号
        dispatch(appAct.setCurrentSelectRoomId(room.uid));

        if(room.enterRoomlimit == 1 && room.tid == 2) {//该房间需要密码才能进入
            dispatch(appAct.openDialog(true));
        }
        else {
            router.push({
                pathname: '/video/'+room.uid,
                query: { from: '/' }
            })
        }
    }

    /**
     * 进入密码房
     */
    enterPasswordRoom(room) {
        const { router } = this.context;
        const { dispatch, currSeleRoomId } = this.props;
        const {roomPwd} = this.refs;
        const rPwd = roomPwd.value.trim();

        roomPwd.blur();

        dispatch(fetchData({
            url : REQURL.checkroompwd.url,
            requestType : REQURL.checkroompwd.type,
            requestData : {
                roomid: currSeleRoomId,
                password: rPwd,
                captcha: ""
            },
            callback: function(res){
                if(res.code == 1){
                    //重置输入框数据
                    roomPwd.value = "";

                    dispatch(appAct.openDialog(false));

                    //密码验证成功，跳转
                    router.push({
                        pathname: '/video/'+currSeleRoomId,
                        query: { from: '/' }
                    })
                }else{
                    //密码验证失败
                    dispatch(appAct.showInfoBox(res.msg,'error'))
                }
            }
        }));
    }

    render() {

        let { slideIndex, videoListsAll, videoListsRec, videoListsSls, videoListsOrd, dialogOpen, drawerOpen, dispatch } = this.props;
        const { router } = this.context;

        return (
            <div className="app-main-content">
                <Banner
                    title="大厅"
                    leftIcon={<FaAlignJustify className="menuIcon" />}
                    leftIconTouch={()=>dispatch(appAct.drawerToggle(!drawerOpen))}
                    drawerOpen={drawerOpen}
                    drawerClose={()=>dispatch(appAct.drawerClose())}
                    //rightIcon={<ActionSearch />}
                    //rightIconTouch={()=>router.push('/search')}
                />
                <div className="appContent home">
                    <Tabs
                        onChange = { e => this.changeTab(e) }
                        value = { slideIndex }
                        className="tab"
                    >
                        <Tab label="精选" value={0} />
                        <Tab label="大厅" value={1} />
                        <Tab label="特色" value={2} />
                        <Tab label="预约" value={3} />
                    </Tabs>
                    <SwipeableViews
                        //animateHeight={true}
                        onChangeIndex={ e =>this.changeTab(e) }
                        index={ slideIndex }
                        className="swipHome"
                    >
                        <VideoLists data={videoListsRec} action={(d)=>this.enterRoom(d)} key={0} />
                        <VideoLists data={videoListsAll} action={(d)=>this.enterRoom(d)} key={1} />
                        <VideoLists data={videoListsSls} action={(d)=>this.enterRoom(d)} key={2} />
                        <VideoLists data={videoListsOrd} action={(d)=>this.enterRoom(d)} key={3} />
                    </SwipeableViews>
                </div>
                <Dialog
                    title="系统提示"
                    actions={[
                        <FlatButton
                            label="确定"
                            primary={true}
                            keyboardFocused={true}
                            onTouchTap={()=>this.enterPasswordRoom()}
                            />,
                        <FlatButton
                            label="取消"
                            onTouchTap={()=>this.closeDialog()}
                            />
                    ]}
                    modal={true}
                    open={dialogOpen}
                    className="video-alertDialog"
                    >
                    <div className="video-alertDialog-title">该房间需要密码才能进入</div>
                    <input className="video-alertDialog-input" placeholder="请输入房间密码" ref="roomPwd" />
                </Dialog>
            </div>
        );
    }

}

const mapStateToProps = state => {
    return {
        slideIndex: state.appState.homeSlideIndex,
        videoListsAll: state.appState.videoListsAll,
        videoListsRec: state.appState.videoListsRec,
        videoListsSls: state.appState.videoListsSls,
        videoListsOrd: state.appState.videoListsOrd,
        dialogOpen: state.appState.dialogOpen,//弹出框
        drawerOpen: state.appState.drawerOpen,//菜单
        currSeleRoomId: state.appState.currSeleRoomId,//当前选中的房间号
    }
}

export default connect(mapStateToProps)(Home);
