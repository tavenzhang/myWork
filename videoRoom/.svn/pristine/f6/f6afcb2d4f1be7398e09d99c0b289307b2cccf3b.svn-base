/**
 * Created by Administrator on 2015/9/29.
 */
package game.carGame {
import flash.events.MouseEvent;
import flash.net.SharedObject;

public class GameInfor extends IGamePane {
    public function GameInfor(src:CarGame) {
        super(src);
        view = getAssMovieClip("gameinfors");
        view.closeBtn.addEventListener(MouseEvent.CLICK, onCloseGame);
        addChild(view);

        view.startGame.addEventListener(MouseEvent.CLICK, onStateGame);
        view.selectMc.addEventListener(MouseEvent.CLICK, onAlwaysClick);
    }

    private function onAlwaysClick(event:MouseEvent):void {
        var _frame:int = view.selectMc.currentFrame == 1 ? 2 : 1;
        view.selectMc.gotoAndStop(_frame);

    }

    private function onStateGame(event:MouseEvent):void {
        carGame.alwaysShowGameInfor = view.selectMc.currentFrame == 1 ? false : true;
        var so:SharedObject = SharedObject.getLocal("gamedata", "/");
        so.data.alwaysShowGameInfor = carGame.alwaysShowGameInfor;
        trace("set:", carGame.alwaysShowGameInfor);
        so.flush();

        carGame.initUI();
        removeFromSuperview();
    }

}
}
