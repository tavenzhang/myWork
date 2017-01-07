import React from 'react';
import { Route, IndexRoute, Redirect } from 'react-router';

import {
    Main,
    Video,
    Login,
    Register,
    Search,
    Home,
    Rank,
    RankRich,
    RankExp,
    RankGame,
    User,
    UserEdit,
    Seek,
    Activity,
    Shop,
    ActivityDetail,
    Recharge,
    MyFav,
    MyOrd,
    MyRecord,
    MySetting,
    MyMount,
    MyMsg
} from './containers';

export default (
    <Route path="/" component={ Main }>
        <IndexRoute component={ Home } />
        <Redirect from="/" to="/home" />
        <Route path="home" component={ Home } />
        <Route path="login" component={ Login } />
        <Route path="register" component={ Register } />
        <Route path="search" component={ Search } />
        <Route path="rank" component={ Rank } />
        <Route path="rankExp" component={ RankExp } />
        <Route path="rankRich" component={ RankRich } />
        <Route path="rankGame" component={ RankGame } />
        <Route path="seek" component={ Seek } />
        <Route path="activity" component={ Activity } />
        <Route path="recharge" component={ Recharge } />
        <Route path="shop" component={ Shop } />
        <Route path="activity/:id" component={ ActivityDetail } />
        <Route path="user" component={ User }></Route>
        <Route path="userEdit" component={ UserEdit }></Route>
        <Route path="video/:id" component={ Video } />
        <Route path="myFav" component={ MyFav }></Route>
        <Route path="myOrd" component={ MyOrd }></Route>
        <Route path="myRecord" component={ MyRecord }></Route>
        <Route path="mySetting" component={ MySetting }></Route>
        <Route path="myMount" component={ MyMount }></Route>
        <Route path="myMsg" component={ MyMsg }></Route>
    </Route>
)