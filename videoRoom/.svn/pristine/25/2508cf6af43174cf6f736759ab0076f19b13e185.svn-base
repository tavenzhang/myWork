package shareElement {
	import flash.display.MovieClip;
	import flash.text.TextField;
	public class logo extends MovieClip {
		public var num_txt:TextField;
		public function logo() {
			
		}
		public function set peopleInfo(_obj:Object):void {
			var _now:int = _obj.total + _obj.guests  ;
			var _vip:int = _obj.total - _obj.guests  ;
			if (_now < 0) {
				_now = 0;
			}
			if (_vip <0 ) {
				_vip = 0;
			}
			this.num_txt.htmlText = "<b><font size='12' color='#ffffff'>总:</font><font size='14' color='#fefe00'>"+ _now+"</font><font size='12' color='#ffffff'> 人</font></b><br><font size='12' color='#ffffff'>会员:</font><font size='14' color='#da9bb0'>"+_vip+"</font><br><font size='12' color='#ffffff'>游客:</font><font size='14' color='#ffffff'>"+(_now-_vip)+"</font>";
		}
	}
	
}
