/**
 * Created by Administrator on 2015/4/27.
 */
package com.rover022 {
public interface IVideoRoom {

    /**
     * 给每个模块用的
     * 获取到登录状态
     * @param src
     */
    function checkState():int ;


    /**
     * 给每个模块用的
     * 发送数据函数
     * @param src
     */
    function sendDataObject(src:Object):void;


    /**
     * 给每个模块用的
     * 显示弹出窗口函数
     * @param arg
     */
    function showAlert(title :String = "",mession:String = "消息",isAlone:Boolean = true,buttonNum:int = 3,a5:Boolean = false,callBack:Function = null,other:Object = null):void;


    /**
     * 给每个模块用的
     * 获取到别的其他模块
     * @param _name
     * @return
     */
    function getModule(_name:String):Object;

    function getDataByName(_name:String):Object;

}
}
