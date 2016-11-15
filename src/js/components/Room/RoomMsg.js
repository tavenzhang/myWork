/**
 * Created by soga on 16/9/26.
 */
import React, {Component,PropTypes} from 'react';
import {List, ListItem} from 'material-ui/List';
//import Divider from 'material-ui/Divider';

import { changLinkMsg } from '../../utils/util'

class RoomMsg extends Component {

    static propTypes = {
        data : PropTypes.any.isRequired
    };

    static defaultProps = {
    };

    shouldComponentUpdate(nextProps,nextState) {
        if(this.props.data != nextProps.data) {
            return true
        }
        else {
            return false
        }
    }

    render() {
        const { data } = this.props;
        //console.log(data)
        return (
            <div className="video-chat">
                {data.map(( v, index ) => {
                    let [msg,msgClass] = [null,"roomMsg"];

                    //把含有链接的文字转换
                    const newMsgData = changLinkMsg(v.msg);
                    let newMsg = null;
                    if(newMsgData.length >1) {//含有链接的文字
                        newMsg = <span>
                                    {newMsgData[0]}
                                    <a className="str-link" href={newMsgData[2]} target="_blank">{newMsgData[3]}</a>
                                    {newMsgData[1]}
                                </span>
                    }
                    else {
                        newMsg = newMsgData[0];
                    }

                    if(v.type == 3) {//系统消息
                        msg = <span>【<span className="mark">系统公告</span>】{newMsg}</span>;
                    }

                    if(v.type == 1) {//主播房间信息
                        msg = <span>【<span className="mark">房间公告</span>】{newMsg}</span>;
                    }

                    return (
                        <div className={msgClass} key={index} >{msg}</div>
                    )
                })}
            </div>
        )
    }};

export default RoomMsg;