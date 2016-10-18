/**
 * Created by Administrator on 2015/4/8.
 */
package com.kingjoy.view {
import flash.display.Sprite;

public class DivisionContainer extends Sprite {
    public var tabArray:Array = [];
    public var currentTab:Sprite;

    public function DivisionContainer() {
        super();
    }

    public function addTab(s:String, _contain:Sprite):void {
        tabArray[s] = _contain;
        _contain.visible = false;
        addChild(_contain);

        if (currentTab == null) {
            currentTab = _contain;
            currentTab.visible = true;
        }
    }

    public function show(s:String):void {
        var clip:Sprite = tabArray[s];
        for each (var sprite:Sprite in tabArray) {
            sprite.visible = false;
        }

        if (clip) {
            clip.visible = true;
        }
    }

    public function getView(s:String):Sprite {
        var clip:Sprite = tabArray[s];
        return clip;
    }
}
}
