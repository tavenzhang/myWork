/**
 * Created by soga on 16/9/20.
 */
import React, { Component } from 'react';
import { Link } from 'react-router';
import { connect } from 'react-redux';

import { Banner, ContentPanel, Divider, List, ListItem, RaisedButton, Checkbox, TextField, FlatButton, UserMenuItem } from '../components';

//import ContentInbox from 'material-ui/svg-icons/content/inbox';
import ActionGrade from 'material-ui/svg-icons/action/grade';
//import ContentSend from 'material-ui/svg-icons/content/send';
//import ContentDrafts from 'material-ui/svg-icons/content/drafts';
import Istar from 'react-icons/lib/fa/star';
import Iheart from 'react-icons/lib/fa/heart';
import Ipoweroff from 'react-icons/lib/fa/power-off';
import Isetting from 'react-icons/lib/fa/cog';
import Icartplus from 'react-icons/lib/fa/cart-plus';
import Icny from 'react-icons/lib/fa/cny';
import Imail from 'react-icons/lib/fa/envelope';
import Ifighter from 'react-icons/lib/fa/fighter-jet';
import Iangleright from 'react-icons/lib/fa/angle-right';
import Idiamond from 'react-icons/lib/fa/diamond';
import Iedit from 'react-icons/lib/fa/edit';
import FaAlignJustify from 'react-icons/lib/fa/bars';

//actions
import {appAct,fetchData,appAN} from '../actions';

import {CONFIG,REQURL} from '../config';
//import { encode } from '../utils/util';

const menuIcon = [
    require('../../images/MailIcon.png'),
    require('../../images/ItemIcon.png'),
    require('../../images/BillIcon.png'),
    require('../../images/LoveIcon.png'),
    require('../../images/ReservationIcon.png'),
    require('../../images/SetIcon.png'),
];

const menuItems = [
    { title: '我的信箱', link: 'myMsg' },
    { title: '我的道具', link: 'myMount' },
    { title: '消费记录', link: 'myRecord' },
    { title: '我的关注', link: 'myFav' },
    { title: '我的预约', link: 'myOrd' },
    { title: '设置', link: 'mySetting' },
]

class UserInfo extends Component {

    constructor(props){
        super(props);
        this.logout    = this.logout.bind(this);
    }

    componentWillMount() {
        //加载数据
        const {dispatch} = this.props;
        //当用户处在链接状态，并且状态基中userInfo的uid不存在时
    }

    static contextTypes = {
        router: React.PropTypes.object
    };

    //退出登陆
    logout() {
        const {dispatch} = this.props;
        //请求退出接口
        dispatch(fetchData({
            url : REQURL.logout.url,
            requestType : REQURL.logout.type,
            successAction: appAN.LOGOUT,
            callback: function(data) {
                console.log(data)
            }
        }));
    }

    //显示详细页面
    showDetail(page) {
        const { isLogin, userInfo, dispatch } = this.props;
        const {router} = this.context;

        if(isLogin && userInfo.uid) {//判断用户是否登陆
            router.push({
                pathname: page,
                //query: { from: location.query.from }
            });
        }
        else {
            dispatch(appAct.showInfoBox('登陆后才能操作','error'));
        }
    }

    /**
     * 去编辑页
     */
    //goEdit() {
    //    const {router} = this.context;
    //    router.push({
    //        pathname: '/userEdit',
    //    });
    //}

    render() {
        const { isLogin, userInfo, drawerOpen, dispatch } = this.props;
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

        //头部banner
        let banner = <Banner
                        title="我的"
                        currentPath="/user"
                        leftIcon={<FaAlignJustify className="menuIcon" />}
                        leftIconTouch={()=>dispatch(appAct.drawerToggle(!drawerOpen))}
                        drawerOpen={drawerOpen}
                        drawerClose={()=>dispatch(appAct.drawerClose())}
                    />;

        //头部信息
        let headerMsg = <div>
                    <Link to="/register"><FlatButton label="注册" className="btn-register" /></Link>
                    <Link to="/login"><FlatButton label="登录" className="btn-login" /></Link>
                </div>;

        if(isLogin && userInfo.uid) {//判断用户是否登陆
            headerMsg = <div>
                <h4>{userInfo.nickname}</h4>
                <h5>余额 {userInfo.points>0 ? userInfo.points : 0}<Idiamond className="icon blue" /></h5>
            </div>;

            //退出按钮
            logout = <ListItem primaryText="退出登录"
                           leftIcon={<Ipoweroff className="iconUP red" />}
                           onClick={()=>this.logout()}
                     />

            //头部banner
            //banner = <Banner
            //        title="我的"
            //        rightIcon={<Iedit className="banner-right-iconBtn" />}
            //        rightIconTouch={()=>this.goEdit()}
            //    />
        }

        let userAvatar = <img src={userInfo.headimg} className="avatar" />
        //用户头像
        if(!userInfo.headimg) {
            userAvatar = <img src={require('../../images/logo.png')} className="avatar-logo" />;
        }

        return (
            <div className="app-main-content">
                {banner}
                <div className="appContent">
                    <div className="user-header">
                        <div className="user-header-main">
                            {userAvatar}
                            {headerMsg}
                        </div>
                    </div>
                    <div className="user-main">
                        <div className="listPanel">
                            {
                                menuItems.map((v,i) =>
                                    <UserMenuItem
                                        key={i}
                                        title={v.title}
                                        icon={menuIcon[i]}
                                        onTouchTap={()=>this.showDetail(v.link)}
                                        />
                                )
                            }
                        </div>
                    </div>
                </div>
            </div>
        );
    }

}


const mapStateToProps = state => {
    return {
        isLogin : state.appState.isLogin,
        userInfo : state.appState.userInfo,
        drawerOpen: state.appState.drawerOpen,//菜单
    }
}

export default connect(mapStateToProps)(UserInfo);
