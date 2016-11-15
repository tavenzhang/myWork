/**
 * Created by soga on 16/9/25.
 */
import React, {Component,PropTypes} from 'react';
import {RankListPanel} from './../';
import Iuser from 'react-icons/lib/fa/user';

class AudienceList extends Component {

    static propTypes = {
        data : PropTypes.any.isRequired,
        type : PropTypes.string
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
        const { data, type } = this.props;

        return (
            <div className="video-audience">
                {data.map(( anchor, index ) => {

                    let num = index + 1;
                    if(num < 10) num = "0"+num;

                    //等级icon
                    let lvIcon = anchor.richLv > 0 ? `lvRichIcon r${anchor.richLv}` : null;

                    //贵族
                    let vipIcon = null;
                    if(anchor.vip > 0) {
                        const vipIconClass = `hotListImg basicLevel${anchor.vip}`;
                        vipIcon = <div className={vipIconClass}></div>;
                    }

                    const lvIcons = <div className="rankIcons">
                                        {vipIcon}
                                        <div className={lvIcon}></div>
                                    </div>;

                    anchor.username = anchor.name;

                    return (
                        <RankListPanel
                            key={num}
                            lvIcons={lvIcons}
                            data={anchor}
                            num={<Iuser className={type} />}
                        />
                    )
                })}
            </div>
        )
    }};

export default AudienceList;