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
	import flash.display.DisplayObject;
	import flash.display.Stage;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class Geoms
	{
		public function Geoms() {}

		/**
		 * Solves lots of types of implementation of a set of coordinates
		 * @param a can be a Point or a DisplayObject or a Number (will be x)
		 * @param b can be a DisplayObject to locate 'a' in the local coordinates of b or a Number (will be y). If NaN, y will equal x
		 */

		static public function position(a:*, b:* = NaN):Point
		{
			var p:Point = null;
			
			switch(true)
			{
				case (a is Point):
					p = a.clone();
					break;
					
				case (a is DisplayObject):
					p = new Point(a.x, a.y);
					
					if (b is DisplayObject)
					{
						p = (a as DisplayObject).localToGlobal(new Point());
						p = (b as DisplayObject).globalToLocal(p);
					}
					break;
					
				case (a is Array):
					p = new Point(parseFloat(a[0]), parseFloat(a[1]));
					break;
					
				case !isNaN(a):
					p = new Point(a, !isNaN(b) ? b : a);
					break;	
			
				case (a is Object):	
					p = new Point("x" in a ? a.x : 0, "y" in a ? a.y : 0);
					break;
			}
			
			return p;
		}
		
		/**
		 * solves a lot of types of implementations of a rectangle
		 * @param a can be a Rectangle, a DisplayObject, a Point (will be width and height) or a Number (will be width)
		 * @param b can be a Point (will be x and y) or a Number. If it's NaN, height will be equal to width
		 */		
		static public function rectangle(a:*, b:* = NaN, c:* = NaN, d:* = NaN):Rectangle
		{
			var r:Rectangle = null;
			
			switch(true)
			{
				case (a is Rectangle):
					r = a.clone();
					break;
					
				case (a is Stage):
					r = new Rectangle(0, 0, a.stageWidth, isNaN(b) ? a.stageHeight : b);
					break;
					
				case (a is DisplayObject):
					r = a.getRect(a);
					break;
					
				case (a is Point):
					r = new Rectangle(0, 0, a.x, a.y);
					if (b is Point)	{ r.x = b.x; r.y = b.y; }
					break;
					
				case !isNaN(a):
					r = new Rectangle();
						r.width = a;
						r.height = !isNaN(b) ? b : a;
					
					var p:Point = Geoms.position(c, d);
					
					r.x = p.x;
					r.y = p.y;
					break;
					
				case (a is Object):
					r = new Rectangle("x" in a ? a.x : 0,
									  "y" in a ? a.y : 0,
									  "width" in a ? a.width : 0,
									  "height" in a ? a.height : 0);
					break;		
			}
			
			return r;
		}
		
		static public function divide(arg:*, ratio:*):Point
		{
			arg = position(arg);
			ratio = position(ratio);
			
			var r:Point = arg.clone();
				r.x /= ratio.x;
				r.y /= ratio.y;
				
			return r;
		}
	}
}