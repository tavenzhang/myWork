/**
 * Created by soga on 16/9/21.
 */

import React, { Component } from "react";
import { connect } from 'react-redux';

//组件
import { Banner, SeekPanel, List, ListItem } from '../components';

const seekActPic = require('../../images/seek-activity.jpg');
const seekShopPic = require('../../images/seek-shop.jpg');

class Seek extends Component{

    render(){

        return (
            <div className="app-main-content">
                <Banner title="发现" />
                <div className="appContent">
                    <SeekPanel link="/activity" imgSrc={seekActPic} />
                    <SeekPanel link="/shop" imgSrc={seekShopPic} />
                </div>
            </div>
        );
    }
}

const mapStateToProps = state => {
    return {
        //activityList: state.appState.activityList
    }
}

export default connect(mapStateToProps)(Seek);