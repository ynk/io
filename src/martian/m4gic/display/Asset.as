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

package martian.m4gic.display 
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	public class Asset extends Sprite 
	{
		private var smooth:Boolean;
		
		private var input:BitmapData;

		private var _width:Number = 0;
		private var _height:Number = 0;
		private var _scaleX:Number = 1;
		private var _scaleY:Number = 1;
		private var _scale9:Rectangle = null;
		
		private var m:Matrix;
		private var widths:Vector.<Number> = new Vector.<Number>(3, true);
		private var heights:Vector.<Number> = new Vector.<Number>(3, true);
		
		public function Asset(bitmapData:BitmapData = null, smoothing:Boolean = false, scale9:Rectangle = null)
		{
			input = bitmapData;
			smooth = smoothing;
			
			_width = input.width;
			_height = input.height;
			
			if (scale9 != null) { scale9Grid = scale9; }
			else { refresh(); }
		}
		
		private function refresh():void
		{
			if (_scale9 == null)
			{
				graphics.clear();
				graphics.beginBitmapFill(input, null, false, smooth);
				graphics.drawRect(0, 0, input.width, input.height);
				graphics.endFill();
				
				return;
			}

			m = new Matrix();
			
			var ax:int = 0, ay:int = 0,
				bx:Number = 0, by:Number = 0,
				cx:Number = 0, cy:Number = 0,
				ux:Number = 0, uy:Number = 0,
				vx:Number = 0, vy:Number = 0;
			
			var rx:Number = _width - widths[0] - widths[2],
				ry:Number = _height - heights[0] - heights[2];
						
			graphics.clear();
			
			for (ax = 0; ax < 3; ax++)
			{
				ux = widths[ax];
				vx = (ax != 1) ? widths[ax] : rx;
				
				by = cy = 0;
				
				for (ay = 0; ay < 3; ay++)
				{
					uy = heights[ay];
					vy = (ay != 1) ? heights[ay] : ry;
					
					if ((vx > 0) && (vy > 0))
					{
						m.a = vx / ux;
						m.d = vy / uy;
						m.tx = - bx * m.a + cx;
						m.ty = - by * m.d + cy;
						
						graphics.beginBitmapFill(input, m, false, smooth);
						graphics.drawRect(cx, cy, vx, vy);
						graphics.endFill();
					}
					
					by += uy;
					cy += vy;
				}
				
				bx += ux;
				cx += vx;
			}			
		}
		
		override public function get width():Number { return _width; }
		override public function set width(value:Number):void 
		{
			_width = value;
			_scaleX = 1;
			
			refresh();
		}
		
		override public function get height():Number { return _height; }
		override public function set height(value:Number):void 
		{
			_height = value;
			_scaleY = 1;
			
			refresh();
		}
		
		override public function get scaleX():Number { return _scaleX; }
		override public function set scaleX(value:Number):void 
		{
			_scaleX = value;
			_width = input.width * _scaleX;
			
			refresh();
		}
		
		override public function get scaleY():Number { return _scaleY; }
		override public function set scaleY(value:Number):void 
		{
			_scaleY = value;
			_height = input.height * _scaleY;
			
			refresh();
		}
		
		override public function get scale9Grid():Rectangle { return _scale9; }
		override public function set scale9Grid(value:Rectangle):void 
		{
			_scale9 = value;
			
			widths[0] = _scale9.left;
			widths[1] = _scale9.width;
			widths[2] = input.width - _scale9.right;
			
			heights[0] = _scale9.top;
			heights[1] = _scale9.height;
			heights[2] = input.height - _scale9.bottom;
			
			refresh();
		}
	}
}