package taven.common {
import com.greensock.TweenLite;
import com.greensock.easing.Linear;

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLVariables;
import flash.text.StyleSheet;
import flash.text.TextField;
import flash.text.TextFormat;


public class Marquee extends MovieClip {
		private var _style:StyleSheet=new StyleSheet();
		private var _textFormat:TextFormat = new TextFormat("宋体", 16, 0x999999, false);
		public var txt:TextField;
		private var _tweenText:TweenLite;
		private var _tweenBool:Boolean = false;
		private var msgArray:Array = new Array();
		
		private var aTime:int=30;
		private var cTime:int=0;
		public function Marquee():void {
			this.mouseEnabled = false;
			this.visible = false;
			
			this._style.setStyle("a:link",{color:"#fe9901"});
			this._style.setStyle("a:hover",{color:"#fff500",textDecoration:"underline"});
			this._style.setStyle("a:active",{color:"#bf7400",textDecoration:"underline"});
			
			this.txt = new TextField();
			this.txt.defaultTextFormat = this._textFormat;
			this.txt.autoSize = "left";
			this.txt.wordWrap = false;
			this.txt.multiline = false;
			this.txt.styleSheet = this._style;
			this.addChild(this.txt);
			
			this.txt.addEventListener(MouseEvent.ROLL_OUT,onRollOutHandler);
			this.txt.addEventListener(MouseEvent.ROLL_OVER,onOverHandler);
			
		}
		private function onRollOutHandler(e:MouseEvent):void
		{
			this._tweenText.resume();
		}
		private function onOverHandler(e:MouseEvent):void
		{
			this._tweenText.pause();
		}
		public function set text(_str:String):void {
			if (this._tweenBool) {
				this.msgArray.push(_str);
				return;
			}
			this._tweenBool = true;
			
			this.txt.alpha = 1;
			if(_str.indexOf("?")!=-1){
				var _v:URLVariables = new URLVariables(_str.substr(_str.indexOf("?") + 1, _str.length));
				this.txt.htmlText = _v.name+": "+_str.substr(0, _str.indexOf("?")) + '  <font color="#fe9901">\(</font><a href="/' + _v.rid + '">来自：'+ _v.rname+'</a><font color="#fe9901">\)</font>';
			}else {
				this.txt.text = _str;
			}
			this.tweenWidth();
			this.visible = true;
		}
		
		public function tweenWidth():void
		{
			if(this.txt.text!="")
			{
				if(this.txt.x<(-this.mask.width))
				{
					this.moveCompleteEvent();
					return;
				}
				if(this.mask){
					this.txt.x = this.mask.x + this.mask.width + 5;
					this.aTime-=this.cTime;
					this._tweenText = TweenLite.to(this.txt, this.aTime, { "x":-this.mask.width, onUpdate:updateHandler, "ease":Linear.easeNone, "onComplete":moveCompleteEvent } );
				}else {
					this.txt.x = -5;
					this._tweenText = TweenLite.to(this.txt, 10, { "x":-this.mask.width, "ease":Linear.easeNone, "onComplete":moveCompleteEvent } );
				}
			}
		}
		
		private function updateHandler():void
		{
//			trace("####",this.aTime);
			this.cTime=int(this._tweenText.time());
		}
		
		private function moveCompleteEvent():void {		
			this._tweenText.invalidate();
			this.aTime=30;
			this.cTime=0;
			TweenLite.killTweensOf(this.txt);
			this._tweenText = TweenLite.to(this.txt, .5, { "alpha":0, "delay":3, "ease":Linear.easeNone, "onComplete":playCompleteEvent } );
		}
		private function playCompleteEvent():void {
			this.visible = false;
			this.txt.text = "";
			this.txt.width = 10;
			this._tweenText.invalidate();
			TweenLite.killTweensOf(this.txt);
			this._tweenText = null;
			this._tweenBool = false;
			if(this.msgArray.length>0){
				var _str:String = this.msgArray.shift();
				this.text = _str;
			}else {
				this.dispatchEvent(new Event("marqueeCompleteEvent"));
			}
		}
	}
}