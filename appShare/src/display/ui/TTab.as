/**
 * Created by taven on 2016/3/30.
 */
package display.ui {
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.text.TextField;


public class TTab  extends Sprite{

    private var _selected:Boolean;

    public function TTab(view:MovieClip) {
        mc = view;
        mc.stop();
        this.addChild(mc);
        this.mouseChildren=false;
        this.mouseEnabled = true;
        selected = false;
        this.buttonMode =true
    }

    public var mc:MovieClip;
    public var index:int;

    public function get selected():Boolean {
        return _selected;
    }

    public function set selected(value:Boolean):void {
        _selected = value;
        mc.gotoAndStop(_selected ? 2:1);
        if(mc.txtName != null)
        {
            (mc.txtName as TextField).textColor = _selected ? 0xFFFFFF:0xABB4B6;
        }
    }
}
}
