package taven.utils
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Elastic;

	import flash.display.DisplayObject;

	import taven.constant.Align;

	public class TweenHelp
	{
		/**
		 * 淡入/淡出
		 * @param view
		 * @param duration
		 * @param startAlpha
		 * @param endAlpha
		 * @param onComplete
		 *
		 */
		public static function fade(view:DisplayObject, duration:Number, startAlpha:Number=0.0, endAlpha:Number=1.0, onComplete:Function=null):void
		{
			view.alpha=startAlpha;
			TweenLite.to(view, duration, {alpha: endAlpha, onComplete: onComplete});
		}

		/**
		 * 闪烁效果
		 * @param view
		 * @param duration
		 * @param times 闪烁次数
		 * @param onComplete
		 */
		public static function blink(view:DisplayObject, duration:Number, times:int, onComplete:Function=null):void
		{
			var interval:Number=duration / times;
			var i:int=0; //这里i加1代表完成半次，而非1次

			TweenLite.to(view, interval / 2, {alpha: .1, onComplete: eachBlink});

			function eachBlink():void
			{
				i++;
				if (i >= times * 2)
				{
					if (onComplete != null)
					{
						onComplete();
					}

				}
				else
				{
					if (i % 2 == 1)
					{
						TweenLite.to(view, interval / 2, {alpha: 1, onComplete: eachBlink});
					}
					else
					{
						TweenLite.to(view, interval / 2, {alpha: .1, onComplete: eachBlink});
					}
				}
			}

		}

		public static function fromBlur(view:DisplayObject, duration:Number):void
		{
			TweenLite.from(view, duration, {blurFilter: {blurX: 20, blurY: 20, remove: true}});
		}

		public static function motionFrom(view:DisplayObject, duration:Number, fromdir:int):void
		{
			switch (fromdir)
			{
				case Align.LEFT:
				{
					TweenLite.from(view, duration, {x: -view.width, ease: Elastic.easeOut});
					break;
				}
				case Align.RIGHT:
				{
					TweenLite.from(view, duration, {x: -view.stage.stageWidth, ease: Elastic.easeOut});
					break;
				}
				case Align.TOP:
				{
					TweenLite.from(view, duration, {y: -view.height, ease: Elastic.easeOut});
					break;
				}
				case Align.BOTTOM:
				{
					TweenLite.from(view, duration, {y: -view.stage.stageHeight, ease: Elastic.easeOut});
					break;
				}
			}
		}

		public static function scaleFrom(view:DisplayObject, duration:Number, blur:Boolean=true):void
		{
			if (blur)
			{
				TweenLite.from(view, duration, {scaleX: 0.1, scaleY: 0.1, ease: Elastic.easeOut, blurFilter: {blurX: 20, blurY: 20, remove: true}});
			}
			else
			{
				TweenLite.from(view, duration, {scaleX: 0.1, scaleY: 0.1, ease: Elastic.easeOut});
			}
		}
	}
}
