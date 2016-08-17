/**
 * Created by Administrator on 2015/6/24.
 */
package com.rover022 {
import flash.text.TextField;

/**
 * 聊天室 实现聊天功能
 */
public interface IChat {
    function onGiftChat(sObject:Object):void;

    function onPublicChat(sObject:Object, type:int):void;

    function onPeopleEnter(sObject:Object):void;

    function onChatSystemMessage(src:Object):void;

    function clear():void;

    function get inputTextField():TextField;

    function addItem(obj:Object):void;

    function onComboGiftChat(sObject:Object):void;
}
}
