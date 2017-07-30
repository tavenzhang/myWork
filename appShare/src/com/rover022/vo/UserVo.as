/**
 * Created by Administrator on 2015/6/8.
 */
package com.rover022.vo {
public dynamic class UserVo {
    public var uid:int;
    public var richLv:int;
    public var lv:int;
    public var icon:int;
    public var name:String = "";
    public var car:int;
    public var ruled:int;
    public var hidden:Number;
    public var money:Number;
    public var rank:Number;

    public function UserVo(src:Object = null) {
        if (src != null) {
            for (var _name:String in src) {
                this[_name] = src[_name];
            }
        }
    }

    public function init(id:int = 0, uname:String = "", mrlv:int = 0, mlv:int = 0, mico:int = 0, mcar:int = 0):UserVo {
        uid    = id;
        richLv = mrlv;
        lv     = mlv;
        icon   = mico;
        name   = uname;
        car    = mcar;
        return this;
    }

    public function reset():void {
        uid    = 0;
        richLv = 0;
        lv     = 0;
        icon   = 0;
        name   = "";
        car    = 0;
    }

    public function get uname():String {
        return name;
    }
}
}
