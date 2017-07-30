/**
 * Created by zhangxinhua on 15/9/28.
 */
package com.rover022.vo {
public class VipInfo {
    //用户id
    public var uid:int = 0;
    //richLV 用户财富等级
    public var rivchLv:int = 0;
    //lv  主播等级
    public var lv:int;
    //vip贵族等级
    public var vipLV:int;
    //是否可访问
    public var allowvisitroom:Boolean = false;
    //是否有欢迎语
    public var haswelcome:Boolean;
    //是否有聊天特效
    public var haschateffect:Boolean;
    //聊天限制间隔  单位秒 0表示无限制
    public var chatsecond:int;
    //聊天限制字数
    public var chatlimit:int = 15;
    //房间是否贵宾席
    public var hasvipseat:Boolean;
    //是否有权限禁言其他人 0 无权限 大于1 表示禁言其他人到次数
    public var powerForbidChat:int;
    //踢人的权限 0 无权限 大于1 表示禁言其他人到次数
    public var letout:int;
    public var limitRoomCount:int = 0;
    //用户系数
    public var userTimes:int = 10;
    //fpwd
    public var fpwd:String = "";
    //是否可以聊天
    public var forbitChat:Boolean=0;



    public function initInfo(data:Object):void {
        uid = data.uid;
        rivchLv = data.rivchLv;
        lv = data.lv;
        vipLV = data.vip;
        allowvisitroom = int(data.allowvisitroom) == 0; //0不限制.1限制
        haswelcome = int(data.haswelcome) == 0; //0有.1没有
        haschateffect = int(data.haschateffect) == 1; //0无.1有
        chatsecond = int(data.chatsecond);  //聊天限制时间
        chatlimit = data.chatlimit;  //聊天限制字数
        hasvipseat = int(data.hasvipseat) == 1; //0无 1有
        powerForbidChat = data.nochatlimit;     //是否有权限禁言其他人 0 无权限 大于1 表示禁言其他人到次数
        letout = data.letout;   //踢人到权限 0 无权限 大于1 表示禁言其他人到次数
        limitRoomCount = data.limitRoomCount;
        userTimes=data.userTimes;//用户显示系数
        forbitChat=data.forbidChat;
    }
}
}
