/**
 * Created by Administrator on 2015/4/10.
 */
package {
import com.greensock.loading.LoaderMax;
import com.greensock.loading.SWFLoader;
import com.greensock.loading.XMLLoader;
import com.rover022.vo.GiftVo;
import com.kingjoy.view.GiftPool;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.FileReference;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.system.Security;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.utils.getDefinitionByName;
import flash.utils.setTimeout;

import ghostcat.manager.RootManager;
import ghostcat.mvc.GhostCatMVC;
import ghostcat.ui.PopupManager;
import ghostcat.ui.containers.GAlert;
import ghostcat.ui.containers.GScrollPanel;
import ghostcat.ui.controls.GButton;

[SWF(width=1500, height=700)]
public class GiftMake extends MovieClip {

    private var view:MovieClip;
    private var container:Sprite;
    private var scrollPanel:GScrollPanel;
    private var inforMc:MovieClip;
    private var queue:LoaderMax;
    private var xmlFileName:String = 'xml/giftConfig.xml';
    private var xml:XML;
    private var showLay:Sprite;
    private var giftManger:GiftPool;
    private var selectClip:MovieClip;
    private var numTxt:TextField;

    public function GiftMake() {

        RootManager.register(this);
        Security.loadPolicyFile("saft.xml");
        loadConfig();


        setTimeout(function ():void {
            var s2:Sprite = GhostCatMVC.instance.getM("Test2");
            s2["click"]();
        }, 1000);


    }

    private function loadConfig():void {
        LoaderMax.defaultContext = new LoaderContext(false, ApplicationDomain.currentDomain);
        queue = new LoaderMax({onComplete: initUI});
        queue.append(new XMLLoader(xmlFileName));
        queue.append(new SWFLoader("Modules/skin/uiMake.swf"));
        queue.load();

    }

    public function initUI(e:Event = null):void {
        var _class:Class = getDefinitionByName("bgClip") as Class;
        var bg:MovieClip = new _class;
        bg.x = 0;
        bg.alpha = 0.5;
        addChild(bg);

        showLay = new Sprite();
        giftManger = new GiftPool();
        addChild(showLay);

        view = new MovieClip();
        addChild(view);


        var _class:Class = getDefinitionByName("uiClip") as Class;
        inforMc = new _class;
        inforMc.x = 200;
        inforMc.visible = false;
        view.addChild(inforMc);

        numTxt = new TextField();
        numTxt.text = "1";
        numTxt.maxChars = 4;
        numTxt.restrict = "0-9"
        numTxt.x = 104;
        numTxt.y = 300;
        numTxt.type = TextFieldType.INPUT;
        inforMc.addChild(numTxt);

        var _txt:TextField = new TextField();
        _txt.defaultTextFormat = new TextFormat("宋体", 12);

        _txt.text = "播放数量:";
        _txt.y = 300;
        inforMc.addChild(_txt);

        container = new Sprite();

        scrollPanel = new GScrollPanel(container);
        scrollPanel.addVScrollBar();
        scrollPanel.setSize(150, 300);
        view.addChild(scrollPanel);

        xml = queue.getContent(xmlFileName);
        updateContainer();

        var button:GButton;
        button = new GButton();
        button.label = "删除";
        button.x = 200;
        button.y = 350;
        button.addEventListener(MouseEvent.CLICK, deleteHandle);
        inforMc.addChild(button);
        button = new GButton();
        button.label = "播放";
        button.x = 100;
        button.y = 350;
        button.addEventListener(MouseEvent.CLICK, playHandle);
        inforMc.addChild(button);
        button = new GButton();
        button.y = 350;
        button.label = "修改";
        button.addEventListener(MouseEvent.CLICK, editHandle);
        inforMc.addChild(button);
        //

        button = new GButton();
        button.y = 350;
        button.label = "增加播放道具数据";
        button.addEventListener(MouseEvent.CLICK, addItemHandle);
        view.addChild(button);

        button = new GButton();
        button.x = 100;
        button.y = 350;
        button.label = "刷新";
        button.addEventListener(MouseEvent.CLICK, resHandle);
        view.addChild(button);

        button = new GButton();
        button.y = 400;
        button.label = "保存数据到本地";
        button.addEventListener(MouseEvent.CLICK, saveHandle);
        view.addChild(button);
    }

    private function selectItemHandle(event:MouseEvent):void {
        selectClip = event.currentTarget as MovieClip;
        showClipInfor(selectClip.item);
    }

    public function showClipInfor(item:*):void {
        if (item) {
            inforMc.visible = true;
            numTxt.text = "1";
            inforMc._nameTxt.text = item.@name;
            inforMc.uidTxt.text = item.@id;
            inforMc.urlTxt.text = item.@url;
            inforMc.time.text = item.@time;

            inforMc.xposTxt.text = item.@x;
            inforMc.yposTxt.text = item.@y;
            inforMc.typeTxt.text = item.@type;
            inforMc.playTypeTxt.text = item.@playType;

            inforMc.xscaleTxt.text = item.@xScale;
            inforMc.yscaleTxt.text = item.@yScale

        } else {
            inforMc.visible = false;

            inforMc._nameTxt.text = "";
            inforMc.uidTxt.text = "";
            inforMc._nameTxt.text = "";
            inforMc.time.text = "";

            inforMc.xposTxt.text = "";
            inforMc.yposTxt.text = "";
            inforMc.typeTxt.text = "";
            inforMc.playTypeTxt.text = "";

            inforMc.xscaleTxt.text = "";
            inforMc.yscaleTxt.text = "";

        }
    }

    private function makeTitle(item:*):MovieClip {
        var button:GButton;
        button = new GButton();
        button.label = item.@name;
        var clip:MovieClip = new MovieClip();
        clip.item = item;
        clip.addChild(button);
        return clip;
    }

    /**
     * done
     * @param event
     */
    public function saveHandle(event:MouseEvent):void {
        var fileRef:FileReference = new FileReference();
        fileRef.save(xml, "giftConfig.xml");
    }


    /**
     * done
     * @param event
     */
    public function addItemHandle(event:MouseEvent):void {
        var popView:MovieClip = new MovieClip();
        var _class:Class = getDefinitionByName("uiClip") as Class;
        var skinMC:MovieClip = new _class();
        popView.addChild(skinMC);

        var button:GButton = new GButton();
        button.label = "添加";
        button.x = 0;
        button.y = 300;
        button.addEventListener(MouseEvent.CLICK, function (e:MouseEvent):void {
            var _xml:XML = <root>
            </root>;
            _xml.item = new XML();
            _xml.item.@id = skinMC.uidTxt.text;
            _xml.item.@url = skinMC.urlTxt.text;
            _xml.item.@time = skinMC.time.text;
            _xml.item.@x = skinMC.xposTxt.text;
            _xml.item.@y = skinMC.yposTxt.text;
            _xml.item.@xScale = skinMC.xscaleTxt.text;
            _xml.item.@yScale = skinMC.yscaleTxt.text;

            _xml.item.@type = skinMC.typeTxt.text;
            _xml.item.@playType = skinMC.playTypeTxt.text;
            _xml.item.@name = skinMC._nameTxt.text;

            xml.appendChild(_xml.item);
            PopupManager.instance.removePopup(popView);

            GAlert.show("加入成功");

            updateContainer();

        });
        popView.addChild(button);

        button = new GButton();
        button.label = "关闭窗口";
        button.x = 100;
        button.y = 300;
        button.addEventListener(MouseEvent.CLICK, function (e:MouseEvent):void {
            PopupManager.instance.removePopup(popView);
        });
        popView.addChild(button);


        PopupManager.instance.showPopup(popView);
    }


    /**
     * done
     * @param event
     */
    public function playHandle(event:MouseEvent):void {
        var giftVo:GiftVo = GiftVo.makeFromXML(selectClip.item);
        giftVo.num = int(numTxt.text);
        giftManger.quickShowEff(giftVo);
    }

    /**
     * done
     * @param event
     */
    public function resHandle(event:MouseEvent):void {
        inforMc.visible = false;
        var xmlLoader:XMLLoader = new XMLLoader(xmlFileName, {onComplete: onXmlComplete});
        xmlLoader.load();

        function onXmlComplete(e:Event):void {
            xml = xmlLoader.getContent(xmlFileName);

            updateContainer();
        }
    }

    public function updateContainer():void {
        container.removeChildren();
        for (var i:int = 0; i < xml.item.length(); i++) {
            var clip:MovieClip = makeTitle(xml.item[i]);
            clip.y = 30 * i;
            clip.addEventListener(MouseEvent.CLICK, selectItemHandle);
            container.addChild(clip);
        }
        inforMc.visible = false;
    }

    public function editHandle(event:MouseEvent):void {
        var item:* = selectClip.item;

        item.@name = inforMc._nameTxt.text;
        item.@id = inforMc.uidTxt.text;
        item.@url = inforMc.urlTxt.text;
        item.@time = inforMc.time.text;

        item.@x = inforMc.xposTxt.text;
        item.@y = inforMc.yposTxt.text;
        item.@type = inforMc.typeTxt.text;
        item.@playType = inforMc.playTypeTxt.text;

        item.@xScale = inforMc.xscaleTxt.text;
        item.@yScale = inforMc.yscaleTxt.text;
        //saveHandle(null);
        GAlert.show("修改成功");
    }

    public function deleteHandle(event:MouseEvent):void {
        var item:* = selectClip.item;
        for (var i:int = 0; i < xml.item.length(); i++) {
            if (item == xml.item[i]) {
                delete xml.item[i];
                updateContainer();
                GAlert.show("成功删除");
                return
            }
        }
        GAlert.show("删除失败");


    }
}
}


