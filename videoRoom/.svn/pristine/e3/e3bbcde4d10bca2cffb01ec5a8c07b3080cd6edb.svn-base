/**
 * Created by Administrator on 2015/3/25.
 */
package taven.chatModule {
import com.bit101.components.ComboBox;
import com.rover022.ModuleNameType;
import com.rover022.vo.VideoConfig;

import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;

import ChatRoomModule;

public class InputUI extends Sprite {
    public var chatRoomModule:ChatRoomModule;
    private var _smileyContainer:Sprite;
    private var _sendBtn:SimpleButton;
    private var _targetCombox:ComboBox;
    public var view:inputUIMC;
    public var uDict:Array;
    public var faceUI:FaceView;
    public var textField:TextField;

    public function InputUI(_width:Number, _module:ChatRoomModule) {
        uDict = [{label: "所有人", data: {}}];
        chatRoomModule = _module;
        view = new inputUIMC();
        addChild(view);
        textField = new TextField();
        textField.defaultTextFormat = new TextFormat("宋体", 12);
        textField.textColor = 0x0;
        textField.type = TextFieldType.INPUT;
        textField.width = 165;
        textField.height = 36;
        textField.x = 5;
        textField.y = 40;
        textField.multiline = false;
        textField.wordWrap = false;
        textField.restrict = "^<>";
        addChild(textField);
        _targetCombox = new ComboBox(view, 5, 4);
        _targetCombox.width = 160;
        _targetCombox.addItem(uDict[0]);
        _targetCombox.selectedIndex = 0;
        _targetCombox.openPosition = ComboBox.TOP;
        _targetCombox.x = 40;
        //表情容器
        _smileyContainer = new Sprite();
        addChild(this._smileyContainer);
        _smileyContainer.visible = false;
        _smileyContainer.y = -_smileyContainer.height;
        _sendBtn = view.sendNews_bt;
        _sendBtn.addEventListener(MouseEvent.CLICK, chatRoomModule.sendMessage);
        view.exp_bt.addEventListener(MouseEvent.CLICK, onExpClick);
        view.exp_bt.visible = true;
        //建立快捷键插件

    }

    public function initFaceDic():void {
        //faceUI 想延迟初始化的话 必须先注册 好face url 否则无法解析其他人的表情
        for (var i:int = 0; i < 42; i++) {
            var id:String = i.toString();
            if (id.length == 1) {
                id = "0" + id;
            }
            ChatRoomModule.faceArr["/" + id] = VideoConfig.HTTP + "image/face/" + id + ".swf";
        }
    }

    private function onExpClick(event:MouseEvent):void {
        if (faceUI == null) {
            var icoPre:String = chatRoomModule.videoRoom.getDataByName(ModuleNameType.HTTPROOT) as String;
            icoPre = icoPre == null ? "" : icoPre;
            faceUI = new FaceView(this, icoPre);
            faceUI.y = -165;
            faceUI.visible = false;
            addChild(faceUI);
        }
        faceUI.visible = !faceUI.visible;
    }

    public function getType():int {
        if (_targetCombox.selectedIndex == 0) {
            return 0;
        } else {
            return 1;
        }
    }

    public function getUID():uint {
        if (_targetCombox.selectedIndex == 0) {
            return 0;
        } else {
            return _targetCombox.selectedItem.data;
        }
    }

    public function addItem(obj:Object):void {
        var num:int = getIndex(obj);
        if (num == -1) {
            _targetCombox.addItem(obj);
            _targetCombox.selectedIndex = uDict.length;
            uDict.push(obj);
        } else {
            _targetCombox.selectedIndex = num;
        }
    }

    public function getIndex(src:Object):int {
        for (var i:int = 0; i < uDict.length; i++) {
            if (uDict[i].label == src.label) {
                return i;
            }
        }
        return -1;
    }

    public function reset():void {
        uDict = [{label: "所有人", data: {}}];
        _targetCombox.removeAll();
        _targetCombox.addItem(uDict[0]);
        _targetCombox.selectedIndex = 0;
    }

    public function clear():void {
        textField.text = "";
        reset();
    }
}
}
