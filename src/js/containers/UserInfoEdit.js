import React, { Component } from 'react';
import { connect } from 'react-redux';

//import { RaisedButton, Checkbox, TextField, SelectField, MenuItem } from 'material-ui';
//import DatePicker from 'material-ui/DatePicker';
import { Banner } from '../components';

//主题
class UserInfoEdit extends Component {

    render() {
        return (
            <div className="app-main-content">
                <Banner
                    title="修改资料"
                    back={true}
                    />
                <div className="appContent appContent-text">
                    <TextField
                        //hintText="Hint Text"
                        floatingLabelText="昵称"
                        fullWidth={true}
                    /><br />
                    <TextField
                        //hintText="签名"
                        floatingLabelText="签名"
                        multiLine={true}
                        fullWidth={true}
                        rows={2}
                    /><br />
                    <SelectField value={0} fullWidth={true}>
                        <MenuItem value={0} primaryText="男" />
                        <MenuItem value={1} primaryText="女" />
                        <MenuItem value={2} primaryText="保密" />
                    </SelectField>
                    <SelectField value={0} fullWidth={true}>
                        <MenuItem value={0} primaryText="地点" />
                        <MenuItem value={1} primaryText="北京" />
                        <MenuItem value={2} primaryText="上海" />
                        <MenuItem value={3} primaryText="广州" />
                    </SelectField>
                </div>
            </div>
        );
    }
}

//<DatePicker hintText="生日" fullWidth={true}/>

const mapStateToProps = state => {
    return {

    }
}

export default connect(mapStateToProps)(UserInfoEdit);
