package shareElement{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	public class loadMaterial extends MovieClip {
		public var logo_mc:MovieClip;	
		public var loading_mc:MovieClip;
		public var mask_mc:MovieClip;
		
		private var _loader:Loader = null;
		private var _loaderContext :LoaderContext = new LoaderContext(true);
		private var _url:String = "";//判断图片加载路径是否一致
		private var _w:Number=0;
		private var _h:Number=0;
		public function loadMaterial():void {
			this.logo_mc.visible = false;
			this.loading_mc.visible = false;
			this.loading_mc.stop();
			
			this.mask_mc.visible = false;
			
			this._loader = new Loader;
			this._loader.x = 0;
			this._loader.y = 0;
			this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE, _onCompleteEvent);
			this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _onErrorEvent);
			this.addChildAt(this._loader, this.getChildIndex(this.mask_mc));
			this._loader.visible = false;
		}
		public function load(_url : String, _bool:Boolean = false) : void {
			if (this._url != _url || _bool) {//bool:强制更新
				this._loader.scaleX = this._loader.scaleY = 1;
				this._loader.visible = false;
				this.logo_mc.visible = false;
				
				this.loading_mc.play();
				this.loading_mc.visible = true;					
				try{
					this._loader.unloadAndStop();
					this._loader.unload();
				}catch (e:*) {
				}
				
				this._loader.load(new URLRequest(_url), this._loaderContext);
				this._url = _url;
			}
		}
		//------------------------load;
		private function _onCompleteEvent(e : Event) : void {
			try{
				var bitmap :Bitmap = Bitmap(e.target.content);
				if (bitmap) {
					bitmap.smoothing = true;
					if(this._w!=0){
						bitmap.width = this._w;
					}
					if (this._h != 0) {
						bitmap.height = this._h;
					}									
				}
			}catch (e:*) {				
			}
			this._loader.x = -this._loader.width / 2;
			this._loader.y = -this._loader.height / 2;
			
			this.logo_mc.visible = false;
			this.loading_mc.visible = false;
			this.loading_mc.stop();
			this._loader.visible = true;			
		}
		private function _onErrorEvent(e : IOErrorEvent = null) : void {
			this.loading_mc.stop();
			this.loading_mc.visible = false;
			this.logo_mc.visible = true;
			this._loader.visible = false;
		}
		
		//*w
		override public function get width():Number 
		{
			return this._w;
		}
		
		override public function set width(value:Number):void 
		{
			this._w = value;
			this.logo_mc.width = this.mask_mc.width = value;
			this.logo_mc.x = this.loading_mc.x = this.mask_mc.x = -value / 2;
			this._loader.mask = this.mask_mc;
			
		}
		//*h
		override public function get height():Number 
		{
			return this._h;
		}
		
		override public function set height(value:Number):void 
		{
			this._h = value;
			this.logo_mc.height = this.mask_mc.height = value;
			this.logo_mc.y = this.loading_mc.y = this.mask_mc.y = -value / 2;
			this._loader.mask = this.mask_mc;
		}
	}
}