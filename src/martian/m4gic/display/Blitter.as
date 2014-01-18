/**
 * User: y_nk
 * Date: 17/01/2014 19:30
 */
package martian.m4gic.display
{

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.Event;

	import martian.ev3nts.helpers.on;
	import martian.m4gic.exec;



	public class Blitter extends Shape
	{
		static public const REFRESH:String = "refresh";

		private var src:DisplayObject,
					buffer:BitmapData;

		public function Blitter(source:DisplayObject, enterframe:Boolean = true)
		{
			src = source;

			if (src.parent) { src.parent.removeChild(src); }
			src.addEventListener(REFRESH, refresh);
			refresh();

			if (enterframe)
				on(this, Event.ADDED_TO_STAGE, exec(addEventListener, Event.ENTER_FRAME, refresh));
		}

		public function refresh(e:Event = null):void
		{
			graphics.clear();

			if (!buffer)
				buffer = new BitmapData(500, 700, true, 0);

			buffer.fillRect(buffer.rect, 0);
			buffer.draw(src);

			graphics.beginBitmapFill(buffer, null, false, false);
			graphics.drawRect(0, 0, buffer.width, buffer.height);
			graphics.endFill();
		}

		public function dispose(e:Event):void
		{
			if (hasEventListener(Event.ENTER_FRAME))
				removeEventListener(Event.ENTER_FRAME, refresh);

			buffer.dispose();
			graphics.clear();
		}
	}
}
