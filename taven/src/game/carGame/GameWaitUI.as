/**
 * Created by Administrator on 2015/7/15.
 */
package game.carGame {
import flash.events.MouseEvent;

public class GameWaitUI extends IGamePane {
    public function GameWaitUI(src:CarGame) {
        super(src);
        view = getAssMovieClip("waitMc");
        view.closeBtn.addEventListener(MouseEvent.CLICK, onCloseGame);
        addChild(view);
        view.helpBtn.addEventListener(MouseEvent.CLICK, onHelpGame);
    }

    private function onHelpGame(event:MouseEvent):void {
        var view:GameInfor = new GameInfor(carGame);
        view.active();
        removeFromSuperview();
        carGame = null;
    }
}
}
