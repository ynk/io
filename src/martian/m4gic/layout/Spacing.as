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

package martian.m4gic.layout
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class Spacing extends EventDispatcher
	{
		public function Spacing(css:String = "0") { all.apply(null, css.split(",")); }
		
		private var l:Number = 0;
			public function get left():Number { return l; }
			public function set left(value:Number):void { l = value; update(); }	
		
		private var r:Number = 0;
			public function get right():Number { return r; }
			public function set right(value:Number):void { r = value; update(); }		
		
		private var t:Number = 0;
			public function get top():Number { return t; }
			public function set top(value:Number):void { t = value; update(); }
		
		private var b:Number = 0;
			public function get bottom():Number { return b; }
			public function set bottom(value:Number):void { b = value; update(); }
		
		public function horizontal(left:Number, right:Number = NaN):void
		{
			l = left;
			r = !isNaN(right) ? right : left;
			
			update();
		}
		
		public function vertical(top:Number, bottom:Number = NaN):void
		{
			t = top;
			b = !isNaN(bottom) ? bottom : top;
			
			update();
		}
		
		public function all(top:Number = NaN, right:Number = NaN, bottom:Number = NaN, left:Number = NaN):void
		{
			
			
			
			update();
		}
		
		public function reset():void
		{
			left = right = top = bottom = 0;
			update();
		}
		
		private function update():void { dispatchEvent(new Event(Event.CHANGE)); }
	}
}