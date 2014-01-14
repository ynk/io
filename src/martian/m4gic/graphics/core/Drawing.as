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

package martian.m4gic.graphics.core
{
	import flash.display.*;
	import flash.geom.*;
	import martian.m4gic.data.Color;

	import martian.m4gic.data.Ini;

	import martian.m4gic.tools.Geoms;

	public class Drawing
	{
		private namespace linking;
		use namespace linking;

		linking var fired:Boolean = false;

		linking var prev:Drawing = null;
		linking var next:Drawing = null;




		private var graphics:Graphics;
		private var execute:Boolean;

		private var command:String;
		private var parameters:Array;

		public function Drawing(graphics:Graphics, directly:Boolean, clear:Boolean = false):void
		{
			this.graphics	= graphics;
			this.execute	= directly;

			this.command 	= APPLY;
			this.parameters	= null;

			if (clear) { graphics.lineStyle(); graphics.endFill(); }
		}

		private function colorize(input:*):int
		{
			if (input is int) { return input; }
			else if (input is String)
			{
				if (input == "rnd")
					return int(Math.random() * 0xffffff);


				if (input.charAt(0) == "#")
					input = "0x" + input.substr(1);

				if (input.indexOf("0x") == 0)
					return parseInt(input, 16);
			}

			return -1;
		}

		private function link(trash:Boolean):Drawing
		{
			var drawing:Drawing = new Drawing(graphics, execute);

			if (trash) { dispose(); }
			else { drawing.prev.next = this; }

			return drawing;
		}

		private function dispose():void
		{
			parameters = null;
			prev = null;
			next = null;
		}










		//********** STROKE COMMAND **********
		static private const STROKE:String = "stroke";

		public function stroke(weight:Number = 0.5, color:* = 0, alpha:Number = 1, options:Object = null):Drawing
		{
			command = STROKE;
			parameters = arguments;

			if (execute)
			{
				var ini:Ini = new Ini(options),
					hinting:Boolean = ini.boolean("pixelHinting", false),
					scale:String	= ini.string("scaleMode", "normal"),
					caps:String		= ini.string("capStyle", null),
					joints:String	= ini.string("joints", null),
					miter:Number	= ini.number("miterLimit", 3);

				graphics.lineStyle(weight, colorize(color.valueOf()), alpha, hinting, scale, caps, joints, miter);
			}

			return link(execute);
		}

		//********** FILL COMMAND **********
		static private const FILL:String = "fill";

		public function fill(color:* = 0, alpha:Number = 1):Drawing
		{
			command = FILL;
			parameters = arguments;

			if (execute)
			{
				graphics.beginFill(colorize(color.valueOf()), color is Color ? color.alpha : alpha);
			}

			return link(execute);
		}

		//********** GRADIENTFILL COMMAND **********
		static private const GRADIENT:String = "gradient";

		public function gradient(config:Object):Drawing
		{
			command = GRADIENT;
			parameters = arguments;

			if (execute)
			{
				var ini:Ini = new Ini(config),
					width:Number		 = ini.number("width", 0),
					height:Number		 = ini.number("height", 0),
					color1:int 			 = ini.star("color1", 0).valueOf(),
					color2:int 			 = ini.star("color2", 0xffffff).valueOf(),
					alpha1:Number 		 = ini.number("alpha1", 1),
					alpha2:Number 		 = ini.number("alpha2", 1),
					ratio:Number		 = ini.number("ratio", .5),
					angle:Number		 = ini.number("angle", 0),
					type:String			 = ini.string("type", "linear"),
					spread:String		 = ini.string("spreadMethod", "pad"),
					interpolation:String = ini.string("interpolationMethod", "rgb"),
					focal:Number		 = ini.number("focalPointRatio", 0);

				if (ini.star('box'))
				{
					var box:Rectangle = Geoms.rectangle(ini.star('box'));
						width = box.width;
						height = box.height;
				}

				var matrix:Matrix = new Matrix(),
					r1:Number = 0,
					r2:Number = 0;

				matrix.createGradientBox(width, height, angle * Math.PI / 180);

				if (ratio == .5) { r1 = 0; r2 = 1; }
				else if (ratio < .5) { r1 = 0; r2 = 2 * ratio; }
				else { r1 = 2 * ratio - 1; r2 = 1; }

				r1 *= 0xFF;
				r2 *= 0xFF;

				graphics.beginGradientFill(type, [colorize(color1), colorize(color2)], [alpha1, alpha2], [r1, r2], matrix, spread, interpolation, focal);
			}

			return link(execute);
		}

		//********** BITMAPFILL COMMAND **********
		static private const BITMAP:String = "bitmap";

		public function bitmap(source:*, full:* = null, matrix:Matrix = null, smooth:Boolean = true, repeat:Boolean = false):Drawing
		{
			command = BITMAP;
			parameters = arguments;

			if (execute)
			{
				var bmd:BitmapData;

				if (source is Class)
				{
					try { source = new source(); }
					catch(e:Error) {}
				}

				if (source is BitmapData) { bmd = BitmapData(source); }
				else if (source is Bitmap) { bmd = Bitmap(source).bitmapData; }
				else
				{
					bmd = new BitmapData(DisplayObject(source).width, DisplayObject(source).height, true, 0);
					bmd.draw(source);
				}

				if (full != null && full !== false)
				{
					var offset:* = (full !== true) ? Geoms.position(full) : { x:0, y:0 };
					if (full === 'centered')
					{
						offset.x = - bmd.width * .5;
						offset.y = - bmd.width * .5;
					}

					if (!matrix) { matrix = new Matrix(); }

					matrix.tx = offset.x;
					matrix.ty = offset.y;

					full = null;
				}

				graphics.beginBitmapFill(bmd, matrix, repeat, smooth);

				if (full == null && full !== false)
				{
					if (!matrix) { matrix = new Matrix(); }
					rect(bmd.width, bmd.height, matrix.tx, matrix.ty);
				}
			}

			return link(execute);
		}

		//********** MOVE COMMAND *********
		static private const MOVE:String = "move";

		public function move(x:*, y:Number = NaN):Drawing
		{
			command = MOVE;
			parameters = arguments;

			if (execute)
			{
				var p:Point = Geoms.position(x, y);
					graphics.moveTo(p.x, p.y);
			}

			return link(execute);
		}

		//********** LINE COMMAND **********
		static private const LINE:String = "line";

		public function line(x:*, y:Number = NaN):Drawing
		{
			command = LINE;
			parameters = arguments;

			if (execute)
			{
				var p:Point = Geoms.position(x, y);
					graphics.lineTo(p.x, p.y);
			}

			return link(execute);
		}

		public function cross(x:*, y:* = NaN):Drawing
		{
			var p:Point = Geoms.position(x, y);
			return move(p.x - 3, p.y - 3).line(p.x + 3, p.y + 3).move(p.x - 3, p.y + 3).line(p.x + 3, p.y - 3);
		}

		public function shape(...dots):Drawing
		{
			if (dots.length == 1 && dots[0] is Array) { dots = dots[0]; }

			var self:Drawing = this, length:int = dots.length;

			self = self.move(dots[0]);
			for (var i:int = 1; i < length; i++) { self = self.line(dots[i]); }

			return self.line(dots[0]);
		}

		//********** CURVE COMMAND **********
		static private const CURVE:String = "curve";

		public function curve(x:*, y:* = NaN, u:* = NaN, v:* = NaN):Drawing
		{
			command = CURVE;
			parameters = arguments;

			if (execute)
			{
				var p:Point = Geoms.position(x, y),
					c:Point = Geoms.position(u, v);

				if (!c) { c = Geoms.position(y); }

				graphics.curveTo(c.x, c.y, p.x, p.y);
			}

			return link(execute);
		}

		//********** SPLINE COMMAND **********
		static private const SPLINE:String = "spline";

		public function spline(points:Array, closed:Boolean = false, steps:int = 100):Drawing
		{
			command = SPLINE;
			parameters = arguments;

			if (execute)
			{
				var spline:Spline = new Spline();
				for each(var point:* in points) { spline.points.push(Geoms.position(point)); }

				var computed:Vector.<Number> = spline.compute(steps, closed),
					length:int = computed.length;

				graphics.moveTo(computed[0], computed[1]);
				for (var i:int = 0; i < length; i += 2) { graphics.lineTo(computed[i], computed[i + 1]); }
			}

			return link(execute);
		}







		//********** RECT COMMAND **********
		static private const RECT:String = "rect";

		public function rect(width:*, height:* = NaN, x:* = NaN, y:* = NaN):Drawing
		{
			command = RECT;
			parameters = arguments;

			if (execute)
			{
				var r:Rectangle = Geoms.rectangle(width, height, x, y);
					graphics.drawRect(r.x, r.y, r.width, r.height);
			}

			return link(execute);
		}

		public function square(side:Number, centered:Boolean = false, x:Number = 0, y:Number = 0):Drawing
		{
			var offset:Number = centered ? side / 2 : 0;
				return rect(side, side, x - offset, y - offset);
		}

		//********** ROUNDRECT COMMAND **********
		static private const ROUNDRECT:String = "roundrect";

		public function roundrect(width:*, height:* = NaN, x:* = NaN, y:* = NaN, radius:int = 0):Drawing
		{
			command = ROUNDRECT;
			parameters = arguments;

			if (execute)
			{
				var r:Rectangle = Geoms.rectangle(width, height, x, y),
					s:int = !isNaN(width) ? !isNaN(height) ? !isNaN(x) ? !isNaN(y) ? radius : y : x : height : 0;

					graphics.drawRoundRect(r.x, r.y, r.width, r.height, s, s);
			}

			return link(execute);
		}

		//********** ELLIPSE COMMAND **********
		static private const ELLIPSE:String = "ellipse";

		public function ellipse(width:*, height:* = NaN, x:* = NaN, y:* = NaN):Drawing
		{
			command		= ELLIPSE;
			parameters	= arguments;

			if (execute)
			{
				var r:Rectangle = Geoms.rectangle(width, height, x, y);
					graphics.drawEllipse(r.x, r.y, r.width, r.height);
			}

			return link(execute);
		}

		public function circle(diameter:Number, centered:* = true, x:* = NaN, y:Number = NaN):Drawing
		{
			if (!(centered is Boolean))
			{
				x = centered;
				centered = true;
			}

			var o:Number = centered ? diameter * .5 : 0,
				p:Point = Geoms.position(x, y);

			return ellipse(diameter, diameter, p.x - o, p.y - o);
		}

		//********** PLUGIN COMMAND **********
		static private const PLUGIN:String = "plugin";

		public function plugin(method:Function, parameters:Array):Drawing
		{
			command		= PLUGIN;
			parameters	= arguments;

			if (execute) { method.apply(null, new Array(graphics).concat(parameters)); }

			return link(execute);
		}

		public function placeholder(width:*, height:* = NaN, debug:Boolean = false):Drawing
		{
			return fill(0x00ACF8, debug ? .5 : 0).rect(width, height);
		}

		public function zone(dp:DisplayObject):Drawing
		{
			return 	 stroke().fill(0xffffff).rect(dp).append()
					.stroke().move(0, 0).line(dp.width, dp.height)
							 .move(dp.width, 0).line(0, dp.height);
		}

		//********** CLEAR COMMAND **********
		static private const CLEAR:String = "clear";

		public function clear():Drawing
		{
			command = CLEAR;

			if (execute) { graphics.clear(); }

			return link(execute);
		}

		//********** APPEND COMMAND **********
		static private const APPEND:String = "append";

		public function append():Drawing
		{
			command = APPEND;

			if (execute)
			{
				graphics.lineStyle(0, 0, 0);
				graphics.endFill();
			}

			return link(execute);
		}

		//********** APPLY COMMAND **********
		static private const APPLY:String = "apply";

		public function apply(clear:Boolean = true):void
		{
			if (fired) { return; }
				fired = true;

			if (command == APPLY)
			{
				var start:Drawing = this;
				while (start.prev != null) { start = start.prev; }

				if (clear) { graphics.clear(); }
					start.apply();
			}
			else
			{
				execute = true;
				this[command].apply(this, arguments);
				next.apply();
				dispose();
			}
		}
	}
}







