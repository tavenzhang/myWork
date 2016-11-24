/**
 * Created by soga on 16/9/21.
 */
import getMuiTheme from 'material-ui/styles/getMuiTheme';

//主题
export const muiTheme = getMuiTheme({
    palette: {
        primary1Color: '#cb2064',
        primary2Color: '#363636',
        accent1Color: '#448AFF',
        textColor: '#222'
    },
    appBar: {
        height: 40,
        //padding: 12
    },
    tabs: {
        backgroundColor: '#fff',
        textColor: '#BDBDBD',
        selectedTextColor: '#fff',
    },
    //dropDownMenu: {
    //    accentColor: '#cb2064'
    //},
    fontFamily: 'Roboto, YouYuan, helvetica neue, hiragino sans gb'
});