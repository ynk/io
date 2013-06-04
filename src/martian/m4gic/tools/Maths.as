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
	import flash.geom.Point;

	public class Maths
	{
		public function Maths() {}
		
		static public function odd(n:Number):Boolean { return (n & 1) == 0; }
		static public function even(n:Number):Boolean { return (n & 1) != 0; }
		static public function positive(n:Number):Boolean { return n > 0; }
		static public function negative(n:Number):Boolean { return n < 0; }
		static public function sign(n:Number):Number { return n > 0 ? 1 : -1; }
		static public function divisible(n1:Number, n2:Number):Boolean { return (n1 % n2) == 0; }
		
		static public function between(n:Number, min:Number, max:Number):Boolean { return (min <= n) && (n <= max); }
		
		static public function square(n:Number):Number { return n * n; }
		static public function abs(n:Number):Number { return (positive(n)) ? n : -n; }
		static public function round(n:Number):int { return (n - floor(n) > .5) ? ceil(n) : floor(n); } 
		static public function floor(n:Number):int { return int(n); }
		static public function ceil(n:Number):int { return int(n) + 1; }
		static public function trim(n:Number, p:int = 2):Number { return parseFloat(n.toFixed(p)); }
		static public function bary(n1:Number, n2:Number):Number { return lerp(.5, n1, n2); }
		static public function lerp(n:Number, n1:Number, n2:Number):Number { return (n1 * (1 - n)) + (n2 * n); }
		static public function clamp(n:Number, min:Number = 0, max:Number = 1):Number { if (n < min) { return min; } else if (n > max) { return max; } return n; }
		static public function normalize(n:Number, min:Number, max:Number):Number { return (n - min) / (max - min); }
		
		static public function line(n:Number, x1:Number, y1:Number, x2:Number, y2:Number):Point
		{
			var p1:Point = new Point(x1, y1),
				p2:Point = new Point(x2, y2),
				p3:Point,  p4:Point = p1.clone();
				
			p3 = p2.subtract(p1);
				
			p4.x = p4.x + p3.x * n; 
			p4.y = p4.y + p3.y * n;
			
			return p4;
		}
		
		static public function project(n:Number, x1:Number, y1:Number, x2:Number, y2:Number):Point
		{
			var angle:Number = Math.atan2(y2 - y1, x2 - x1),
				p0:Point = new Point(x1, y1);
				
			p0.x = x1 + n * Math.cos(angle);
			p0.y = y1 + n * Math.sin(angle);
			
			return p0;
		}
		
		static public function loop(n:Number, min:Number, max:Number):Number
		{
			var p:int = max - min + 1,
				m:Number = (n - min) % p;
				
    		if(m < 0) { m += p; }
    			
    		return min + m;
		}
		
		static public function map(n:Number, min1:Number, max1:Number, min2:Number, max2:Number):Number
		{ return lerp(normalize(clamp(n, min1, max1), min1, max1), min2, max2); }
		
		static public function sets(items:int, min:Number = 0, max:Number = 1):Array
		{
			var array:Array = new Array(), i:int = 0;
			while (i < items) { array[i] = min + i * (max - min) / items; i++; }
			return array;
		}
		
		static public function random(min:Number = 0, max:Number = 1):Number { return Math.random() * (max - min) + min; }
		
		static public function randoms(items:int, min:Number = 0, max:Number = 1, round:Boolean = false, exclusive:Boolean = false):Array
		{
			var array:Array = new Array(), i:int = 0;
			
			if (exclusive && items <= (max - min + 1))
			{
				while(i < (max - min)) { array.push(i); i++; }
				while(i < items)
				array = Arrays.shuffle(array);
			}
			else { while (i < items) { array.push(Maths.random(min, max)); i++; } }
			
			if (round) { i = 0;  while (i < items) { array[i] = Maths.round(array[i]); i++; } }
			
			return array;
		}
		
		static public function euclide(n1:int, n2:int):int
		{
			n1 = Maths.abs(n1);
			n2 = Maths.abs(n2);
			
			if ((n1 == 0) || (n2 == 0)) { return 0; }
			
			var a:int = n1 > n2 ? n1 : n2;
			var b:int = n1 < n2 ? n1 : n2;
			var r:int = -1;
			
			while (r != 0)
			{
				r = a % b; if (r == 0) { break; }
				a = b; b = r;
			}
			
			return b;
		}
	}
}