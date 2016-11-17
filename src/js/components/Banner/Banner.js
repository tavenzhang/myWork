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

const MenuIcon = [
    require('./../../../images/LeftListIcon01.png'),
    require('./../../../images/LeftListIcon02.png'),
    require('./../../../images/LeftListIcon03.png'),
    //require('./../../../images/LeftListIcon04.png'),
    require('./../../../images/LeftListIcon05.png'),
    require('./../../../images/LeftListIcon06.png')
]

const menus = [
    { title: '大厅', link:'/home' },
    { title: '我的', link:'/user' },
    { title: '排行', link:'/rank' },
    //{ title: '充值', link:'/recharge' },
    { title: '商城', link:'/shop' },
    { title: '活动', link:'/activity' },
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
        router: React.PropTypes.object
    };

    render() {
        const { router } = this.context;
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
                        {
                            menus.map((v,i) => {
                                const itemBg = currentPath == v.link ? 'active' : '';
                                return <Link to={v.link} key={i}>
                                            <MenuItem
                                                className={`menu-item ${itemBg}`}
                                                leftIcon={<img src={MenuIcon[i]} className="menu-list-icon" />}
                                                onTouchTap={() => drawerClose()}>
                                                {v.title}
                                            </MenuItem>
                                        </Link>
                            })
                        }
                    </div>
                </Drawer>
            </AppBar>
            )
    }};

//<AppBar title="菜单" className='appBar' />
//                        <Link to="/login" ><MenuItem className="menu-item" onTouchTap={() => drawerClose()}>退出登录</MenuItem></Link>

export default Banner;