/**
 * Created by zhangxinhua on 16/9/1.
 */
package control {
import com.rover022.CBProtocol;
import com.rover022.ModuleNameType;

import display.ModuleRSLManager;

import manger.DataCenterManger;

public class ActiveControl extends BaseControl {
    override public function regMsg():void {
        super.regMagHanlde(CBProtocol.activeCj_62001, handleMessgae);
    }

    override public function handleMessgae(data:*):void {
        switch (data.cmd) {
            case CBProtocol.activeCj_62001:
                DataCenterManger.activeCJData = data;
                ModuleRSLManager.instance.showModule(ModuleNameType.ActiveCJ);
                break;
        }

    }
}
}
