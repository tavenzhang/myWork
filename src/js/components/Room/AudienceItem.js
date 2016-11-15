/**
 * Created by soga on 16/9/29.
 */
import React, {Component,PropTypes} from 'react';
import {RankListPanel} from './../';
import Iuser from 'react-icons/lib/fa/user';

class AudienceList extends Component {

    static propTypes = {
        data : PropTypes.any.isRequired
    };

    static defaultProps = {
    };

    render() {
        const { audience, admins } = this.props;

        return (
            <div className="video-audience">

                {audiences.map(( anchor, index ) => {

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

                    //主播=3，管理员=2，观众=0
                    //let IuserClass = "other";
                    //if(anchor.ruled == 2) {
                    //    IuserClass = 'admin';
                    //}
                    //else if(anchor.ruled == 0) {
                    //    IuserClass = 'audience';
                    //}
                    //else {
                    //    IuserClass = 'other'
                    //}

                    anchor.username = anchor.name;

                    return (
                        <RankListPanel
                            key={num}
                            lvIcons={lvIcons}
                            data={anchor}
                            num={<Iuser className="audience" />}
                            />
                    )
                })}
            </div>
        )
    }};

export default AudienceList;