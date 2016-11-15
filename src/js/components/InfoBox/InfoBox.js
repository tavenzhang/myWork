/**
 * Created by soga on 16/9/22.
 */
import React, {Component,PropTypes} from 'react';
import Snackbar from 'material-ui/Snackbar';

const styles = {
    infoBox: {
        backgroundColor: '#222'
    }
}

class InfoBox extends Component {

    static propTypes = {
        open : PropTypes.bool,
        msg  : PropTypes.string,
        onClose : PropTypes.func,
        style : PropTypes.string
    };

    static defaultProps = {
        open : false,
        msg  : '',
        style: ''
    };

    render() {

        if(this.props.style=="error") styles.infoBox.backgroundColor = '#e84548';
        if(this.props.style=="success") styles.infoBox.backgroundColor = '#222';

        return (

            <Snackbar
                className="infoBox"
                open={this.props.open}
                message={this.props.msg}
                autoHideDuration={3000}
                onRequestClose={this.props.onClose}
                bodyStyle={ styles.infoBox }
                />

        )
    }};

export default InfoBox;