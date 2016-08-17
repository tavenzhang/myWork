/**
 * Created by Roger on 2014/12/1.
 */
package com.kingjoy.view {
import com.greensock.TweenLite;
import com.greensock.TweenMax;
import com.greensock.easing.Sine;
import com.greensock.plugins.BezierPlugin;
import com.greensock.plugins.BezierThroughPlugin;
import com.greensock.plugins.TweenPlugin;
import com.junkbyte.console.Cc;
import com.rover022.vo.GiftVo;
import com.rover022.vo.VideoConfig;

import tool.VideoTool;

import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import flash.net.URLRequest;
import flash.utils.setTimeout;

import ghostcat.manager.RootManager;

public class GiftView extends Sprite {
	public var loader:Loader;
	public var giftData:GiftVo;
	public var endPoint:Point;

	public function GiftView(gift:GiftVo, _x:Number = 0, _y:Number = 0) {
		endPoint = new Point(_x, _y);
		giftData = gift;
		//
		loader   = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandle);
		loader.load(new URLRequest(VideoConfig.HTTP + giftData.url + "?version=" + VideoConfig.VERSION));
		addChild(loader);
		//
	}

	public static function makeCloudGraphics(gift:GiftVo, array:Array, b:Boolean = true):Sprite {
		var view:Sprite   = new Sprite();
		var loader:Loader = new Loader();
		var map:Bitmap;
		//
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onSubCompleteHandle);
		loader.load(new URLRequest(VideoConfig.HTTP + gift.url));
		//显示路径动画效果
		

		function showMoveEffImage(bitmap:Bitmap, itemArray:Array):void {
			for (var i:int = 0; i < itemArray.length; i++) {
				var copyBitmap:Bitmap = new Bitmap(bitmap.bitmapData);
				copyBitmap.x          = -35;
				copyBitmap.y          = -35;
				copyBitmap.smoothing  = true;
				var item:Sprite       = new Sprite();
				item.addChild(copyBitmap);
				item.rotation = array[i][4];
				view.addChild(item);
				var _x:Number = itemArray[i][0];
				var _y:Number = itemArray[i][1];
				item.x        = RootManager.stage.stageWidth * Math.random();
				item.y        = Math.random() > 0.5 ? RootManager.stage.stageHeight : 0;
//				TweenPlugin.activate([BezierPlugin, BezierThroughPlugin]);
//				if (b) {
//					TweenMax.to(item, 3, {bezier: [{x: _x, y: item.y}, {x: _x, y: _y}], ease: Sine.easeOut});
//				} else {
//					TweenMax.to(item, 3, {bezier: [{x: item.x, y: _y}, {x: _x, y: _y}], ease: Sine.easeOut});
//				}
				TweenLite.to(item, 2, {
					x: _x,
					y: _y
				});
				TweenLite.to(item, 3, {
					alpha: 0,
					delay: 3 + Math.random() * 0.5
				});
			}
		}

		//显示星星效果;
		function showStarImage(bitmap:Bitmap, num:Number, time:Number):void {
			Cc.log(num);
			for (var i:int = 0; i < num; i++) {
				var copyBitmap:Bitmap = new Bitmap(bitmap.bitmapData);
				copyBitmap.x          = -35;
				copyBitmap.y          = -35;
				copyBitmap.smoothing  = true;
				var item:Sprite       = new Sprite();
				item.addChild(copyBitmap);
				item.x      = Math.random() * VideoConfig.WIDTH;
				item.y      = Math.random() * VideoConfig.HEIGHT;
				item.alpha  = 0;
				item.scaleX = item.scaleY = 0.5;
				view.addChild(item);
				var soTime:Number = Math.random() * 2;
				TweenLite.to(item, 1, {
					scaleX: 1,
					scaleY: 1,
					alpha:  1,
					delay:  soTime
				});
				TweenLite.to(item, 1, {
					alpha: 0,
					delay: soTime + time
				});
			}
		}

		//子对象被加载进来
		function onSubCompleteHandle(e:Event):void {
			map = loader.content as Bitmap;
			if (!b) {
				if (array.length > 100 && array.length < 200) {
					showStarImage(map, 120, 3);
				} else if (array.length >= 200 && array.length < 500) {
					showStarImage(map, 160, 6);
				} else if (array.length >= 500) {
					showStarImage(map, 200, 7);
				} else {
					showMoveEffImage(map, array);
				}
			} else {
				showMoveEffImage(map, array);
			}
		}

		//消失
		setTimeout(dispose, 10000);
		function dispose():void {
			if (map) {
				map.bitmapData.dispose();
			}
			loader.unload();
			view.parent.removeChild(view);
		}

		view.mouseChildren = false;
		view.mouseEnabled  = false;
		return view;
	}

	private function onCompleteHandle(event:Event):void {
		if (loader.content is Bitmap) {
			x                = VideoConfig.WIDTH / 2;
			y                = VideoConfig.HEIGHT;
			loader.content.x = -loader.content.width / 2;
			loader.content.y = -loader.content.height / 2;
		} else {
			x = endPoint.x;
			y = endPoint.y;
		}
		loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onCompleteHandle);
		var disTime:Number = 0;
		if (giftData.time == 0) {
			disTime = 3;
		} else {
			disTime = giftData.time;
		}
		TweenLite.to(loader, 1, {
			alpha:      0,
//            scaleX: 2,
//            scaleY: 2,
			onComplete: dispose,
			delay:      disTime + Math.random() * 0.2
		});
	}

	private function dispose():void {
		loader.unload();
		loader = null;
		VideoTool.remove(this);
	}
}
}
