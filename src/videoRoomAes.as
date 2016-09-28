/**
 * Created by thomas on 2016/9/21.
 */
package {
import flash.display.Loader;
import flash.display.Sprite;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
[SWF(width=1500, height=900, backgroundColor="#00000")]
public class videoRoomAes extends Sprite {

 [Embed (source="../bin-debug/videoRoom.swf", mimeType = "application/octet-stream")] // source = path to the swf you want to protect private var content:Class;
  public var mainClass:Class;
    public function videoRoomAes() {
        var loader:Loader = new Loader();
        addChild(loader);
        loader.loadBytes(new mainClass(), new LoaderContext(false, new ApplicationDomain()));
    }

}
}
