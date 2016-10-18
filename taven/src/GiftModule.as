/**
 * Created by Administrator on 2015/1/21.
 */
package {
import giftModule.*;

import flash.display.Sprite;
import flash.events.Event;


public class GiftModule extends Sprite {

    private var view:GiftUI;

    public function GiftModule() {
        view = new GiftUI();
        view.addEventListener(Event.ADDED_TO_STAGE, init);

        addChild(view);


    }

    private function init(event:Event):void {
   //     view.configURLS("http://v.1room.cc/video_gs/conf", "http://v.1room.cc/video_gs/pack/list2", "http://www.1room.cc/flash/image/gift_material/{0}.png");
        //view.giftData =JSON.parse('[{"category":1,"name":"热门","items":[{"isNew":1,"gid":310016,"price":1,"category":1,"name":"鲜花","desc":"请不要把我插在牛粪上","sort":"1"},{"isNew":0,"gid":310022,"price":5,"category":1,"name":"蓝色妖姬","desc":"","sort":"2"},{"gid":320014,"price":10,"category":1,"name":"波霸","desc":"哇，好大的胸器","sort":"3"},{"gid":320006,"price":188,"category":1,"name":"心雨","desc":"心如雨下","sort":"4"},{"gid":320010,"price":1888,"category":1,"name":"祝福气球","desc":"飞屋环球必备","sort":"5"},{"gid":320022,"price":3888,"category":1,"name":"烟花之吻","desc":"爱TA，就送这个给TA吧","sort":"6"},{"gid":310005,"price":20,"category":1,"name":"Dior香水","desc":"我是迪奥，不是奥迪哦","sort":"7"},{"gid":320012,"price":10,"category":1,"name":"任性","desc":"任性一次","sort":"8"},{"gid":320013,"price":10,"category":1,"name":"女神","desc":"请叫我女神","sort":"9"},{"gid":310006,"price":10,"category":1,"name":"啤酒","desc":"啤酒加炸鸡，惬意","sort":"10"},{"gid":310011,"price":3,"category":1,"name":"冰激凌","desc":"快点吃掉我，我快化掉了","sort":"11"}]},{"category":2,"name":"推荐","items":[{"gid":320025,"price":488,"category":2,"name":"情侣戒指","desc":"它是爱情不可言喻的密码","sort":"1"},{"gid":320026,"price":388,"category":2,"name":"音乐盒","desc":"可自动演奏音乐","sort":"2"},{"gid":320027,"price":266,"category":2,"name":"清凉一夏","desc":"清凉一夏，避暑总动员 ","sort":"3"},{"gid":320023,"price":10,"category":2,"name":"脱掉","desc":"脱！脱！脱！","sort":"4"},{"gid":310001,"price":50,"category":2,"name":"钻戒","desc":"钻石很久远，一颗就…","sort":"5"},{"gid":310014,"price":3,"category":2,"name":"香吻","desc":"只献给最喜欢的人","sort":"6"},{"gid":310018,"price":1,"category":2,"name":"棒棒糖","desc":"棒棒，好棒哦","sort":"7"},{"gid":310012,"price":5,"category":2,"name":"鼓掌","desc":"不错不错，鼓掌","sort":"8"},{"gid":320011,"price":10,"category":2,"name":"萌","desc":"萌萌达","sort":"9"},{"gid":320016,"price":10,"category":2,"name":"呆","desc":"我当时就惊呆了","sort":"10"},{"gid":310004,"price":50,"category":2,"name":"皇冠","desc":"只有尊贵的人才配得上我","sort":"11"},{"gid":310017,"price":10,"category":2,"name":"板砖","desc":"任你再叼，一砖拍倒","sort":"12"},{"gid":320015,"price":10,"category":2,"name":"duang","desc":"duang，duang","sort":"13"}]},{"category":3,"name":"高级","items":[{"gid":320019,"price":10,"category":3,"name":"惊喜狮子","desc":"惊喜！","sort":"1"},{"gid":320020,"price":10,"category":3,"name":"惊喜小丑","desc":"惊喜！","sort":"2"},{"gid":320003,"price":888,"category":3,"name":"烛光晚餐","desc":"只把最好的留给你","sort":"3"},{"gid":320005,"price":520,"category":3,"name":"我爱你","desc":"对不起，我爱你","sort":"4"},{"gid":320008,"price":521,"category":3,"name":"爱神之箭","desc":"用它让主播爱上你吧","sort":"5"},{"gid":320017,"price":99,"category":3,"name":"蛋糕","desc":"吃多了会长胖的哦","sort":"6"}]},{"category":4,"name":"奢华","items":[{"gid":330001,"price":3888,"category":4,"name":"绚丽流星雨","desc":"一起去看流星雨","sort":"1"},{"gid":320024,"price":5888,"category":4,"name":"花田别墅","desc":"","sort":"2"},{"gid":330002,"price":6888,"category":4,"name":"情比钻坚","desc":"","sort":"3"},{"gid":330003,"price":3888,"category":4,"name":"豪华游艇","desc":"","sort":"4"}]}]')
    }
}
}
