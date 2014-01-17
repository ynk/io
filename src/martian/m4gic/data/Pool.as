/**
 * User: y_nk
 * Date: 16/01/2014 21:08
 */
package martian.m4gic.data
{

	import flash.events.Event;
	import flash.events.EventDispatcher;



	public class Pool extends EventDispatcher
	{
		static public const INFLATE:String = "poolInflate";

		private var type:Class;

		private var free:Array = [],
					busy:Array = [];

		public function Pool(type:Class, amount:int = 1)
		{
			this.type = type;

			for (var i:int = 0; i < amount; i++)
				free[i] = new type();
		}

		public function pick():*
		{
			if (free.length == 0)
			{
				free.push(new type());
				dispatchEvent(new Event(INFLATE));
			}

			busy.push(free.pop());
			return busy[busy.length - 1];
		}

		public function release(object:* = null):Boolean
		{
			if (object == null)
			{
				free = free.concat(busy);
				busy = [];

				return true;
			}


			for (var i:int = 0, l:int = busy.length; i < l; i++)
			{
				if (object === busy[i])
				{
					busy.splice(i, 1);
					free.push(object);
					return true;
				}
			}

			return false;
		}

		public function destroy():void
		{
			release();

			for (var i:int = 0, l:int = free.length; i < l; i++)
				free[i] = null;

			free = null;
		}

		public function each(callback:Function):void
		{
			for (var i:int = 0, l:int = free.length; i < l; i++)
				callback(free[i]);
		}
	}
}
