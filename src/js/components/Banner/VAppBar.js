import React, { Component, PropTypes } from 'react';
import { Link } from 'react-router';
import AppBar from 'material-ui/AppBar';
import IconButton from 'material-ui/IconButton';
import MenuItem from 'material-ui/MenuItem';
import Avatar from 'material-ui/Avatar';
import Drawer from 'material-ui/Drawer';

import ActionSearch from '../../../../node_modules/material-ui/svg-icons/action/search';
import { connect } from 'react-redux';

import { appAct } from '../actions';

export default class VAppBar extends Component {

    static propTypes = {
        title : PropTypes.string,
        avatar: PropTypes.string,
        onTouchTap: PropTypes.func.isRequired,
        drawerClose: PropTypes.func.isRequired,
        drawerOpen: PropTypes.bool,
    };

    static defaultProps = {
        title : "标题",
        avatar : "images/avatar.jpg",
        drawerOpen: false
    };

    handleLinkToSearch(){
        location.href = '#/search';
    }

    render() {
        const { drawerOpen, onTouchTap, title, avatar, drawerClose } = this.props;

        return(
            <AppBar
                title={ title }
                iconElementLeft={
                    <IconButton
                        className="appBar-avatar"
                        onTouchTap = { () => onTouchTap() }
                        >
                        <Avatar
                            src={ avatar }
                        />
                    </IconButton>
                }

                iconElementRight={
                    <IconButton
                        onTouchTap = { () => this.handleLinkToSearch() }
                    >
                        <ActionSearch />
                    </IconButton>
                }

                className='appBar'

            >
                <Drawer
                    docked={false}
                    width={200}
                    open={ drawerOpen }
                    onRequestChange={ () => drawerClose() }
                >
                    <AppBar title="菜单" className='appBar' />
                    <div className="appContent drawer">
                        <Link to="/home" ><MenuItem className="menu-item" onTouchTap={() => drawerClose()}>大厅</MenuItem></Link>
                        <Link to="/rank" ><MenuItem className="menu-item" onTouchTap={() => drawerClose()}>排行榜</MenuItem></Link>
                        <Link to="/activity" ><MenuItem className="menu-item" onTouchTap={() => drawerClose()}>活动</MenuItem></Link>
                        <Link to="/user" ><MenuItem className="menu-item" onTouchTap={() => drawerClose()}>个人中心</MenuItem></Link>
                        <Link to="/login" ><MenuItem className="menu-item" onTouchTap={() => drawerClose()}>退出登录</MenuItem></Link>
                    </div>
                </Drawer>
            </AppBar>

        )
    }
}
