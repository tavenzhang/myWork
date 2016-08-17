/**
 * Created by ws on 2015/8/4.
 */
package taven.utils {
import com.bit101.components.ComboBox;

import flash.display.DisplayObjectContainer;

public class CCComboBox extends ComboBox{
    public function CCComboBox(parent:flash.display.DisplayObjectContainer = null,xpos:Number = 0,ypos:Number = 0,defaultLabel:String = "",items:Array = null) {
        super(parent,xpos,ypos,defaultLabel,items)
    }
    public function update():void{

        setLabelButtonLabel();
        _list.draw();
    }

}
}
