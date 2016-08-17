package taven.common
{
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.geom.Transform;

import taven.utils.baseScroll_taven;

/**
	 * @author 抽TList
	 */

	public class TScroll
	{
		private var scrollLogic:baseScroll_taven;

		private var _scroll_mc:Sprite;
		/**显示区域*/
		private var _scrollRect:Rectangle=new Rectangle(0, 0, 0, 0);

		private var _scrollContainer:DisplayObjectContainer;

		private var _itemRenderHeight:Number;

		private var _track:scaleSprite;

		private var _thumb:scaleSprite;

		private var _autoHideScroll:Boolean;

		private var _maxCount:int=0;
		private static var thumbImageUI:thumbImage_taven =new thumbImage_taven(12, 46);
		private static var trackImageUI:trackImage_taven =new trackImage_taven(12, 46);
		
		public function TScroll(container:DisplayObjectContainer, itemHeight:Number=0, maxCount:int=0, autoHideScroll:Boolean=true)
		{
			_scrollContainer=container;
			//产生滚动条
			_scroll_mc=new Sprite();
			if (container.parent)
			{
				container.parent.addChild(_scroll_mc);
				_scroll_mc.y=container.y;
			}
			else
			{
				throw new Error("层级错误");
			}

			_thumb=new scaleSprite(thumbImageUI);
			_thumb.scale9Grid=new Rectangle(5, 22, 1, 1);
			//轨道元件
			_track=new scaleSprite(trackImageUI);
			_track.scale9Grid=new Rectangle(5, 22, 1, 1);
			_track.height=200;

			_scroll_mc.addChild(_track);
			_scroll_mc.addChild(_thumb);

			_itemRenderHeight=itemHeight;
			_maxCount=maxCount;
			_autoHideScroll=autoHideScroll;
			_scroll_mc.x=_scrollContainer.x + _scrollContainer.width - _track.width;
			var validHeight:int=_maxCount * _itemRenderHeight - 2;
			var _scale:Number=validHeight / _scroll_mc.height;
			_thumb.height*=_scale;
			_track.height*=_scale;
			//符加滚动条程序
			scrollLogic=new baseScroll_taven(_thumb, _track);
			scrollLogic.buttonMode=true; //设置手手型
			scrollLogic.autoScale=false; //滑块是否自适应
			scrollLogic.addEventListener(Event.SCROLL, _selScrollEvent); //滚动事件
			scrollLogic.addEventListener("scrollFalse", _selScrollFalseEvent); //隐藏事件
			scrollLogic.addEventListener("scrollTrue", _selScrollTrueEvent); //显示事件;
			
			var nowRact:Rectangle=getFullBounds(_scrollContainer);
			_scrollRect.width=_scrollContainer.x + nowRact.width;
			_scrollRect.height=validHeight;
			//缩放轨道的高度
			scrollLogic.step=nowRact.height - _scrollRect.height; ////总滚值,滑块最大滚动数值
			
			_scroll_mc.visible=scrollLogic.step >5;
			_scrollContainer.scrollRect=_scrollRect;
			var _g:Graphics=_scroll_mc.graphics;
			_g.beginFill(0x00FF00, 0);
			_g.drawRect(-20, -20, _track.width + 45, _track.height + 40);
			_g.endFill();
			_scrollRect.y=0;
			updateListView();
			if (autoHideScroll && _scroll_mc.visible)
			{
				_g=(_scrollContainer as Sprite).graphics;
				_g.clear();
				_g.beginFill(0x00FF00, 0);
				_g.drawRect(_scrollRect.x, _scrollRect.y, nowRact.width, nowRact.height);
				_g.endFill();
				_scrollContainer.addEventListener(MouseEvent.ROLL_OVER, onRollHandle);
				_scrollContainer.addEventListener(MouseEvent.ROLL_OUT, onRollHandle);
				_scroll_mc.addEventListener(MouseEvent.ROLL_OVER, onRollHandle);
				_scroll_mc.addEventListener(MouseEvent.ROLL_OUT, onRollHandle);
				_scroll_mc.visible=false;
			}
		}
		
		

		public function dispose():void
		{
			if (scrollLogic)
			{
				scrollLogic.removeEventListener(Event.SCROLL, _selScrollEvent); //滚动事件
				scrollLogic.removeEventListener("scrollFalse", _selScrollFalseEvent); //隐藏事件
				scrollLogic.removeEventListener("scrollTrue", _selScrollTrueEvent); //显示事件
				_scrollContainer.removeEventListener(MouseEvent.ROLL_OVER, onRollHandle);
				_scrollContainer.removeEventListener(MouseEvent.ROLL_OUT, onRollHandle);
				_scroll_mc.removeEventListener(MouseEvent.ROLL_OVER, onRollHandle);
				_scroll_mc.removeEventListener(MouseEvent.ROLL_OUT, onRollHandle);
				if (_scroll_mc.parent)
				{
					_scroll_mc.parent.removeChild(_scroll_mc);
				}
				scrollLogic.gc();
				_scrollContainer=null;
				_scroll_mc=null;
				scrollLogic=null;
			}
		}

		/**刷新list 滚动*/
	/*	public function update(newRendHeigh:Number=0, newMaxCount:Number=0):void
		{
			_itemRenderHeight=(newRendHeigh <= 0) ? _itemRenderHeight : newRendHeigh;
			_maxCount=(newMaxCount <= 0) ? _maxCount : newMaxCount;
	
		}*/


		private function onRollHandle(evt:MouseEvent):void
		{
			if (evt.type == MouseEvent.ROLL_OVER)
			{
				_scroll_mc.visible=true;

			}
			else
			{
				_scroll_mc.visible=false;
			}
			//trace("_scroll_mc.visible=" +_scroll_mc.visible +"_scroll_mc.x=" +_scroll_mc.x+"_scroll_mc.y=" +_scroll_mc.y);
		}


		private function _selScrollEvent(e:Event):void
		{
			//trace("scrollLogic.value= " + scrollLogic.value);
			_scrollRect.y=scrollLogic.value;
			updateListView();
		}

		private function _selScrollFalseEvent(e:Event):void
		{
			_scroll_mc.visible=false;
		}

		private function _selScrollTrueEvent(e:Event):void
		{
			//trace("_selScrollTrueEvent=" +scroll_mc);
			_scroll_mc.visible=true;
		}

		private function updateListView():void
		{
			_scrollContainer.scrollRect=_scrollRect;
		}

		/** As3显示对象scrollRect设置之后  高度不对问题    获取原始宽高*/
		public function getFullBounds(displayObject:DisplayObject):Rectangle
		{
			var bounds:Rectangle;
			var transform:Transform;
			var toGlobalMatrix:Matrix;
			var currentMatrix:Matrix;
			transform=displayObject.transform;
			currentMatrix=transform.matrix;
			toGlobalMatrix=transform.concatenatedMatrix;
			toGlobalMatrix.invert();
			transform.matrix=toGlobalMatrix;
			bounds=transform.pixelBounds.clone();
			transform.matrix=currentMatrix;
			return bounds;
		}

	}
}
