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

package martian.m4gic.tools
{
	import flash.utils.getTimer;
	
	public class Chrono
	{
		static private var UID:int = 0;
		
		public var name:String;
		public var auto:Boolean;
		
		private var running:Boolean = false;
		
		private var _start:Number = 0;
		private var _laps:Array = new Array();
		private var _stop:Number = 0;
			public function get time():Number { return _stop - _start; }
			
		public function Chrono(name:String = "", auto:Boolean = true)
		{
			this.name = (name != "") ? name : (UID++).toString();
			this.auto = auto;
			
			if (auto) { start(); }
		}
		
		public function start():void
		{
			if (!running)
			{
				_start = getTimer();
				running = true;
			}
		}
		
		public function lap():void
		{
			if (running)
			{
				_laps.push(getTimer() - _start);
				if (auto) { trace("[CHRONO] '" + name + "' chrono did lap n°" + _laps.length + " at " + _laps[_laps.length - 1] + "ms"); }
			}
		}
		
		public function stop():void
		{
			if (running)
			{
				_stop = getTimer();
				running = false;
				
				if (auto) { trace(toString()); }
			}
		}
		
		public function toString():String
		{
			return !running ? "[CHRONO] '" + name + "' chrono ended after " + time + "ms" : "[CHRONO] '" + name + "' is still running after " + (getTimer() - _start) + "ms";
		}
	}
}