package taven.common
{
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import taven.utils.ObjectPool;
import taven.utils.baseScroll_taven;

/**
 * @author 抽TList
 */

public class TavenScrollList extends Sprite
{
	public static const ITEM_CLICK:String ="ITEM_CLICK";

	public static const SCROLL_END:String ="SCROLL_END";

	private var _scrollPannel:baseScroll_taven;

	private var _contentView:Sprite;
	/**显示区域*/
	private var _maskRect:Rectangle=new Rectangle(0, 0, 0, 0);

	//是否自动隐藏滚轮
	private var _autoHideScroll:Boolean;



	//项目高度
	private var _track:scaleSprite;
	private var _thumb:scaleSprite;
	private static var thumbImageUI:thumbImage_taven =new thumbImage_taven(13, 46);
	private static var trackImageUI:trackImage_taven =new trackImage_taven(5, 200);

	private var _maxCount:int =5;

	private var _dataList:Array=null;
	/**复用对象池*/
	private var _objectPool:ObjectPool;

	private var _itemList:Array=[];

	private var _curIndex:int= 0;

	private var _maxHeightChange:Boolean= false;

	private var _seclecItem:IListItem;
	/**item的宽和高 */
	private var _itemPoint:Point =new Point(0,0);

	public function TavenScrollList(objectClass:Class,pageSize:int=3,autoHideScroll:Boolean=true)
	{
		_contentView =new  Sprite();
		this.addChild(_contentView);
		_maxCount =pageSize;
		_objectPool=new ObjectPool(objectClass);
		var itemView:IListItem = _objectPool.fetch() as IListItem;
		_itemPoint.y=itemView.view.height;
		_itemPoint.x=itemView.view.width;
		_objectPool.recycle(itemView);
		_thumb=new scaleSprite(thumbImageUI);
		//轨道元件
		_track=new scaleSprite(trackImageUI);
		_track.scale9Grid=new Rectangle(1, 10, 1, 10);
		_track.x+=4
		_scrollPannel=new baseScroll_taven(new Sprite(),_thumb, _track);
		_scrollPannel.view.x=_itemPoint.x-_scrollPannel.view.width ;
		this.addChild(_scrollPannel.view)
		_scrollPannel.autoScale=false; //滑块是否自适应
		_scrollPannel.addEventListener(Event.SCROLL, _selScrollEvent); //滚动事件
		_scrollPannel.addEventListener("scrollFalse", _selScrollFalseEvent); //隐藏事件
		_scrollPannel.addEventListener("scrollTrue", _selScrollTrueEvent); //显示事件;
		updateListView();
		_autoHideScroll =autoHideScroll;
		dataList=[];
		addEventListener(Event.ADDED_TO_STAGE,onAddToStage)
	}

	private function  onAddToStage(evt:Event):void
	{
		if(_autoHideScroll)
		{
			this.addEventListener(MouseEvent.ROLL_OVER, onRollHandle);
			this.addEventListener(MouseEvent.ROLL_OUT, onRollHandle);
			changeScrollBarVisible(false);
			_maxHeightChange =true;
		}
	}

	/**获取所有ui 显示item*/
	public function get itemList():Array
	{
		return _itemList;
	}

	private function checkAutoHide(isForce:Boolean=false):void
	{
		if (_autoHideScroll&&_maxHeightChange||isForce)
		{
			_maxHeightChange =false;
			var _g:Graphics=this.graphics;
			_g.clear();
			_g.beginFill(0x00FF00,0);
			_g.drawRect(0,0, _scrollPannel.view.x+_scrollPannel.view.width+5,maxCount*_itemPoint.y+2);
			_g.endFill();
		}
	}

	public function get seclecItem():IListItem
	{
		return _seclecItem;
	}

	public function set seclecItem(value:IListItem):void
	{
		_seclecItem = value;
	}



	private function changeScrollBarVisible(value:Boolean):void
	{
		if(dataList.length>maxCount)
		{
			_scrollPannel.view.visible = value;
		}
		else
		{
			_scrollPannel.view.visible = false;
		}

	}

	public function get curPostIndex():int
	{
		return _curIndex;
	}
	/**设置数据显示索引 刷新列表*/
	public function set curPostIndex(value:int):void
	{
		_curIndex = value;
		updateDisplauView(_curIndex);
	}

	public function get dataList():Array
	{
		return _dataList;
	}

	public function  set dataList(itemData:Array):void
	{
		_dataList =itemData;
		var validHeight:int=itemData.length * _itemPoint.y - 2;
		var index:int=0;
		_scrollPannel.height =maxCount*_itemPoint.y;
		_scrollPannel.step =(itemData.length-maxCount)+1;

		_scrollPannel.value =_scrollPannel.value;
		if(_scrollPannel.value>=_scrollPannel.step)
		{
			_scrollPannel.value =_scrollPannel.step-1;
		}
		var _scale:Number=validHeight / maxCount*_itemPoint.y;
		curPostIndex = _curIndex;
	}


	public function get maxCount():int
	{
		return _maxCount;
	}

	public function set maxCount(value:int):void
	{
		_maxCount = value;
		_maxHeightChange =true;
		dataList =_dataList;
		updateListView();
	}
	/**重新刷新宽高比*/
	public function flushListView(foceWidth:Number=0,foceHerigt:Number=0):void
	{
		var itemView:IListItem = _objectPool.fetch() as IListItem;
		_itemPoint.y= foceHerigt==0 ?itemView.view.height:foceHerigt;
		_itemPoint.x= foceWidth==0 ?itemView.view.width:foceWidth;
		_scrollPannel.view.x = _itemPoint.x-_scrollPannel.view.width ;
		_objectPool.recycle(itemView);
		checkAutoHide();
		maxCount=_maxCount;
	}

	//调整个滚动条x 位置
	public function adjustScrollPost(xNum:Number):void
	{
		_scrollPannel.view.x += xNum;
		checkAutoHide(true);

	}

	/**根据高度 改变最多显示的项目数*/
	public function updateMaxCountByHeight(heigh:Number):void
	{
		maxCount = heigh/_itemPoint.y;
	}

	private function updateDisplauView(startIndex:int=0):void
	{
		//先做清理工作
		disposeListView()
		var endIndex:int = startIndex+maxCount;
		var index:int=0;
		var selectUid:int=0;
		if(seclecItem&&seclecItem.data)
		{
			selectUid = seclecItem.data.uid;
			seclecItem.select=false;;
			seclecItem=null;
		}
		for (var i:int=startIndex;i<=endIndex;i++)
		{
			if(_dataList[i]!=null)
			{
				var itemView:IListItem = _objectPool.fetch() as IListItem;
				itemView.data = _dataList[i];
				if(selectUid>0&&selectUid==itemView.data.uid)
				{
					seclecItem =itemView;
					seclecItem.select=true;
				}
				_contentView.addChild(itemView.view);
				_itemList.push(itemView);
				itemView.view.y=index*_itemPoint.y;
				index++;
				if(!itemView.view.hasEventListener(MouseEvent.CLICK))
				{
					itemView.view.addEventListener(MouseEvent.CLICK, onClickHandle);
				}
			}
		}
		checkAutoHide();
	}

	private function onClickHandle(evt:MouseEvent):void
	{
		evt.stopImmediatePropagation();
		for each(var item:IListItem  in _itemList)
		{
			if(item.view==evt.currentTarget)
			{
				seclecItem =item;
				seclecItem.select=true;
				break;
			}
		}
		this.dispatchEvent(new Event(ITEM_CLICK));
	}


	//清理工作
	private function disposeListView():void
	{
		if(_itemList.length>0)
		{
			for(var i:int=0;i<_itemList.length;i++)
			{
				var item:IListItem =  _itemList[i];
				if(IListItem)
				{
					try
					{
						_objectPool.recycle(_itemList[i]);
					}
					catch(e:*) {
						trace("_objectPool.recycle-----error");
					}
				}
			}
		}
		_contentView.removeChildren();
		_itemList.length=0;
		if(seclecItem)
			seclecItem.select=false;
	}



	private function onRollHandle(evt:MouseEvent):void
	{

		if (evt.type == MouseEvent.ROLL_OVER)
		{
			changeScrollBarVisible(true);
		}
		else {
			changeScrollBarVisible(false);
		}
	}
	private function  onStageOver(e:Event):void
	{
		trace(e.type);
		trace("e.target.name"+e.target.name	);
	}


	private function _selScrollEvent(e:Event):void
	{
		curPostIndex =_scrollPannel.value;
		if(curPostIndex>0&&_dataList&&_scrollPannel.step<=_scrollPannel.value)
		{
			dispatchEvent(new Event(SCROLL_END));
		}
	}

	private function _selScrollFalseEvent(e:Event):void
	{
		//_contentView.visible=false;
	}

	private function _selScrollTrueEvent(e:Event):void
	{
		//trace("_selScrollTrueEvent = "+_scrollPannel.value);
		//_contentView.visible=true;
	}

	private function updateListView():void
	{
		_maskRect.width=_scrollPannel.view.x+30;
		_maskRect.height = maxCount*_itemPoint.y;
		this.scrollRect=_maskRect;

	}

	/** As3显示对象scrollRect设置之后  高度不对问题    获取原始宽高*/
	/*	public function getFullBounds(displayObject:DisplayObject):Rectangle
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
	 }*/

}

}