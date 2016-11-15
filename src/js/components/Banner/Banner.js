/**
 * Created by soga on 16/9/20.
 */
import React, { Component, PropTypes } from 'react';
import AppBar from 'material-ui/AppBar';
import IconButton from 'material-ui/IconButton';
import NavigationClose from 'material-ui/svg-icons/navigation/arrow-back';

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
        const { back, title, titleTP } = this.props;

        let [backIcon,rightIcon] = [<IconButton />,<IconButton />];

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
            backIcon = <IconButton
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

        //栏目标题
        let bannerTitle = titleTP == "image" ? <img src={title} /> : title;

        return (
            <AppBar
                title={ bannerTitle }
                iconElementLeft={backIcon}
                iconElementRight={rightIcon}
                className='appBar'
                />
        )
    }};

export default Banner;