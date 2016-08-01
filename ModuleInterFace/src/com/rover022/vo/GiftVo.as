/**
 * Created by Roger on 2014/12/1.
 * 礼物数据
 */
package com.rover022.vo {
public class GiftVo {

    public static var TYPE_GIFT:String = "gift";
    public static var TYPE_TRANSPORTATION:String = "transportation";

    public var sendName:String;
    public var recName:String;

    public var id:String;
    public var name:String;
    public var num:int;
    public var time:int;
    public var url:String;
    public var x:Number;
    public var y:Number;
    public var scaleX:Number;
    public var scaleY:Number;
    public var type:String;
    public var playType:String = "";


    /**
     * 是否包含动态数据
     */
    public var data:Array;

    public function GiftVo() {
    }

    public static function makeFromXML(item:*):GiftVo {
        var giftVo:GiftVo = new GiftVo();
        giftVo.id = item.@id;
        giftVo.name = item.@name;
        giftVo.num = 1;
        giftVo.time = item.@time;
        giftVo.url = item.@url;
        giftVo.x = item.@x;
        giftVo.y = item.@y;
        giftVo.scaleX = item.@xScale;
        giftVo.scaleY = item.@yScale;
        giftVo.type = item.@type;
        giftVo.playType = item.@playType;
        return giftVo;
    }
}
}
