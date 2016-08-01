/**
 * Created by ws on 2015/6/18.
 */
package taven.common {
    import com.greensock.TweenLite;
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.MovieClip;

    public class progress extends MovieClip {
        public var mask_mc:MovieClip;//用作width小于bar_mc最小width的时候
        public var bar_mc:MovieClip;
        protected var _value:int = 0;//当前值
        protected var _step:int = 0;//总长度
        private var totalValue:int = 135;
        public function progress(uiView:MovieClip) {
            mask_mc = uiView.mask_mc;
            bar_mc= uiView.bar_mc
            this.bar_mc = new scaleSprite(this.bar_mc);
            this.bar_mc.mask = this.mask_mc;
        }
        //*数值
        public  function set value(_v:int):void {
            if (_v < 0) {
                _v = 0;
            }else if (_v >this.step){
                _v = this.step;
            }
            this._value = _v;

            this.renderProgress();
        }
        public  function get value():int {
            return this._value;
        }
        //*步长
        public  function set step(_v:int):void {
            if (_v < 0) {
                _v = 0;
            }
            this._step = _v;

            if (this._step == 0) {
                this.value = 0;
                this.bar_mc.visible = false;
            }else {
                this.bar_mc.visible = true;
            }
            this.renderProgress();
        }
        public  function get step():int {
            return this._step;
        }
        private function renderProgress():void {
            if (this.bar_mc.visible) {
                this.mask_mc.width = int(this.value / this.step * this.totalValue * 10) / 10+1;
                TweenLite.to(this.bar_mc, 1, { "width":this.mask_mc.width - 1 } );
            }
        }
    }
}
