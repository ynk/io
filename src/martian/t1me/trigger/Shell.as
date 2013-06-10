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
	import flash.events.IEventDispatcher;
	
	import martian.ev3nts.helpers.on;
	
	import martian.t1me.interfaces.Stackable;
	import martian.t1me.misc.Time;

	public class Shell extends EventDispatcher implements Stackable
	{
		public var t:IEventDispatcher;
		public var f:Function;
		public var e:String;
		public var a:Array;
		
		public function Shell(target:IEventDispatcher, start:Function, stop:String, ...parameters)
		{
			t = target;
			f = start;
			e = stop;
			a = parameters;
		}
		
		public function start():void
		{
			on(t, e, close); 
			
			if (a != null) { f.apply(null, a); }
			else { f.call(); }
		}
		
		private function close():void { dispatchEvent(new Event(Time.STOP)); }
		
		public function dispose():void
		{
			t = null;
			f = null;
			e = "";
			a = null;
		}
	}
}