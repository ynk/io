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

package martian.m4gic.data 
{
	import flash.geom.Point;
	import martian.m4gic.tools.Maths;
	
	public class Angle
	{
		static public const DEGREES:String = "degrees";
		static public const RADIANS:String = "radians";
		
		static public const PI:Number = Math.PI;
		
		static private const TO_DEG:Number = 180 / PI;
		static private const TO_RAD:Number = 1 / TO_DEG;
		
		public var mode:String = DEGREES;
		
		public function get value():* { return (mode == DEGREES) ? degrees : radians; }
		public function set value(n:*):void 
		{
			if (mode == DEGREES) { degrees = n; }
			else { radians = n; }
		}
		
		private var d:Number = 0;
			public function get degrees():Number { return d; }
			public function set degrees(n:Number):void { d = Maths.loop(n, -180, 180); update(RADIANS); }
		
		private var r:Number = 0;
			public function get radians():Number { return r; }
			public function set radians(n:Number):void { r = Maths.loop(n, -PI, PI); update(DEGREES); }
		
		public function get cos():Number { return Math.cos(r); }
		public function get sin():Number { return Math.sin(r); }
		public function get tan():Number { return Math.tan(r); }			
			
		private function update(m:String):void
		{
			if (m == RADIANS) { r = d * TO_RAD; }
			else { d = r * TO_DEG; }
		}
		
		public function Angle(n:Number, mode:String = DEGREES)
		{
			this.value = n;
			this.mode = mode;
		}
		
		public function spot(distance:Number):Point { return new Point(distance * cos, distance * sin); }
		
		public function toString():String { return "[Angle degrees:" + degrees + ", radians:" + radians + ", mode:" + mode.toUpperCase() + "]"; }
	}
}