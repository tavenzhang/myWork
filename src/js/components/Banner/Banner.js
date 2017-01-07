/**
 * Created by soga on 16/9/20.
 */
import React, { Component, PropTypes } from 'react';
import { Link } from 'react-router';
import MenuItem from 'material-ui/MenuItem';
import AppBar from 'material-ui/AppBar';
import IconButton from 'material-ui/IconButton';
import Drawer from 'material-ui/Drawer';
import NavigationClose from 'material-ui/svg-icons/navigation/arrow-back';
import FlatButton from 'material-ui/FlatButton';
import Ipoweroff from 'react-icons/lib/fa/power-off';
import Isetting from 'react-icons/lib/fa/cog';
import Idiamond from 'react-icons/lib/fa/diamond';
//import  react-icons/lib/fa/question-circle
import {FaQuestionCircle} from 'react-icons/lib/fa'
//actions
import {fetchData,appAN} from '../../actions';

import {REQURL} from '../../config';

const MenuIcon = [
    require('../../../images/LeftListIcon01.png'),
    //require('../../../images/LeftListIcon02.png'),
    require('../../../images/LeftListIcon03.png'),
    require('../../../images/LeftListIcon04.png'),
    require('../../../images/LeftListIcon05.png'),
    require('../../../images/LeftListIcon06.png'),
    require('../../../images/MailIcon.png'),
    require('../../../images/ItemIcon.png'),
    require('../../../images/BillIcon.png'),
    require('../../../images/LoveIcon.png'),
    require('../../../images/ReservationIcon.png'),
    require('../../../images/SetIcon.png'),
]

const menus = [
    { title: '直播大厅', link:'/home', login:false },
    //{ title: '我的', link:'/user' },
    { title: '排行榜单', link:'/rank', login:false },
    { title: '砖石充值', link:'/recharge', login:true },
    { title: '道具商城', link:'/shop', login:false },
    { title: '活动中心', link:'/activity', login:false },
    { title: '联系客服', link:'', login:false },
    { title: '我的信箱', link:'/myMsg', login:true },
    { title: '我的道具', link:'/myMount', login:true },
    { title: '消费记录', link:'/myRecord', login:true },
    { title: '我的关注', link:'/myFav', login:true },
    { title: '我的预约', link:'/myOrd', login:true },

]

class Banner extends Component {

    static propTypes = {
        title : PropTypes.string,
        back : PropTypes.any,
        rightIcon : PropTypes.any,
        rightIconTouch : PropTypes.func
    };

    static defaultProps = {
        title : "标题",
        back : false,
        rightIcon : "",
        titleTP: "text"
    };

    static contextTypes = {
        router: React.PropTypes.object,
        isLogin: React.PropTypes.bool,
        userInfo: React.PropTypes.object,
        dispat: React.PropTypes.func,
    };

    goRegister() {
        const { drawerClose } = this.props;
        const {router} = this.context;

        drawerClose();
        router.push({
            pathname: '/register',
        });
    }

    goLogin() {
        const { drawerClose } = this.props;
        const {router} = this.context;
        drawerClose();
        router.push({
            pathname: '/login',
        });
    }

    goSetting() {
        const { drawerClose } = this.props;
        const {router} = this.context;
        drawerClose();
        router.push({
            pathname: '/mySetting',
        });
    }

    logout() {
        const {dispat} = this.context;
        const { drawerClose } = this.props;

        drawerClose();
        //请求退出接口
        dispat(fetchData({
            url : REQURL.logout.url,
            requestType : REQURL.logout.type,
            successAction: appAN.LOGOUT,
            callback: function(data) {
                console.log(data)
            }
        }));
    }

    render() {
        const { router, isLogin, userInfo } = this.context;
        const { back, title, titleTP, drawerClose, drawerOpen, leftIconTouch, currentPath } = this.props;
        let [rightIcon,leftIcon] = [<IconButton />,<IconButton />];
        if(back) {
            let backFunc = null;
            if(typeof back === "boolean") {
                backFunc = () => {
                    router.goBack();
                }
            }
            else {
                backFunc = () => {
                    router.push(back);
                }
            }
            leftIcon = <IconButton
                            onTouchTap={ ()=>backFunc() }
                            >
                            <NavigationClose />
                        </IconButton>
        }

        if(this.props.rightIcon) {
            rightIcon = <IconButton
                            onTouchTap={ this.props.rightIconTouch }
                            >
                            {this.props.rightIcon}
                        </IconButton>
        }

        if(this.props.leftIcon) {
            leftIcon = <IconButton
                onTouchTap={ this.props.leftIconTouch }
                >
                {this.props.leftIcon}
            </IconButton>
        }

        //栏目标题
        let bannerTitle = titleTP == "image" ? <img src={title} /> : title;

        ///////////////////////////////////////
        ///////////////个人信息
        ///////////////////////////////////////
        //头衔
        let [Iexp,Irich,Ivip,logout] = [null,null,null,null];

        //主播等级
        //roled=3为主播
        if(userInfo.lv_exp && userInfo.roled == 3) {
            const Iclass = `hotListImg AnchorLevel${userInfo.lv_exp}`;
            Iexp = <div className={Iclass}></div>
        }

        //财富等级
        if(userInfo.lv_rich > 1) {
            const Iclass = `lvRichIcon r${userInfo.lv_rich}`;
            Irich = <div className={Iclass}></div>
        }

        //贵族等级
        if(userInfo.vip > 0) {
            const Iclass = `hotListImg basicLevel${userInfo.vip}`;
            Ivip = <div className={Iclass}></div>
        }

        //当用户没任何等级和徽章
        if(Iexp == null && Irich == null && Ivip == null) {
            Iexp = "不详";
        }

        //头部信息
        let headerMsg = <div>
            <FlatButton label="注册" className="btn-register" onTouchTap={()=>this.goRegister()} />
            <FlatButton label="登录" className="btn-login" onTouchTap={()=>this.goLogin()} />
        </div>;

        if(isLogin && userInfo.uid) {//判断用户是否登陆
            headerMsg = <div>
                <h4>{userInfo.nickname}</h4>
                <h5>余额 {userInfo.points>0 ? userInfo.points : 0}<Idiamond className="icon blue" /></h5>
            </div>;
        }

        let userAvatar = <img src={userInfo.headimg} className="avatar" />
        //用户头像
        if(!userInfo.headimg) {
            userAvatar = <img src={require('../../../images/logo.png')} className="avatar-logo" />;
        }
        return (
            <AppBar
                title={ bannerTitle }
                iconElementLeft={leftIcon}
                iconElementRight={rightIcon}
                className='appBar'
                >
                <Drawer
                        docked={false}
                        width={200}
                        open={ drawerOpen }
                        onRequestChange={ () => drawerClose() }
                >
                    <div className="appContent drawer">
                        <div className="menu-header">
                            {userAvatar}
                            {headerMsg}
                        </div>
                        <div className="menu-lists">
                        {
                            menus.map((v,i) => {
                                const itemBg = currentPath == v.link ? 'active' : '';
                                if((!isLogin && v.login)) {
                                    return null;
                                }
                                if(v.title=="联系客服")
                                {
                                    return    <a key={i} href='http://v88.live800.com/live800/chatClient/chatbox.jsp?companyID=754482&configID=3517&jid=5432615048&lan=zh&subject=%E5%92%A8%E8%AF%A2&prechatinfoexist=1' target="_blank">
                                        <MenuItem
                                            className={`menu-item ${itemBg}`}
                                            leftIcon={<FaQuestionCircle color="#fff" className="menu-list-icon" />}
                                            onTouchTap={() => drawerClose()}>
                                            {v.title}
                                        </MenuItem>
                                    </a>
                                }
                                else{
                                    return <Link to={v.link} key={i}>
                                        <MenuItem
                                            className={`menu-item ${itemBg}`}
                                            leftIcon={<img src={MenuIcon[i]} className="menu-list-icon" />}
                                            onTouchTap={() => drawerClose()}>
                                            {v.title}
                                        </MenuItem>
                                    </Link>
                                }

                            })
                        }
                        </div>
                        { isLogin ? <div className="menu-bottom">
                            <span className="menu-bottom-btn" onTouchTap={()=>this.logout()}><Ipoweroff />退出</span>
                            <span className="menu-bottom-btn" onTouchTap={()=>this.goSetting()}><Isetting />设置</span>
                        </div> : null }
                    </div>
                </Drawer>
            </AppBar>
            )
    }};

//<AppBar title="菜单" className='appBar' />
//                        <Link to="/login" ><MenuItem className="menu-item" onTouchTap={() => drawerClose()}>退出登录</MenuItem></Link>

export default Banner;