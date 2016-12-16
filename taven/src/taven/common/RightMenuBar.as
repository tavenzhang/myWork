/**
 * Created by zhangxinhua on 16/8/2.
 */
package taven.common {
import display.ui.TTabBar;

import flash.display.DisplayObject;
import flash.display.MovieClip;

import manger.ClientManger;

public class RightMenuBar extends leftMenuMc {
    private var tabBar:TTabBar;
    private var menuBarView:taven_rankMenu;
    private var menuWidth:Number;
    private var _isFirstInit:Boolean;

    public function RightMenuBar() {

        menuBarView = new taven_rankMenu();
//        menuBarView.menuBtn1.txtName.text = "聊天";
//        menuBarView.menuBtn2.txtName.text = "点歌";
//        menuBarView.menuBtn3.txtName.text = "麦序";
      tabBar = new TTabBar([menuBarView.menuBtn1, menuBarView.menuBtn2, menuBarView.menuBtn3], onTabChange, 1);
        menuBarView.menuBtn1.txtName.text = "";
        menuBarView.menuBtn2.txtName.text = "聊天";
        menuBarView.menuBtn3.txtName.text = "";
        menuBarView.menuBtn1.stop();
        menuBarView.menuBtn2.gotoAndStop(1);
        menuBarView.menuBtn3.stop();
        menuWidth = tabBar.width;
        tabBar.mouseEnabled=tabBar.mouseChildren=false;
        menuBarView.menuBtn1.mouseEnabled=menuBarView.menuBtn2.mouseEnabled=menuBarView.menuBtn3.mouseEnabled=false;
        this.addChild(menuBarView);
        this.addChild(tabBar);

    }

    private function dragBg(width:Number, heigh:Number):void {
//        this.graphics.clear();
//        this.graphics.beginFill(0x000000, 0.7);
//        // this.graphics.drawRoundRectComplex(2,(-h+6),(width-4),(heigh+h),0,0,10,10);
//        this.graphics.drawRoundRectComplex(-2, -4, (menuWidth + 4), (heigh + tabBar.height + 10), 0, 0, 2, 2);
//        this.graphics.endFill();
    }


    public function adjustHeiht(heigh:Number):void {
//        var view:MovieClip = ClientManger.getInstance().view as MovieClip;
//        view["rankGift_Module"].height = view["rankView_Module"].height = view["rankWeek_Module"].height = heigh;
//        view["rankView_Module"].x = view["rankWeek_Module"].x = -26;
//        view["rankGift_Module"].x = 6;
//        dragBg(menuWidth, heigh);
//        if(!_isFirstInit)
//        {
//            _isFirstInit = true;
//            onTabChange(0);
//        }
    }


    private function onTabChange(index:int):void {
        var view:MovieClip = ClientManger.getInstance().view as MovieClip;
        if (!view.rankGift_Module) {

        }
//        switch (index) {
//            case 0://本场贡献
//                view.rankGift_Module.visible = false;
//                view.rankView_Module.visible = true;
//                view.rankWeek_Module.visible = false;
//                break;
//            case 1://礼物清单
//                view.rankGift_Module.visible = true;
//                view.rankView_Module.visible = false;
//                view.rankWeek_Module.visible = false;
//                break;
//            case 2://周贡献榜
//                view.rankGift_Module.visible = false;
//                view.rankView_Module.visible = false;
//                view.rankWeek_Module.visible = true;
//                break;
//        }
    }

    /**--------------------------------------------------------------------------公共接口-----------------------------------------------------------------------------------------------------------*/
    override public function set width(value:Number):void {
        super.width = width;
        dragBg(width, height)
    }


    override public function set height(value:Number):void {
        super.height = value;

        dragBg(width, height)
    }

    public function addSubView(displayObject:DisplayObject):void {
        this.addChildAt(displayObject, 0);
        displayObject.y = tabBar.y + tabBar.height + 10;
        displayObject.width = menuWidth;
        displayObject.visible=false;

    }

}
}
