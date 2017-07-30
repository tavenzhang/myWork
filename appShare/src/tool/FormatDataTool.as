package tool {
import com.hurlant.crypto.symmetric.CBCMode;
import com.hurlant.crypto.symmetric.DESKey;
import com.hurlant.util.Base64;
import com.rover022.vo.VideoConfig;

import flash.utils.ByteArray;

public class FormatDataTool {

    /**
     * 主播
     * @param _ar
     * @return
     */
    public static function playerDataArray(_ar:Array):Array {
        if (!_ar) {
            return null;
        }
        for (var i:int = 0; i < _ar.length; i++) {
            playerData(_ar[i]);
        }
        return _ar;
    }

    public static function playerData(_obj:Object):Object {
        if (!_obj) {
            return null;
        }
        _obj.type = _obj.category;
        _obj.headUrl = VideoTool.formatVideoHeadURL(_obj.uid, _obj.version);
        _obj.time = _obj.created;
        _obj.people = _obj.total + _obj.guests;

        return _obj;
    }

    public static function peopleArray(_ar:Array):Array {
        if (!_ar) {
            return null;
        }
        for (var i:int = 0; i < _ar.length; i++) {
            _ar[i].people = _ar[i].total + _ar[i].guests;
        }

        return _ar;
    }

    /**
     * 用户
     * @param _ar
     * @return
     */
    public static function userDataArray(_ar:Array):Array {
        if (!_ar) {
            return null;
        }
        for (var i:int = 0; i < _ar.length; i++) {
            userData(_ar[i]);
        }
        return _ar;
    }

    public static function userData(_obj:Object):Object {
        if (!_obj) {
            return null;
        }
        if (_obj.ruled == 1 || _obj.ruled == 2) {
            _obj.power = 1;
            _obj.level = (_obj.richLv);
        } else if (_obj.ruled == 3) {
            _obj.power = 2;
            _obj.level = (_obj.lv);
        } else {
            _obj.power = 0;
            _obj.level = (_obj.richLv);
        }

        return _obj;
    }

    /**
     * 贡献
     * @param _ar
     * @return
     */
    public static function rankViewArray(_ar:Array):Array {
        if (!_ar) {
            return null;
        }
        for (var i:int = 0; i < _ar.length; i++) {
            rankView(_ar[i]);
        }
        return _ar;
    }

    public static function rankView(_obj:Object):Object {
        if (!_obj) {
            return null;
        }
        _obj.rank = "";
        _obj.money = _obj.score;
        return _obj;
    }

    /**
     * 车位
     * @param _ar
     * @return
     */
    public static function parkCarArray(_ar:Array):Array {
        if (!_ar) {
            return null;
        }
        for (var i:int = 0; i < _ar.length; i++) {
            parkCar(_ar[i]);
        }
        return _ar;
    }

    public static function parkCar(_obj:Object):Object {
        if (!_obj) {
            return null;
        }
        _obj.carUrl = VideoConfig.HTTP + "image/gift_material/" + _obj.car + ".png";
        return _obj;
    }

    /**
     * 礼物
     * @param _ar
     * @return
     */
    public static function rankGiftArray(_ar:Array):Array {
        if (!_ar) {
            return null;
        }
        for (var i:int = 0; i < _ar.length; i++) {
            rankGift(_ar[i]);
        }
        return _ar;
    }

    public static function rankGift(_obj:Object):Object {
        //{"uid":3322234,"richLv":0,"vipLv":1,"num":1,"gid":100002,"name":"test004","created":"11:48"}
        //{time:"12:34",name:"走路闷骚会闪耀",count:55,ico:"1.jpg",giftName:"鲜花"}
        if (!_obj) {
            return null;
        }
        _obj.time = _obj.created;
        if (_obj.num) {
            _obj.count = _obj.num;
        } else {
            _obj.count = _obj.gnum;
        }
        if (_obj.gname) {
            _obj.giftName = _obj.gname;
        } else {
            _obj.giftName = ""
        }
        if (!_obj.name) {
            _obj.name = _obj.sendName;
        }
        if (!_obj.uid) {
            _obj.uid = _obj.sendUid;
        }
        var _gurl:String = VideoConfig.resAdd;
        _obj.ico = _gurl.replace("\{0\}", _obj.gid);
        return _obj;
    }

    /**
     * 用户信息面板
     * @param _obj
     * @return
     */
    public static function personInfo(_obj:Object):Object {
        _obj.headUrl = VideoTool.formatHeadURL(_obj.headimg);
        _obj.isFocus = false;
        return _obj;
    }

    public static function getNickeName(src:Object):String {
        if (src.hidden && src.hidden == 1) {
            return "神秘人"
        } else {
            return src.name
        }
    }

    public static function getNickeNameByInt(_name:String, num:int):String {
        return num == 1 ? "神秘人" : _name;

    }

    /**
     * 格式化url
     * @param _url
     * @param _id
     * @return
     */
    public static function formatURL(_url:String, _id:*):String {
        return _url.replace("{0}", _id);
    }

    //---------------------------------------------------------------Http
    private static var httpKey:String = "";
    private static var httpIv:String = "";
    private static var desKey:DESKey = null;
    private static var cbcMode:CBCMode;
    //
    private static function createDes():void {
        if (!desKey) {
            var keyArray:ByteArray = new ByteArray();
            keyArray.writeUTFBytes("iloveyvv");
            var ivArray:ByteArray = new ByteArray();
            ivArray.writeUTFBytes("onevideo");
            desKey = new DESKey(keyArray);
            cbcMode = new CBCMode(desKey);//加密模式
            cbcMode.IV = ivArray;//设置加密的IV
        }
    }

    /**
     * 解密http数据
     * @param _v
     * @return
     */
    public static function decode(_v:String):String {
        createDes();
        var _str:String = "";

        var bytes:ByteArray = Base64.decodeToByteArray(_v);
        cbcMode.decrypt(bytes);//利用加密模式的解密算法解码
        _str = byteArrayToString(bytes);//把二进制数据转换成字符串 函数代码如下;

        return _str;
    }

    /**
     * ByteArray转String
     * @param bytes
     * @return
     */
    public static function byteArrayToString(bytes:ByteArray):String {
        var str:String;
        if (bytes) {
            bytes.position = 0;
            str = bytes.readUTFBytes(bytes.length);
        }

        return str;
    }


    /**
     * String转byteArray
     * @param str
     * @return
     */
    public static function stringToByteArray(str:String):ByteArray {
        var bytes:ByteArray;
        if (str) {
            bytes = new ByteArray();
            bytes.writeUTFBytes(str);
        }
        return bytes;
    }
}
}