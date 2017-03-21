import React, { Component } from 'react';
import { connect } from 'react-redux';

//let ReactCSSTransitionGroup = null;
//if(process.env.NODE_ENV === "development") {
//    ReactCSSTransitionGroup = require('react-addons-css-transition-group');
//}
//else {
//    ReactCSSTransitionGroup = React.addons.CSSTransitionGroup;
//}

//导入样式
import '../../style/main.less';
import {muiTheme} from './../theme';
import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider';
import injectTapEventPlugin from 'react-tap-event-plugin';
// Needed for onTouchTap
// http://stackoverflow.com/a/34015469/988941
injectTapEventPlugin();

//actions
import { appAct, fetchData, appAN } from '../actions';

import { getCookie, delCookie, setCookie } from '../utils/util';

import { REQURL } from '../config';

//组件
//import VAppBar from '../components/VAppBar';
import { Loading, Tabs, Tab, SwipeableViews } from '../components';
//Icon
import ActionHome from 'material-ui/svg-icons/action/home';
import ImageCamera from 'material-ui/svg-icons/image/camera';
//import SocialPerson from 'material-ui/svg-icons/social/person';
import ActionCamera from 'material-ui/svg-icons/action/camera-enhance';
import Itrophy from 'react-icons/lib/fa/trophy';
import Iuser from 'react-icons/lib/fa/user';

//提示盒子
import 'rc-notification/assets/index.css';
import Notification from 'rc-notification';
const notification = Notification.newInstance({});

class Main extends Component {
    constructor(props){
        super(props);
        this.changeRouter = this.changeRouter.bind(this);
        this.isConnect    = this.isConnect.bind(this);
        this.closeInfoBox = this.closeInfoBox.bind(this);
    }

    componentWillMount() {
        //加载数据
        const {dispatch,userInfo,location} = this.props;

        //判断用户是否登陆
        if(this.isConnect() &&userInfo&&!userInfo.uid){//当用户处在链接状态，并且状态基中userInfo的uid不存在时，请求用户数据
            console.log('uid',userInfo.uid)
            //console.log(location.pathname)
            //if(location.pathname.indexOf('/video') != 0) {
                //请求用户信息
                dispatch(fetchData({
                    url : REQURL.getUserInfo.url,
                    requestType : REQURL.getUserInfo.type,
                    successAction: appAN.UPDATE_USERINFO,
                    callback: function(data) {
                        if(!data.info.uid) { //当请求返回没有用户数据时，清空cookie值和状态基isLogin为false
                            //重置状态基
                            dispatch(appAct.logout());
                            //清空cookie
                            delCookie('webuid');
                            //delCookie('v_remember_encrypt');
                            //delCookie('PHPSESSID');
                        }
                    }
                }));
            //}
        }
    }

    componentDidMount() {
        //隐藏加载动画
        const loadPanel = document.getElementById('loadAnim');
        loadPanel.className += " loadHidden";
    }

    componentDidUpdate() {
        const {infoBox} = this.props;
        const closeIB = this.closeInfoBox;
        if(infoBox.show) {
            notification.notice({
                content: <span>{infoBox.msg}</span>,
                onClose() {
                    closeIB();
                },
            });
        }
    }

    /**
     * 判断用户是否链接
     * @returns {boolean}
     */
    isConnect() {
        const {dispatch,isLogin} = this.props;
        if(isLogin || !!getCookie('webuid') /*|| !!getCookie("v_remember_encrypt") || !!getCookie("PHPSESSID")*/ ) {
            if(!isLogin) {//当用户处于连接状态，但是状态基是断开状态，重新设置连接
                dispatch(appAct.login());
            }
            return true;
        }
        else {
            return false;
        }
    }

    static contextTypes = {
        router: React.PropTypes.object,
    };

    static childContextTypes = {
        isLogin: React.PropTypes.bool,
        userInfo: React.PropTypes.object,
        dispat: React.PropTypes.func,
    };


    getChildContext() {
        const { isLogin,userInfo,dispatch } = this.props;
        return {
            isLogin  : isLogin,
            userInfo  : userInfo,
            dispat : dispatch
        };
    }

    changeMenu(index) {
        const {dispatch} = this.props;
        dispatch(appAct.setMenuTabIndex(index));
        setCookie('menuSelectIndex',index);
    }

    /**
     * 切换路由
     * @param tab
     */
    changeRouter(tab) {
        const { router } = this.context;
        router.push(tab.props['data-route']);
        //cookie设置当前选中的tab值
    }

    /**
     * 关闭提示信息
     */
    closeInfoBox() {
        this.props.dispatch(appAct.closeInfoBox());
    }

    render() {
        let { location, isFatch, menuSelectIndex, children } = this.props;
        let [bottomTabs, appClass] = [null,'app-main'];

        //当menuSelectIndex=0时
        //读取cookie中设置的menuSelectIndex值，没有的话默认0，针对刷新页面时状态基中的值丢失处理
        //if(menuSelectIndex == 0) {
        //    //let cookieMenuSelectIndex = getCookie('menuSelectIndex');
        //    menuSelectIndex = parseInt(getCookie('menuSelectIndex')) || 0;
        //}

        return (
            <MuiThemeProvider muiTheme={muiTheme}>
                <div id="appMain">
                    <div className={appClass}>
                        {this.props.children}
                    </div>
                    <Loading show={isFatch} />
                </div>
            </MuiThemeProvider>
        )

    }
  
};


//{appBar}
//{this.props.children}
//<Loading show={isFatch} />

//<ReactCSSTransitionGroup
//    component="div"
//    transitionName="page"
//    transitionEnterTimeout={500}
//    transitionLeaveTimeout={500}
//    className="app-main">
//    {React.cloneElement(children, {
//        key: location.pathname
//    })}
//
//</ReactCSSTransitionGroup>

const mapStateToProps = state => {
    return {
        isFatch: state.fetchState.requesting,
        menuSelectIndex: state.appState.menuSelectIndex,
        infoBox: state.appState.infoBox,
        isLogin: state.appState.isLogin,
        userInfo: state.appState.userInfo
    }
}

export default connect(mapStateToProps)(Main);
