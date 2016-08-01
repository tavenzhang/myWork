package taven.sideGroup
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import taven.common.IListItem;
	import net.TavenHttpService;
	import taven.utils.StringUtils;

	public class DateListItemRender extends Sprite  implements IListItem
	{
		static public var HTTP_SUFIX:String;
		/**用于调用弹出窗口*/
		static public var ALERT_FUN:Function;
		/**用于调用弹出窗口*/
		static public var DATE_SUC_FUN:Function;
		private var _view:listItemdate;
		private var _data:*;
		private var _select:Boolean;
		public function DateListItemRender()
		{
			_view = new listItemdate();
			this.addChild(_view);
			_view.btnDate.addEventListener(MouseEvent.CLICK,ondateHandle);
		}
		
		
		/**数据源*/
		public function get data():*
		{
			return _data;
			
		}
		
		/*	返回:{cmd:50005,total:2,type:4,items:[{day:"2015-05-18",time:"17:40:",live_time:"25分钟",points:"500",reuid:111111,re_nickname:代收代付}..]}
		注：total表示总过设置预约数
		type:4(预约房间)
		points表示总共需要多少钻石
		reuid:0表示没有用户预约,>0表示预约用户uid号
		re_nickname:预约用户昵称*/
		/**
		 * @private
		 */
		public function set data(value:*):void
		{
			_data=value;
			if (_data != null)
			{
				this.visible=true;
				_view.txtMoney.text = data.points.toString();
				_view.txtStartTime.text = data.time;
				_view.txtTime.text=data.live_time;
				_view.txtDate.text = data.day;
				switch(data.type)
				{
					case "4":
					default:
						_view.txtType.text="一对一视频";
						break;
				}
				if(data.reuid=="0")
				{
					_view.mcStatue.visible=false;
					_view.btnDate.visible=true;
				}
				else
				{
					_view.mcStatue.visible=true;
					_view.btnDate.visible=false;
				}
			}
			else
			{
				this.visible=false;
			}
		}
		
		private function ondateHandle(evt:MouseEvent):void
		{
			GetHttpService(false);
		
		}
		
		private function GetHttpService(force:Boolean=true):void
		{
			var resultStr:String;
			resultStr=StringUtils.strStitute(HTTP_SUFIX, _data.id, force);
			TavenHttpService.addHttpService(resultStr, s2cFocusStatue);
			
		}
			
		private function s2cFocusStatue(data:String):void
		{
			
			//trace("data =" + data);
			var dataObj:Object=JSON.parse(data);
			var msg:String;
		/*	switch(dataObj.code)
			{
				case 401:
					msg = "您预约的房间不存在.";
					break;
				case 402:
					msg = "您预约的房间已经下线了.";
					break;
				case 403:
					msg = "您预约的房间已经被预定了，您来晚了.";
					break;
				case 404:
					msg = "自己不能预约自己的房间.";
					break;
				case 405:
					msg = "余额不足哦，请充值.";
					break;
				case 1:
					msg = "预定成功!";
					DATE_SUC_FUN();
					break;
				case 407:
					msg = "您这个时间段有房间预约了，您确定要预约么?";
					break;
				case 0:
					msg = "您这个时间段有房间预约了，您确定要预约么?";
					break
				default:
					msg="未知code "+dataObj.code;
					
			}*/
	
			if(	dataObj.code== 407)
			{
				ALERT_FUN(dataObj.msg,"",false,3,true,function (_v:*):void {
					if (_v == 1) {
						GetHttpService(true);
					}
				});
			}
			else
			{
				ALERT_FUN(dataObj.msg,"");
				if(dataObj.code== 1)
				{
					DATE_SUC_FUN();
				}
			}
				
			/*Show("亲,如果您退出房间就会中断直播,您确定还要退出房间吗?", "亲,别走", false, 3, true, function (_v:*):void {
				if (_v == 1) {
					ClientManger.getInstance().gotoHall();//切换房间
				}*/
			//      showAlert(title :String = "",mession:String = "消息",isAlone:Boolean = true,buttonNum:int = 3,a5:Boolean = false,callBack:Function = null,other:Object = null):void;
	
		/*	{"code":401,"msg":"您预约的房间不存在"}
			{"code":402,"msg":"您预约的房间已经下线了"}
			{"code":403,"msg":"您预约的房间已经被预定了，您来晚了"}
			{"code":404,"msg":"自己不能预约自己的房间"}
			{"code":405,"msg":"余额不足哦，请充值！"}
			{"code":407,"msg":"您这个时间段有房间预约了，您确定要预约么"}
			{"code":1,"msg":"预定成功"}*/
		
		}

		
		public function dispose():void
		{
			//this.removeEventListener(MouseEvent.CLICK, onClickHandle);
		}
		
		public function get select():Boolean
		{
			return _select;
		}
		
		public function set select(value:Boolean):void
		{
			_select=value;
			//this.mcSelect.visible=_select;
		}
		
		public function  get view():DisplayObject
		{
			return this;
		}

	}
}