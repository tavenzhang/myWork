import React, {Component} from 'react';
import { connect } from 'react-redux';
import ReactDOM from 'react-dom';
import request from 'superagent'
import { Link } from 'react-router';

//聊天窗口头部
import NavigationClose from 'react-icons/lib/fa/times-circle';
import { RaisedButton, TextField, Toolbar, ToolbarSeparator, ToolbarGroup, Tabs, Tab, SwipeableViews, AudienceList, ChatList, RoomMsg, GiftRank, FlatButton, Dialog, RoomGiftPanel, UserMount, GiftEffect, VideoBox } from '../components';

import Igift from 'react-icons/lib/fa/gift';
import Idiamond from 'react-icons/lib/fa/diamond';
import { getCookie, rnd, log } from '../utils/util';

//action
import { wsAct, appAct, fetchData, wsAN } from '../actions';

import { REQURL, CONFIG } from '../config';

const getSocketAddress = (host,port) => {
    return "ws://"+host+":"+port+"/ws";
};

let intervalTasks = []; //定时任务名字
let intervalTimes = 15000; //定时任务时间
let test = null;
let haveBestUrl = false; //是否选了最优的下播
let haveBestWS = false; //是否选了最优的socket
let testWSTask = [];//socket测试任务
let isAlertLogin = false;//是否显示没登陆警告

//清楚任务
const clearIntervalTask = () => {
    for(let name in intervalTasks) {
        clearInterval(intervalTasks[name])
    }
}

class Video extends Component {

    constructor(props){
        super(props);
        this.isLogin          = this.isLogin.bind(this);
        this.connectSocket    = this.connectSocket.bind(this);
        this.sendMsg          = this.sendMsg.bind(this);
        this.getUid           = this.getUid.bind(this);
        //this.setBestVideoUrl  = this.setBestVideoUrl.bind(this);
        this.loginoutAct      = this.loginoutAct.bind(this);
    }

    componentWillMount() {
        //加载数据
        const {dispatch,showVideo,gifts} = this.props;

        if(!showVideo) {
            dispatch(wsAct.showVideo(true));
        }

        //链接socket
        const connSocket = this.connectSocket;

        const getUidApp = this.getUid;

        //链接socket
        connSocket();

        //获取礼物数据
        if(!gifts.length) {
            dispatch(fetchData({
                url : REQURL.getGifts.url,
                requestType : REQURL.getGifts.type,
                requestModel : REQURL.getGifts.model,
                successAction : wsAN.UPDATE_GIFTS
            }));
        }

        //定时10分钟执行请求一次session，防止网站过期
        this.requestInteval = setInterval(()=>{
            getUidApp();
        },1000 * 60 * 5);
    }

    componentWillUnmount() {
        this.timer && clearTimeout(this.timer);
        this.requestInteval && clearInterval(this.requestInteval);
    }

    componentDidMount() {
        const {dispatch,isLogin} = this.props;
        for  (let index in document.body.children)
        {
            let item=document.body.children[index];
            if(item.children&&item.children[0]&&item.children[0].id=="754482live8003517")
            {
                var div=item.children[0];
                div.style.display="none";
                this.check=true;
            }
        }
    }

    componentDidUpdate() {
        const {dispatch,videoUrls,seleVideoSrc,isLogin} = this.props;
        //设置聊天窗口最新消息一直在最下边
        this.refs.chatBox.parentNode.scrollTop = 99999999;

        //const setBestVideoUrlFunc = this.setBestVideoUrl;

        const setBestVideoUrl = url => {
            const {dispatch} = this.props;
            if(!haveBestUrl) {
                log("当前选择的url",url)
                haveBestUrl = true;
                dispatch(wsAct.getVideoUrl(url))
            }
        }

        //获取视频地址
        if(videoUrls.length > 0 && seleVideoSrc.length == 0) {
            videoUrls.map((d,i)=>{
                const urlData = d.split("@@")[0];
                const urlHost = urlData.substr(0,urlData.lastIndexOf("/"));
                let pic = document.createElement('img');
                //请求服务器上一个小文件，看哪个返回最快
                pic.src = urlHost + "/speed.jpg";
                pic.onload = function(e,v){
                    pic = null;
                    setBestVideoUrl(urlData);
                }
            })

        }

        //没登陆用户5分钟后移除视频框，弹出登录框
        if(!isLogin && seleVideoSrc.length >= 1) {
            if(!isAlertLogin) {
                isAlertLogin = true;
                setTimeout(function(){
                    dispatch(wsAct.showVideo(false));
                    dispatch(wsAct.showAlertDialog(true,'用户登录后才能继续观看',9));
                },5*60*1000)
            }
        }
    }

    /**
     * 连接socket
     */
    connectSocket() {
        const {dispatch,params,socketConnect} = this.props;
        //const rommid = location.query.rommid;//房间号
        const roomid = parseInt(params.id);//房间号
        //const roomid = 1000014;
        //链接socket
        //移动版：139.59.240.47   一般请求：20036  聊天：20037  送礼：20038

        if(!socketConnect) {
            //获取socket地址
            dispatch(fetchData({
                url : REQURL.socketAddr.url,
                requestData : { rid : roomid},
                requestType : REQURL.socketAddr.type,
                requestModel : REQURL.socketAddr.model,
                callback: function(data) {
                    if(data && data.ret == 1) {
                        let mcHosts = data.host.split(",");

                        //连接socket
                        const conn = (wsHost) => {
                            if(!haveBestWS) {
                                haveBestWS = true;
                                testWSTask = [];
                                dispatch(wsAct.connect(getSocketAddress(wsHost,data.mcMainPort),{
                                    type : 'common',
                                    roomid : roomid,
                                    callback : function(e) {
                                        //通用socket登陆后，根据返回的extck值，登陆聊天和送礼socket
                                        //聊天socket
                                        //心跳定时任务
                                        intervalTasks['comm'] = setInterval(function() {
                                            dispatch(wsAct.heart('comm'))
                                        },intervalTimes)

                                        dispatch(wsAct.connect(getSocketAddress(wsHost,data.mcChatPort),{
                                            type : 'chat',
                                            extck: e,
                                            callback: function() {
                                                //心跳定时任务
                                                intervalTasks['chat'] = setInterval(function() {
                                                    dispatch(wsAct.heart('chat'))
                                                },intervalTimes)
                                            }
                                        }));
                                        //送礼socket
                                        dispatch(wsAct.connect(getSocketAddress(wsHost,data.mcGiftPort),{
                                            type : 'gift',
                                            extck: e,
                                            callback: function() {
                                                //心跳定时任务
                                                intervalTasks['gift'] = setInterval(function() {
                                                    dispatch(wsAct.heart('gift'))
                                                },intervalTimes)
                                            }
                                        }));
                                    }
                                }));
                            }
                        }

                        mcHosts.map((v,i) => {
                            testWSTask[i] = new WebSocket(getSocketAddress(v,data.mcMainPort))
                            testWSTask[i].onopen = function(event) {
                                conn(v);
                                //关闭连接
                                this.close();
                            }
                        })
                    }
                }
            }));
        }
    }

    reConnectSocket() {
        const {dispatch} = this.props;
        //初始化房间内信息
        dispatch(wsAct.resetWsState());
        //重连socket
        this.connectSocket();
    }


    /**
     * 请求用户数据，防止网站过期
     */
    getUid(callback) {
        request(REQURL.getUid.url)
            .withCredentials()
            .end(function (e, res) {
                if(res && res.ok) {
                    const data = JSON.parse(res.text);
                    console.log(data.uid)
                }
                else {
                    console.log("登陆过期")
                }

                //回调
                if(callback) {
                    callback();
                }
            });
    }

    /**
     * 发消息
     * @param e
     */
    sendMsg(e) {
        //e.preventDefault();
        const {dispatch} = this.props;

        const {chatInput} = this.refs;

        const sendMsg = chatInput.getValue().trim();

        chatInput.blur();

        if(this.isLogin()) {//是否登录
            if(sendMsg) {
                dispatch(wsAct.postMessage(sendMsg));
                //重置输入框数据
                this.refs.chatInput.input.value = "";
            }
            else {
                dispatch(appAct.showInfoBox('聊天内容不能为空','error'))
            }
        }
        else {
            dispatch(wsAct.showAlertDialog(true,'用户登录后才能进行聊天',9));
        }
    }

    /**
     * 显示礼物对话框
     */
    showGift() {
        const { dispatch } = this.props;
        if(this.isLogin()) { //判断用户是否登录
            dispatch(wsAct.openGiftDialog(true));
        }
        else {
            dispatch(wsAct.showAlertDialog(true,'用户登录后才能送礼',9));
        }
    }

    /**
     * 送礼物
     */
    sendGift() {
        const { dispatch, currentSeleGift, params } = this.props;

        const {giftNum} = this.refs;

        giftNum.blur();

        if(currentSeleGift) {
            const roomid = parseInt(params.id);//房间号
            //const roomid = 1000014

            const giftData = {
                gnum : parseInt(giftNum.value) || 1,
                gid : currentSeleGift,
                uid : roomid,//主播id
                cmd : 40001 //请求报文
            };
            //console.log(giftData)
            dispatch(wsAct.sendGift(giftData));
            //关闭礼物框
            dispatch(wsAct.openGiftDialog(false));
        }
        else {
            dispatch(appAct.showInfoBox('请先选择礼物','error'));
        }
    }

    //判断用户是否已登录
    isLogin() {
        const { uid, isLogin} = this.props;
        if(uid && isLogin) {
            return true;
        }
        else {
            return false;
        }
    }

    //去登陆页面
    goLogin() {
        const {router} = this.context;
        const {dispatch,params} = this.props;
        const rommid = params.id;//房间号

        this.loginoutAct();

        //关闭对话框
        dispatch(wsAct.showAlertDialog(false,''));

        router.push({
            pathname: '/login',
            query: { from: '/video/'+rommid },
        });
    }

    //返回来源
    backhome() {
        const {router} = this.context;
        const {location} = this.props;

        this.loginoutAct();

        let backUrl = location.query.from ? location.query.from : "/";
        router.push(backUrl);
    }

    //退出房间操作
    loginoutAct() {
        const {dispatch} = this.props;

        //断开socket链接
        dispatch(wsAct.logout());

        //关闭socket心跳定时任务
        clearIntervalTask();

        //重置状态
        testWSTask = [];
        haveBestUrl = false;
        haveBestWS = false;
    }

    static contextTypes = {
        router: React.PropTypes.object
    };

    //切换聊天，送礼，房间信息等tab键
    //changeTab(e) {
    //    const {dispatch} = this.props;
    //    //设置当期选择的tab值
    //    dispatch(appAct.setVideoTabIndex(e));
    //}

    //切换礼物tab键
    //changeGiftTab(e) {
    //    const {dispatch} = this.props;
    //    //设置当期选择的tab值
    //    dispatch(wsAct.setGiftTabIndex(e));
    //}


    //设置当前选中的礼物id
    setCurrentSelectGift(gid) {
        const { dispatch } = this.props;
        dispatch(wsAct.setSeleGift(gid));
    }

    render() {
        const { dispatch, slideIndex, audiences, admins, messages, roomMsg, uid, todayGifts, gifts, openGiftDialog, slideGiftIndex, currentSeleGift, alertDialog, money, userMount, sendGifts, seleVideoSrc, showVideo, moneyTotal } = this.props;

        //判断socket是否连接，没连接的时候，再次连接
        //if(!socketConnect) {
        //    this.connectSocket();
        //}

        //弹出框内容
        let dialogContent = alertDialog.content;
        let dialogDesc = null;

        //礼物弹出框的actions
        const actions = [
            <div className="gift-actions-desc">
                余额：{money}<Idiamond className="Idiamond" />
            </div>,
            <input
                type="nunber"
                className="send-gift-num"
                defaultValue="1"
                ref="giftNum"
                />,
            <RaisedButton
                label="赠送"
                primary={true}
                onTouchTap={()=>this.sendGift()}
            />,
            <FlatButton
                label="取消"
                primary={true}
                id="btnGiftBoxCancel"
                onTouchTap={()=>dispatch(wsAct.openGiftDialog(false))}
                />,
        ];

        //提示登录注册的actions
        let alertActions = [
            <RaisedButton
                label="登录"
                primary={true}
                onTouchTap={()=>this.goLogin()}
                />,
            <FlatButton
                label="取消"
                primary={true}
                onTouchTap={()=>dispatch(wsAct.showAlertDialog(false,''))}
                />,
        ];

        if(alertDialog.type == 1) {//普通弹出框
            alertActions = [
                <RaisedButton
                    label="知道了"
                    primary={true}
                    onTouchTap={()=>dispatch(wsAct.showAlertDialog(false,''))}
                    />,
                <FlatButton
                    label="刷新页面"
                    primary={true}
                    onTouchTap={()=>{location.reload()}}
                    />,
                <FlatButton
                    label="重新连接"
                    primary={true}
                    keyboardFocused={true}
                    onTouchTap={()=>this.reConnectSocket()}
                    />,
            ];
        }

        if(alertDialog.type == 5) {//只有关闭按钮的提示框
            alertActions = [
                <RaisedButton
                    label="知道了"
                    primary={true}
                    onTouchTap={()=>dispatch(wsAct.showAlertDialog(false,''))}
                    />
            ];
        }

        if(alertDialog.type == 6) {//动态内容窗口
            let winers = "";

            if(alertDialog.content.items) {
                alertDialog.content.items.map((v,i)=>{
                    winers += v.name + "、";
                })
            }

            dialogContent = `恭喜以下用户中奖： ${winers.substr(0,winers.length-1)}`;
            dialogDesc = "奖品：" + alertDialog.content.detail;

            alertActions = [
                <RaisedButton
                    label="知道了"
                    primary={true}
                    onTouchTap={()=>dispatch(wsAct.showAlertDialog(false,''))}
                    />
            ];
        }

        //视频资源地址
        let [video,zhubo] = [null,null];
        if(seleVideoSrc.length > 0) {
            const zhuboMsg = seleVideoSrc[0];

            const videoSrc = `${zhuboMsg['rtmp'] +"/" + zhuboMsg['sid'] + "_ff.m3u8"}`;
            video = <video id="live" controls="control" preload="auto" autoPlay="autoplay" ref="video">
                <source src={videoSrc} type="video/mp4" />
            </video>;

            //主播信息
            const lvIcon = `hotListImg AnchorLevel${zhuboMsg.lv}`;
            const headimg = zhuboMsg.headimg ? CONFIG.imageServe + zhuboMsg.headimg + "?w=100&h=100" : require('../../images/avatar_default.png');

            zhubo = <div className="chat-zhubo">
                        <img src={headimg} className="avatar" />
                        <span>{zhuboMsg.name} <div className={lvIcon}></div></span>
                    </div>
        }

        //http://138.68.15.248:8082/proxypublish/14003603889387020|4882FBC7DCA5885FC90A722352424034_ff.m3u8

        return (
            <div className="app-main-content">
                <NavigationClose className="video-backIcon" onTouchTap={ ()=>this.backhome() } />
                {zhubo}
                <UserMount data={userMount} />
                <GiftEffect data={sendGifts}  />

                <div className="room-chat" ref="chatBox">
                    <ChatList data={messages} uid={uid} />
                </div>

                <div className="video-box">
                    <div className="liveBg">{ showVideo ? video : null}</div>
                </div>
                <Toolbar className="video-chatPanel">
                    <Igift className="btnGift" onClick={()=>this.showGift()} />
                    <ToolbarGroup className="send-box">
                        <TextField hintText="快跟主播聊天互动吧" fullWidth={true} ref="chatInput" className="chat-input input" />
                        <RaisedButton label="发送" primary={true} className="send-btn" onTouchEnd={e=>this.sendMsg(e)} />
                    </ToolbarGroup>
                </Toolbar>

                <Dialog
                    //title={}
                    actions={actions}
                    modal={false}
                    open={openGiftDialog}
                    onRequestClose={()=>dispatch(wsAct.openGiftDialog(false))}
                    autoScrollBodyContent={true}
                    contentClassName="giftBox"
                    bodyClassName="giftBoxBody"
                    >
                    <Tabs
                        onChange = { e =>dispatch(wsAct.setGiftTabIndex(e)) }
                        value = { slideGiftIndex }
                        className="tab giftBoxTitle"
                        >
                        {
                            gifts.map((v,i) => {
                                return <Tab label={v.name} value={i} key={i} className={ slideGiftIndex == i ? 'tab-selected' : ''} />
                            })
                        }
                    </Tabs>
                    <SwipeableViews
                        index={ slideGiftIndex }
                        className="giftBoxContent"
                        onChangeIndex = { e =>dispatch(wsAct.setGiftTabIndex(e)) }
                        >
                        {
                            gifts.map((v,i) => {
                                return <RoomGiftPanel
                                        key={i}
                                        data={v.items}
                                        selectGift={e=>this.setCurrentSelectGift(e)}
                                        currentSeleGift={currentSeleGift}
                                    />
                            })
                        }
                    </SwipeableViews>
                </Dialog>
                <Dialog
                    title={alertDialog.title || '系统提示'}
                    actions={alertActions}
                    modal={false}
                    open={alertDialog.show}
                    titleClassName="dialog-title"
                    bodyClassName="dialog-body"
                    actionsContainerClassName="dialog-action"
                    >
                    {dialogContent}
                    <div className="dialogDesc">{dialogDesc}</div>
                </Dialog>
            </div>
        )
    }
};

//<div className="video-banner">
//    <span className="hosterName">{hosterName}</span>
//</div>

const mapStateToProps = state => {
    return {
        isLogin : state.appState.isLogin,
        uid : state.appState.userInfo.uid || 0,
        money : state.appState.userInfo.points || 0,
        slideIndex : state.appState.videoSlideIndex,
        audiences : state.wsState.audiences,
        messages : state.wsState.messages,
        roomMsg : state.wsState.roomMsg,
        historyGifts : state.wsState.historyGifts,//历史贡献
        todayGifts : state.wsState.todayGifts,//当日贡献
        gifts : state.wsState.gifts,//礼物列表
        openGiftDialog : state.wsState.openGiftDialog,//是否弹出礼物列表
        slideGiftIndex : state.wsState.slideGiftIndex,//礼物选择tab
        videoUrls : state.wsState.videoUrls,//下播地址
        seleVideoSrc : state.wsState.seleVideoSrc,//当前选中的下播地址
        admins : state.wsState.admins,//管理员
        currentSeleGift : state.wsState.currentSeleGift,//当前选中的礼物值
        hosterName : state.wsState.hoster.name,//房间主播名字
        alertDialog : state.wsState.alertDialog,//弹出框信息
        socketConnect : state.wsState.socketConnect,//socket链接状态
        userMount : state.wsState.userMount,//坐骑用户进入房间
        sendGifts : state.wsState.sendGifts,//用户送的礼物
        showVideo : state.wsState.showVideo,//显示视频
        moneyTotal : state.wsState.moneyTotal,//本日总砖石数
    }
}

export default connect(mapStateToProps)(Video);