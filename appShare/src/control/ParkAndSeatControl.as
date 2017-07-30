/**
 * Created by Taven on 2015/9/9.
 */
package control {
import com.rover022.CBProtocol;
import com.rover022.ModuleNameType;

import flash.display.MovieClip;

import manger.ModuleLoaderManger;

import tool.FormatDataTool;

import tool.VideoTool;

public class ParkAndSeatControl extends BaseControl {
    override public function regMsg():void {
        super.regMagHanlde(CBProtocol.listSeat,handleMessgae);
        super.regMagHanlde(CBProtocol.listCar,handleMessgae);
    }

    override public function handleMessgae(data:*):void {
        var sObject:Object = data;
        var  view:MovieClip = ModuleLoaderManger.getInstance().getModule(ModuleNameType.VIDEO_ROOM) as MovieClip;
        switch (data.cmd) {
            case CBProtocol.listSeat://获取座位列表数据
                if (view.seats_Module) {
                    view.seats_Module.price = sObject.price;
                    var arr:Array = sObject.items as Array;
                    var len:int = arr.length;
                    for (var i:int = 0; i < len; i++) {
                        arr[i].headimg = VideoTool.formatHeadURL(arr[i].headimg)
                    }
                    view.seats_Module.parksData(arr);
                }
                break;
            case CBProtocol.listCar://停车
                view.parking_Module.updateData(FormatDataTool.parkCarArray(sObject.items));
                break;
        }
    }
}
}
