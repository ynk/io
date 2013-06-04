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

package martian.t1me.trigger
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import martian.t1me.interfaces.Pausable;
	import martian.t1me.interfaces.Progressive;
	
	import flash.utils.setTimeout;
	
	import martian.t1me.interfaces.Stackable;
	import martian.t1me.misc.Time;
	
	public class Call extends EventDispatcher implements Stackable, Progressive, Pausable
	{
		private var f:Function,
					a:Array,
					t:uint,
					c:int,
					d:int,
					s:int;
		
		public function get progress():Number { return (c / 100); }
		
		public function get status():int { return s; }
		
		
		
		public function Call(func:Function, delay:Number = 0, ...args):void
		{
			f = func;
			a = args;
			d = delay;
			
			t = 0;
			c = 0;
			
			s = Time.STOPPED;
		}
		
		public function start():void
		{
			s = Time.RUNNING;
			t = setInterval(step, d / 100);
			
			dispatchEvent(new Event(Time.START));
		}
		
		private function step():void
		{
			if (c++ >= 100)
			{
				clearInterval(t);
				stop();
			}
			else { dispatchEvent(new Event(Time.STEP)); }
		}
		
		public function pause():void 
		{
			if (s == Time.RUNNING)
			{
				clearInterval(t);
				s = Time.PAUSED;
			}
		}
		
		public function resume():void 
		{
			if (s == Time.PAUSED)
			{
				t = setInterval(step, d / 100);
				s = Time.RUNNING;
			}
		}
		
		private function stop():void
		{
			s = Time.STOPPED;
			
			if (f != null)
			{
				if (a != null) { f.apply(null, a); }
				else { f.call(); }
			}
			
			dispatchEvent(new Event(Time.STOP));
		}
		
		public function dispose():void
		{
			f = null;
			a = null;
			d = 0;
		}
	}
}