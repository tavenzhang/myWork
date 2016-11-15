import React, { Component } from 'react';
import { connect } from 'react-redux';

import { Banner, RaisedButton, Checkbox, TextField, Toolbar, ToolbarSeparator, ToolbarGroup, VideoLists, Dialog, FlatButton } from '../components';

//actions
import { appAct, appAN, fetchData } from '../actions';

//config
import { REQURL, CONFIG } from '../config';

class Search extends Component {

    search() {
        //加载数据
        const {dispatch} = this.props;
        const {searchInput} = this.refs;
        const nickname = searchInput.input.value;

        searchInput.blur();

        dispatch(fetchData({
            url : REQURL.search.url,
            requestType : REQURL.search.type,
            requestData : {"nickname": nickname, "pageStart": 1},
            successAction : appAN.SEARCH_VIDEO
        }));
    }

    static contextTypes = {
        router: React.PropTypes.object
    };

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

        const { videoLists, dialogOpen } = this.props;

        return (
            <div className="app-main-content">
                <Banner
                    title="搜索"
                    back="/"
                    />
                <div className="appContent">
                    <Toolbar className="search">
                        <ToolbarGroup className="search-box">
                            <TextField hintText="主播名字" type="search" fullWidth={true} ref="searchInput"/>
                            <ToolbarSeparator />
                            <RaisedButton
                                label="搜索"
                                primary={true}
                                className="search-btn"
                                onTouchTap={()=>this.search()}
                                />
                        </ToolbarGroup>
                    </Toolbar>
                    <div className="search-list">
                        <VideoLists data={videoLists} action={(d)=>this.enterRoom(d)} />
                    </div>
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
        videoLists: state.appState.searchVideoLists,
        dialogOpen: state.appState.dialogOpen,//弹出框
        currSeleRoomId: state.appState.currSeleRoomId,//当前选中的房间号
    }
}

export default connect(mapStateToProps)(Search);
