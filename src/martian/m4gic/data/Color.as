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
	import flash.utils.Dictionary;
	import martian.m4gic.tools.Maths;

	public class Color
	{
		static private var colors:Dictionary = new Dictionary();
			static public function get(name:String):Color { return colors[name] || null; }
		
		private var name:String;
		
		private var a:int = 0xFF;
			public function get alpha():Number { return (this.a / 0xFF); }
			public function set alpha(a:Number):void { rgba(NaN, NaN, NaN, a); }
		
		private var r:int = 0x00;
			public function get red():int { return this.r; }
			public function set red(r:int):void { rgba(r); }
			
		private var g:int = 0x00;
			public function get green():int { return this.g; }
			public function set green(r:int):void { rgba(NaN, g); }
		
		private var b:int = 0x00;
			public function get blue():int { return this.b; }
			public function set blue(b:int):void { rgba(NaN, NaN, b); }
		
		private var h:Number = 0;
			public function get hue():Number { return this.h; }
			public function set hue(h:Number):void { hsl(Maths.clamp(h, 0, 360)); }
		
		private var s:Number = 0;
			public function get saturation():Number { return this.s; }
			public function set saturation(s:Number):void { hsl(NaN, Maths.clamp(s), NaN); }
		
		private var l:Number = 0;
			public function get luminance():Number { return this.l; }
			public function set luminance(l:Number):void { hsl(NaN, NaN, Maths.clamp(l)); }
		
		public function set gray(c:int):void { rgba(c, c, c); }
		
		public function get rgb():int { return this.r << 16 | this.g << 8 | this.b; }
		public function set rgb(c:int):void { rgba(c >> 16, c >> 8 & 0xFF, c & 0xFF); }
		
		public function get argb():int { return this.a << 24 | this.r << 16 | this.g << 8 | this.b; }
		public function set argb(c:int):void { rgba(c >>> 16 & 0xFF, c >>> 8 & 0xFF, c & 0xFF, c >>> 24); }
		
		public function get hex():String
		{
			var prefix:String = "#";
			var fill:String = "";
			var color:String = rgb.toString(16);
			
			for (var i:int = 0; i < (8 - color.length); i++) { fill += "0"; }
			
			return prefix + fill + color;
		}
		
		public function set hex(s:String):void
		{
			if (s.charAt(0) == "#") { s = "0x" + s.substr(1); }
				rgb = parseInt(s, 16);
		}
		
		public function rgba(r:Number = NaN, g:Number = NaN, b:Number = NaN, a:Number = NaN):void
		{
			if (!isNaN(r)) { this.r = r; }
			else { r = this.r; }
			
			if (!isNaN(g)) { this.g = g; }
			else { g = this.g; }
			
			if (!isNaN(b)) { this.b = b; }
			else { b = this.b; }
			
			if (!isNaN(a)) { this.a = a; }
			else { a = this.a; }
			
			r /= 0xFF;
			g /= 0xFF;
			b /= 0xFF;
			
			var min:Number = Math.min(r, g, b),
				max:Number = Math.max(r, g, b),
				del:Number = max - min;
			
			this.l = max;
			
			if (max != 0) { this.s = del / max; }
			else { this.s = 0; }
			
			if (r == max) { this.h = (g - b) / del; }
			else if (g == max) { this.h = 2 + (b - r) / del; }
			else { this.h = 4 + (r - g) / del; }
			
			this.h *= 60;
			if (this.h < 0) { this.h += 360; }
		}
		
		public function hsl(h:Number = NaN, s:Number = NaN, l:Number = NaN):void
		{
			if (!isNaN(h)) { this.h = h; }
			else { h = this.h; }
			
			if (!isNaN(s)) { this.s = s; }
			else { s = this.s; }
			
			if (!isNaN(l)) { this.l = l; }
			else { l = this.l; }
			
			h /= 60;
			
			var i:int = int(h),
				f:Number = h - i,
				p:Number = l * (1 - s),
				q:Number = l * (1 - s * f),
				t:Number = l * (1 - s * (1 - f));
				
			switch(i)
			{
				case 0:
					this.r = l * 0xFF;
					this.g = t * 0xFF;
					this.b = p * 0xFF;
					break;
					
				case 1:
					this.r = q * 0xFF;
					this.g = l * 0xFF;
					this.b = p * 0xFF;
					break;
					
				case 2:
					this.r = p * 0xFF;
					this.g = l * 0xFF;
					this.b = t * 0xFF;
					break;
					
				case 3:
					this.r = p * 0xFF;
					this.g = q * 0xFF;
					this.b = l * 0xFF;
					break;
					
				case 4:
					this.r = t * 0xFF;
					this.g = p * 0xFF;
					this.b = l * 0xFF;
					break;
					
				default:
					this.r = l * 0xFF;
					this.g = p * 0xFF;
					this.b = q * 0xFF;
					break;
			}
		}
		
		public function Color(value:uint = 0xff000000, name:String = "")
		{
			argb = value;
			
			this.name = name;
			if (name != "") { colors[name] = this; }
		}
		
		public function valueOf():Object { return argb; }
		
		public function clone(name:String):Color { return new Color(argb, name != '' ? name : this.name + '_copy'); }
		
		public function toString():String { return "[" + (name.length != 0 ? name : "unknown color") + ": " + hex + "]"; }
	}
}