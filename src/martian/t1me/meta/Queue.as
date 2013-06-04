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

package martian.t1me.meta
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import martian.ev3nts.helpers.on;
	
	import martian.t1me.interfaces.*;
	import martian.t1me.misc.Time;
	
	public class Queue extends EventDispatcher implements Stackable, Progressive, Pausable
	{
		public var stack:Vector.<Stackable>;
		
		private var i:int = 0;
			
		protected var l:int = 0;
			
		private var p:Boolean = false;
		
		private var s:int = 0;
			public function get status():int { return s; }
			
		private var q:int = 0;
		private var t:int = 0;
		private var g:int = 0;
			public function get progress():Number
			{
				var n:Number = t;
				for each(var b:* in c) { n += (b is Progressive) ? b.progress : 0; }
				
				return n / g;
			}		
			
		private var c:Array;	
			
			
		/**
		 * Implements a hybrid stack of Sequencable objects
		 * @param limit : max Sequencable objects that can run at the same time
		 * @param args : an array of Sequencable objects. Will be pushed in the stack
		 */
			
		public function Queue(limit:int = 2, ...args)
		{
			l = limit;
			
			stack = new Vector.<Stackable>();
			
			if (args[0] is Array && args.length == 1) { args = args[0]; }
			
			for each (var arg:* in args)
			{
				if (arg is Stackable) { stack.push(arg); }
				else { trace("Warning:", arg, "does not implement Stackable (skipped)"); }
			}
		}
		
		public function start():void
		{
			if (s == Time.STOPPED)
			{
				tell(Time.START);
				
				c = new Array();
				
				i = q = t = 0;
				g = stack.length;
				if (l < 0) { l = g; }
				
				p = false;
				s = Time.RUNNING;
				
				for (var a:int = 0; a < l; a++) { launch(); }
			}
		}

		private function launch():void
		{
			if (i < g)
			{
				stack[i].addEventListener(Time.STEP, step);
				stack[i].addEventListener(Time.STOP, stop);
				   stack[i].start();
					
				c.push(stack[i]);
				
				i++;
				q++;
			}
		}
		
		public function pause():void
		{
			if (s == Time.RUNNING)
			{
				p = true;
				s = Time.PAUSED;
			}
		}
		
		public function resume():void
		{
			if (s == Time.PAUSED)
			{
				p = false;
				s = Time.RUNNING;
				
				for (var a:int = 0; a < l; a++) { launch(); }
			}
		}
		
		private function step(e:Event):void { tell(Time.STEP); }
		
		private function stop(e:Event):void
		{
			if (p) { i--; return; }
				t++; q--;
				
			e.target.addEventListener(Time.STEP, step);
			e.target.addEventListener(Time.STOP, stop);	
				
			var j:int = 0, m:int = c.length;
			for (j; j < m; j++)	{ if (e.target == c[j]) { c.splice(j, 1); break; } }
				
			if (t == g)
			{
				tell(Time.STOP);
				tell(Event.COMPLETE);
				
				s = Time.STOPPED;
				
				return;
			}
			else if (q < l)
			{
				var d:int = l - q;
				while(d-- > 0) { launch(); }
			}
		}
		
		public function dispose():void { stack = null; }
		
		protected function tell(e:String):void { dispatchEvent(new Event(e)); }
	}
}