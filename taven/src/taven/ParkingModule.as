package taven
{
import com.greensock.TweenLite;
import com.greensock.easing.Expo;
import com.rover022.ModuleNameType;
import display.BaseModule;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;

import taven.enum.StringConst;
import taven.parking.ParkingItemRender;
import taven.utils.DisplayUtils;
import taven.utils.MathUtils;
import taven.utils.ObjectPool;

public class ParkingModule extends BaseModule
	{
		private var _view:taven_parkingView;

		private var _data:Array;

		private var PAGE_SIZE:int=1;
		private const MAX_PAGE_SIZE:int=5;
		private var _curPage:int=1;

		private var _isSacle:Boolean=false;
		/**页面显示大小*/
		private var _pageSize:int=1;

		private var _dataPool:ObjectPool;

		private var _itemList:Array;
		
		private var _isFirstData:Boolean=true;
		public function ParkingModule()
		{
			_view=new taven_parkingView();
			this.addChild(_view);
			super.$view=_view;
			_view.mcControl.btnScale.addEventListener(MouseEvent.CLICK, onScaleView);
			_view.mcControl.mcArrow.mouseEnabled=false;
			_view.mcControl.txtCarNum.mouseEnabled=false;
			_view.mcCarsSp.removeChildren();
			_view.btnPrePage.addEventListener(MouseEvent.CLICK, onPageClick);
			_view.btnNextPage.addEventListener(MouseEvent.CLICK, onPageClick);
			_view.btnShop.addEventListener(MouseEvent.CLICK, onShopClick);
			_dataPool=new ObjectPool(ParkingItemRender);
			_itemList=[];
			updateData([]);
		}

		private function onPageClick(evt:Event):void
		{
			if (_data && _data.length > 0)
			{
				if (evt.currentTarget == _view.btnPrePage)
				{
					updateCarView(_curPage - 1, _data);
				}
				else
				{
					updateCarView(_curPage + 1, _data);
				}
			}
		}

		private function onViewClick(evt:MouseEvent):void
		{
		}


		 public function test():void
		{
			var dataArr:Array=[];
			for (var i:int=0; i < 8; i++)
			{
				var object:Object={};
				object.name="carName" + int(Math.random() * 50);
				object.carUrl=StringConst.DEFAULT_IMG;
				object.uid=i;
				dataArr.push(object);
			}
			updateData(dataArr);
		}

		private function onShopClick(evt:MouseEvent):void
		{
			navigateToURL(new URLRequest(this.videoRoom.getDataByName(ModuleNameType.HTTPFUNCROOT) +"/shop"));
		}
		private function onScaleView(evt:MouseEvent):void
		{
			if (PAGE_SIZE != MAX_PAGE_SIZE)
			{
				_isSacle=true;
				_view.mcControl.mcArrow.scaleX*=-1;
			}
			else
			{
				_isSacle=false;
				_view.mcControl.mcArrow.scaleX=1;
			}
			if (_isSacle)
			{
				if (_data)
				{
					if (_data.length > 0)
						PAGE_SIZE=MAX_PAGE_SIZE;
				}

			}
			else
			{
				PAGE_SIZE=pageSize;
			}
			if (_data)
				updateCarView(_curPage, _data);
		}



		/**设置车辆数据*/
		public function updateData(dataArr:Array, isDelete:Boolean=false):void
		{
			dataArr=(dataArr == null) ? [] : dataArr;
			var isChange:Boolean=false;
			if (isDelete) //删除元素
			{
				for (var i:int=0; i < dataArr.length; i++)
				{
					for each (var item:Object in _data)
					{
						if (item.uid == dataArr[i].uid)
						{
							_data.splice(_data.indexOf(item), 1);
							isChange=true;
							break;
						}
					}
				}
			}
			else
			{
				if (!_data)
				{
					_data=dataArr;
					isChange=true;
				}
				else
				{
					var isNew:Boolean;
					for (i=0; i < dataArr.length; i++)
					{
						isNew=true;
						for each (var item2:Object in _data)
						{
							if (item2.uid == dataArr[i].uid)
							{
								isNew=false;
								_data[_data.indexOf(item2)]=dataArr[i];
								isChange=true;
								break;
							}
						}
						if (isNew)
						{
							_data.push(dataArr[i]);
							isChange=true;
						}
					}
				}
			}
			if (isChange)
			{
				updateCarView(_curPage, _data);
			}
		}

		private function updateCarView(curPage:int, carList:Array):void
		{
			_view.mcControl.txtCarNum.text=carList.length.toString();
			var maxPage:int;

			if (PAGE_SIZE > 0)
			{
				maxPage=Math.ceil(carList.length / PAGE_SIZE);
			}
			else
			{
				maxPage=1;
			}

			_curPage=MathUtils.clamp(curPage, 1, maxPage);
			var count:int=(carList.length - (_curPage - 1) * PAGE_SIZE) > PAGE_SIZE ? PAGE_SIZE : (carList.length - (_curPage - 1) * PAGE_SIZE);
			var dataArr:Array=carList.slice((_curPage - 1) * PAGE_SIZE, (_curPage - 1) * PAGE_SIZE + count);
			_view.mcCarsSp.removeChildren();
			for each (var itemRender:ParkingItemRender in _itemList)
			{
				if (itemRender)
				{
					_dataPool.recycle(itemRender);
				}
			}
//			if(dataArr.length>0&&dataArr.length<6)
//			{
//				while(dataArr.length<6)
//				{
//					dataArr.push(dataArr[0]);
//				}
//			}
			for (var i:int=0; i < dataArr.length; i++)
			{
				var item:ParkingItemRender=_dataPool.fetch() as ParkingItemRender; //new ParkingItemRender();
				_itemList.push(item);
				item.data=dataArr[i];
				item.x=i * item.width;
				_view.mcCarsSp.addChild(item);
				item.cacheAsBitmap=true;
			}
			DisplayUtils.enableButton(_view.btnPrePage, _curPage > 1);
			DisplayUtils.enableButton(_view.btnNextPage, _curPage < maxPage);
			_view.btnPrePage.visible=_view.btnNextPage.visible=maxPage > 1;
			//var visibleRect:Rectangle=new Rectangle(0, -30, _view.mcBg.x + _view.mcBg.width, _view.height + 30)
			//var fixWithNum:int=  _view.mcCarsSp.width>0 ?  _view.mcCarsSp.width:PAGE_SIZE*115;
			var fixWithNum:int=PAGE_SIZE * 115 + 10;
			var pageVisible:Boolean;
			var starWidth:Number=this._view.mcBg.width;
			
			if (PAGE_SIZE == 0)
			{
				fixWithNum=0;
			}
			if(!_isFirstData)
			{
				TweenLite.to(_view.mcBg, 0.3, {width: fixWithNum, ease: Expo.easeInOut, onUpdate: function():void
				{
					_view.mcControl.x=-_view.mcBg.width-_view.mcControl.width+1;
					_view.btnShop.x =_view.mcControl.x+60;
					_view.mcCarsSp.x=_view.mcControl.x+110;
					//visibleRect.width=_view.mcBg.x+_view.mcBg.width;
					//_view.scrollRect=visibleRect;
				}, onComplete: function():void
				{
					pageVisible= (_view.mcControl.mcArrow.scaleX==-1)&&maxPage > 1;
					_view.btnPrePage.visible=_view.btnNextPage.visible=pageVisible;
				}})
			}
			else
			{
				_isFirstData =false;
				_view.mcBg.width =0;
				_view.mcControl.x=-_view.mcBg.width-_view.mcControl.width+1;
				_view.btnShop.x =_view.mcControl.x+60;
				_view.mcCarsSp.x=_view.mcControl.x+110;
				pageVisible= (_view.mcControl.mcArrow.scaleX==-1)&&maxPage > 1;
				_view.btnPrePage.visible=_view.btnNextPage.visible=pageVisible;
			}
		
		}

		/**显示页 的数量*/
		public function get pageSize():int
		{
			return _pageSize;
		}
		/**
		 * @private
		 */
		public function set pageSize(value:int):void
		{
			if (_pageSize != value)
			{
				_pageSize=MathUtils.clamp(value, 0, 5);
				PAGE_SIZE=_pageSize;
				updateCarView(_curPage, _data);
			}
		}

	}
}
