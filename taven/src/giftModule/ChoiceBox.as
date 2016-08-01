/**
 * Created by Administrator on 2015/2/4.
 */
package giftModule {
import com.greensock.TimelineLite;
import com.greensock.TweenLite;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;

public class ChoiceBox extends Sprite {
	public var view:giftboxSkin;
	public var pane:MovieClip;
	private var _pane:LR_GIFT_COMBOLIST_001;
	public var isShowSubView:Boolean = true;

	public function ChoiceBox() {
		super();
		view = new giftboxSkin();
		addChild(view);
		view.numTxt.restrict = "0-9";
		view.numTxt.maxChars = 8;
		view.numTxt.text     = "1";
		view.btn.addEventListener(MouseEvent.CLICK, clickHandle);
		view.btn.buttonMode = true;
	}

	public function buildPane():MovieClip {
		_pane = new LR_GIFT_COMBOLIST_001();
		makeSkin(_pane.titile0, "亲吻", 50, gift_icon00);
		makeSkin(_pane.titile1, "笑脸", 99, gift_icon01);
		makeSkin(_pane.titile2, "心", 188, gift_icon02);
		makeSkin(_pane.titile3, "天使心", 365, gift_icon03);
		makeSkin(_pane.titile4, "我爱你", 520, gift_icon04);
		makeSkin(_pane.titile5, "发发发", 888, gift_icon05);
		makeSkin(_pane.titile6, "一生一世", 1314, gift_icon06);
		makeSkin(_pane.titile7, "生生世世", 3344, gift_icon07);
		makeSkin(_pane.titile8, "长长久久", 9999, gift_icon08);
		makeSkin(_pane.guiZhuContain.supertitile0, "两性相爱", 66, icon09);
		makeSkin(_pane.guiZhuContain.supertitile1, "心门钥匙", 168, icon10);
		makeSkin(_pane.guiZhuContain.supertitile2, "蝴蝶", 366, icon11);
		makeSkin(_pane.guiZhuContain.supertitile3, "丘比特之箭", 666, icon12);
		(_pane.guizhuBtn._nameTxt as TextField).mouseEnabled = false;
		(_pane.guizhuBtn._nameTxt as TextField).text         = "贵族专属 >>>";
		_pane.guizhuBtn.addEventListener(MouseEvent.CLICK, onBtnClick);
		_pane.addEventListener(Event.ADDED_TO_STAGE, function (e:Event):void {
			var locP:Point        = localToGlobal(new Point(0, 0));
			_pane.x               = locP.x - 36;
			_pane.y               = locP.y;
			//
			_pane.guiZhuContain.x = 160;
		});
		return _pane;
	}

	private function onBtnClick(event:MouseEvent):void {
		isShowSubView = !isShowSubView;
		if (isShowSubView) {
			TweenLite.to(_pane.guiZhuContain, 0.3, {x: 160});
		} else {
			TweenLite.to(_pane.guiZhuContain, 0.3, {x: 0});
		}
		_pane.guizhuBtn._nameTxt.text = isShowSubView ? "贵族专属 >>>" : "贵族专属 <<<"
		event.stopPropagation();
	}

	private function makeSkin(titile5Mc:MovieClip, titile:String, num:int, pClass:Class):void {
		var iconMC:MovieClip = titile5Mc.iconMc;
		iconMC.removeChildren();
		iconMC.addChild(new pClass());
		titile5Mc.btn1.alpha      = 0;
		titile5Mc.btn1.buttonMode = true;
		titile5Mc.btn1.addEventListener(MouseEvent.CLICK, onSubClick);
		titile5Mc.btn1.addEventListener(MouseEvent.ROLL_OVER, function (e:MouseEvent):void {
			titile5Mc.btn1.alpha = 1;
		});
		titile5Mc.btn1.addEventListener(MouseEvent.ROLL_OUT, function (e:MouseEvent):void {
			titile5Mc.btn1.alpha = 0;
		});
		titile5Mc.num               = num;
		titile5Mc._nameTxt.htmlText = titile + "<font color='#ff9900'>  " + num + "个</font>";
		function onSubClick(e:MouseEvent):void {
			view.numTxt.text   = num.toString();
			var clip:MovieClip = new pClass();
			var locP:Point     = e.currentTarget.localToGlobal(new Point(0, 0));
			clip.x             = locP.x;
			clip.y             = locP.y;
			stage.addChild(clip);
			var timeline:TimelineLite = new TimelineLite();
			timeline.append(TweenLite.to(clip, 0.5, {x: "-50"}));
			timeline.append(TweenLite.to(clip, 1, {
				y: "-50", alpha: 0.2, onComplete: function ():void {
					clip.parent.removeChild(clip);
				}
			}));
		}
	}

	private function clickHandle(event:MouseEvent):void {
		event.stopPropagation();
		if (pane == null) {
			pane = buildPane();
		}
		stage.addEventListener(MouseEvent.CLICK, stageHandle);
		stage.addChild(pane);
	}

	private function stageHandle(e:MouseEvent):void {
		trace("移除");
		stage.removeEventListener(MouseEvent.CLICK, stageHandle);
		dispose();
	}

	public function dispose():void {
		if (pane && pane.parent) {
			pane.parent.removeChild(pane);
		}
	}

	public function reset():void {
		view.numTxt.text = "1";
	}

	public function get giftNum():int {
		view.numTxt.text = int(view.numTxt.text).toString();
		return int(view.numTxt.text);
	}
}
}
