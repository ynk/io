/*
Copyright (c) 2010 julien barbay <barbay.julien@gmail.com>

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/

package martian.ev3nts
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class Listener extends EventDispatcher
	{
		protected var _target:IEventDispatcher = null;
			public function get target():IEventDispatcher { return _target; }
		
		public var stack:Vector.<Function>;
		
		protected var registered:Boolean = false;
		protected var activated:Boolean = false;
			public function get available():Boolean { return (registered && activated); }
		
		protected var event:String;
		
		public function Listener(target:IEventDispatcher, event:String, auto:Boolean = true)
		{
			if (!registered)
			{
				this._target = target;
				this.event = event;

				registered = true;
				stack = new Vector.<Function>;
				
				if (auto) { activate(); }
			}
		}

		public function activate():Boolean
		{
			if (!activated)
			{
				_target.addEventListener(event, fire, false, 0, true);
				activated = true;
				
				return true;
			}
			
			return false;
		}
		
		public function deactivate():Boolean
		{
			if (activated)
			{
				_target.removeEventListener(event, fire, false);
				activated = false;
				
				return true;	
			}
			
			return false;
		}
		
		public function toggle():Boolean
		{
			if (registered)
			{
				activated ? deactivate() : activate();
				return activated;
			}
			
			return false;
		}
		
		protected function fire(e:*):void { perform(e); }
		
		public function perform(event:* = null):void
		{
			for (var i:int = 0; i < stack.length; i++)
			{
				try { stack[i].call(null); }
				catch(e:ArgumentError) { stack[i].call(null, event); }
			}
		}
		
		final public function add(method:Function):Boolean
		{
			if (available)
			{
				stack.push(method);
				return true;
			}
			
			return false;
		}
		
		final public function remove(method:Function = null):Boolean
		{
			if (available)
			{
				for (var i:int = 0; i < stack.length; i++)
				{
					if (method == null || stack[i] == method)
					{
						stack.splice(i, 1); 
						if (method != null) { return true; }
					}
				}
			}
			
			return false;
		}
		
		final public function dispose():Boolean
		{
			if (registered)
			{
				if (activated) { deactivate(); }
					remove();
				
				this._target = null;
				registered = false;
				stack = null;
				
				return true;
			}
			
			return false;
		}
	}
}