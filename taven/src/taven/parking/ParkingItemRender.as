package taven.parking
{
import taven.seatView.LoadMaterial;

public class ParkingItemRender extends taven_parkingItemRender
	{
		private var _carView:LoadMaterial;
		
		private var _data:*;
		public function ParkingItemRender()
		{
			this.mcIcoSp.removeChildren();
			_carView = new LoadMaterial();
			_carView.width =70;
			_carView.height=70;
			//_carView.x= _carView.width/2;
			//_carView.y= _carView.height/2;
			this.mcIcoSp.addChild(_carView);
			this.mouseChildren=false;
			_carView.loading_mc.x =0;
			_carView.loading_mc.y =0;
		}

		public function get data():*
		{
			return _data;
		}
	
		/*
		 * 	{hostName:}
		*/
		public function set data(value:*):void
		{
			_data = value;
			if(_data)
			{
				this.txtHostName.text = data.name;
				_carView.load(data.carUrl,true); 
			}
		
		}
		
		public function dispose():void
		{
			
		}

	}
}