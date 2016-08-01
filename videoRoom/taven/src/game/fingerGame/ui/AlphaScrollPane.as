/**
 * Created by roger on 2016/5/18.
 */
package game.fingerGame.ui {
import com.bit101.components.ScrollPane;

import flash.display.DisplayObjectContainer;

public class AlphaScrollPane extends ScrollPane {
    public function AlphaScrollPane(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0) {
        super(parent, xpos, ypos);
        _background.alpha = 0;
        _hScrollbar.autoHide = true;
        filters = null;
    }

    override public function draw():void {
        super.draw();
        content.x = 0;
    }
}
}
