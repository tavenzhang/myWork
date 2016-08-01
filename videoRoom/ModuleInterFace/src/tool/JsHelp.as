/**
 * Created by Taven on 2015/8/22.
 */
package tool {
import com.rover022.vo.VideoConfig;

import flash.external.ExternalInterface;

public class JsHelp {
    static public function gotoRoom(_id:int):void {
        try {
            if (ExternalInterface.available) {
                var funcName:String = VideoConfig.configXML.js.@goRoom;
                ExternalInterface.call(funcName, _id);
            }
        } catch (e:*) {
        }
    }
}
}
