/**
 * Created by soga on 16/9/26.
 */
import React, {Component,PropTypes} from 'react';
import {List, ListItem} from 'material-ui/List';
import { CONFIG } from '../../config';
import { changLinkMsg } from '../../utils/util'

class ChatList extends Component {

    static propTypes = {
        data : PropTypes.any.isRequired,
        uid : PropTypes.any.isRequired
    };

    static defaultProps = {
    };

    //componentDidUpdate() {
    //    //scrollTop();
    //    this.refs.test.scrollTop = 99999999
    //    console.log(this.refs.test.scrollTop)
    //}

    shouldComponentUpdate(nextProps,nextState) {
        if(this.props.data != nextProps.data) {
            return true
        }
        else {
            return false
        }
    }

    render() {
        const { data, uid } = this.props;
        return (
            <div className="video-chat">
                {data.map(( v, index ) => {
                    let [msg,msgClass] = [null,"chat-chat"];
                    let [lvIcon,vipIcon] = [null,null];
                    //财富等级
                    if(v.richLv > 1) {
                        const cls = `lvRichIcon r${v.richLv}`;
                        lvIcon = <div className={cls}></div>;
                    }
                    //贵族
                    if(v.vip > 0) {
                        const cls = `hotListImg basicLevel${v.vip}`;
                        vipIcon = <div className={cls}></div>;
                    }
                    //用户进入房间消息
                    if(v.cmd == 11002) {
                        let mount = null;
                        if(v.car) {
                            mount = <span>开着座驾<img className="chat-list-icon" src={ CONFIG.giftPath + v.car + ".png" } /></span>
                        }
                        msg = <span>欢迎【{vipIcon} {lvIcon} {v.name}】{mount}进入房间</span>;
                       //  msgClass = `chat-userEnter`;
                        msgClass=`mark`
                    }
                    //聊天
                    if(v.cmd == 30001) {
                        //<span className="date">[{v.date}]</span>
                        switch(v.type) {
                            case 0://聊天
                                //财富等级
                                if(v.richLv > 1) {
                                    const cls = `lvRichIcon r${v.richLv}`;
                                    lvIcon = <div className={cls}></div>;
                                }

                                //贵族
                                if(v.vip > 0) {
                                    const cls = `hotListImg basicLevel${v.vip}`;
                                    vipIcon = <div className={cls}></div>;
                                }
                                const sendName = v.sendUid == uid ? "我" : v.sendName;
                                msg = <span>
                                        {vipIcon} {lvIcon}
                                    <span className="sendName">{sendName}</span>：
                                    {v.content}
                                    </span>;
                                break;

                            case 3://系统消息
                                //把含有链接的文字转换
                                const newMsgData = changLinkMsg(v.content);
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
                                msg = <span>【<span className="mark">公告</span>】{newMsg}</span>;
                                break;

                            case 6://升级消息
                                let lvIcon = `lvRichIcon r${v.richLv}`;//等级icon，默认用户
                                if(v.content.indexOf("||@icon||") > 0) {//表示主播
                                    lvIcon = `hotListImg AnchorLevel${v.lv}`;
                                }

                                msg = <span>
                                        【<span className="mark gift">贺语 </span>】
                                        恭喜<span className="mark gift">{v.sendName}</span>晋升为
                                        <div className={lvIcon}></div>
                                       </span>;
                                break;

                            case 7://开通贵族
                                let vipIcon = `hotListImg basicLevel${v.vip}`;//贵族icon

                                msg = <span>
                                        【<span className="mark gift">贵族 </span>】
                                        恭喜<span className="mark gift">{v.sendName}</span>开通
                                        <div className={vipIcon}></div>
                                       </span>;
                                break;

                            case 10://贵族到期
                                let vipIconExpir = `hotListImg basicLevel${v.icon}`;//贵族icon

                                const contents = v.content.split("||");
                                msg = <span>
                                        【<span className="mark gift">贵族 </span>】
                                        您的<div className={vipIconExpir}></div>{contents[2]}
                                       </span>;
                                break;


                            default:
                                msg = v.content;
                        }
                    }

                    //送礼
                    if(v.cmd == 40001) {
                        //<span className="date">[{v.date}]</span>
                        const sendName = v.sendUid == uid ? "我" : v.sendName;
                        const giftIcon = <img className="chat-list-icon" src={ CONFIG.giftPath + v.gid + ".png" } />
                        msg = <span>
                                【<span className="mark gift">礼物</span>】
                                 <span className="mark">{sendName}</span>赠送给{v.recName}
                                {giftIcon} <span className="mark giftNum">x{v.gnum}</span>
                              </span>;
                    }

                    //系统信息
                    if(v.cmd == 1) {
                        msg = <span>【<span className="mark">系统</span>】{v.content}</span>;
                    }

                    return (
                        <div className={msgClass} key={index} >{msg}</div>
                    )
                })}
            </div>
        )
    }};

export default ChatList;