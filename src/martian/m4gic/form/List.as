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

package martian.m4gic.form
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	import flash.events.*;
	
	import martian.m4gic.data.Ini;
	
	import martian.m4gic.graphics.draw;
	
	import martian.m4gic.tools.Maths;

	public class List extends EventDispatcher implements Field
	{
		static private const H:Object = { o:"y", r:"height", p:"x", s:"width",  d:37, i:39 };
		static private const V:Object = { o:"x", r:"width",  p:"y", s:"height", d:38, i:40 };
		
		static public const HORIZONTAL:int = 0x0;
		static public const VERTICAL:int = 0x1;
				
		public function get asset():Object { return container; }
		
		private var n:String;
			public function get name():String { return n; }
			public function set name(s:String):void { n = s; }
		
		private var i:int;
			public function get index():int { return i; }
			public function set index(n:int):void { i = n; }

		public function get next():int { return 0; }

		public function get value():Object { return selected.value; }
		public function set value(o:Object):void
		{
			if (container.numChildren == 0) { return; }
			for (var i:int = 0, item:Renderer; item = container.getChildAt(i) as Renderer; i++)
			{
				if (o == item.value)
				{
					update(item);
					return;
				}
			}
		}
		
		private var type:Object,
					itemrenderer:Class,
					container:Sprite,
					fader:Fader,
					limit:int = -1;
			
		private var c:int = NaN,
					s:int = NaN,
					list_mask:Shape,
					selected:Renderer;
		
		public function List(config:Object)
		{
			var ini:Ini = new Ini(config);
				type = ini.number("type", VERTICAL) == HORIZONTAL ? H : V;
				container = ini.cast("container", Sprite, new Error("You must provide a valid container"));
				itemrenderer = ini.cast("itemrenderer", Renderer, new Error("You must provide a valid Renderer Class or object"));
				fader = ini.cast("fader", Fader, null);
				limit = ini.integer("limit", -1);
				i = ini.integer("index", 0);
		}
		
		public function feed(entries:Array):void
		{
			var item:*, items:Array = new Array();
			
			for (var j:int = 0; j < entries.length; j++)
			{
				item = new itemrenderer();
					item.label = entries[j].label;
					item.value = entries[j].value;
					item.tabIndex = i + j;
					
					item.addEventListener(FocusEvent.FOCUS_IN, kFocus);
					
				s = item[type.s];
				
				items.push(item);
			}
			
			layout(items);
		}
		
		private function layout(items:Array):void
		{
			while(container.numChildren) { container.removeChildAt(0); }
			
			var a:int, b:int, i:int = 0, l:int = items.length;
			
			for (i = 0; i < l; i++)
			{
				items[i][type.p] = i * s;
				container.addChild(items[i]);
			}

			a = items[0][type.r];
			b = s * (limit < l ? limit : l);
			 
			if (Maths.between(limit, 0, l))
			{
				if (!list_mask)
				{
					list_mask = new Shape();
						container.parent.addChild(list_mask);
						container.mask = list_mask;
				}
				
				if (type == V) { draw(list_mask).clear().placeholder(a, b); }
				else if (type == H) { draw(list_mask).clear().placeholder(b, a); }
			}
			else if (list_mask)
			{
				container.mask = null;
				container.parent.removeChild(list_mask);
				
				list_mask = null;
			}
			
			if (fader)
			{
				fader.removeEventListener(Event.CHANGE, sUpdate);
				
				fader.step = 1 / container.numChildren;
				fader.addEventListener(Event.CHANGE, sUpdate);
			}
		}
		
		private function mClick(e:MouseEvent):void 
		{
			/*var hop:Number = container["mouse" + type.p.toUpperCase()];
			var index:int = int(container["mouse" + type.p.toUpperCase()] / s);
			
			if (fader) { fader.value = index / container.numChildren; }
				update(container.getChildAt(index) as Renderer, true);
				
			tell(Event.CHANGE);*/
		}
		
		private function sUpdate(e:Event):void 
		{
			var index:int = int(fader.value.valueOf() * (container.numChildren - 1));
				update(container.getChildAt(index) as Renderer);
				
			tell(Event.CHANGE);
		}
		
		private function kFocus(e:FocusEvent):void 
		{
			var index:int = int(container["mouse" + type.p.toUpperCase()] / s);
				update(container.getChildAt(index) as Renderer, true);
				
			tell(Event.CHANGE);
		}
		
		private function update(item:Renderer, force:Boolean = false):void
		{
			if (selected && selected == item) { return; }
			else if (selected) { selected.unselect(); }
			
			var d:int = c;
			
			selected = item;
			selected.select();
			
			c = (selected as DisplayObject)[type.p] / s;
				
			var min:int = c > d ? d : d - limit,
				max:int = c > d ? d + limit : d;
			
			trace(c, min, max, Maths.between(c, min, max));
				
			if (!Maths.between(c, min, max)) { move(c); }
			
			if (fader && force) { fader.value = c / container.numChildren; }
		}
		
		private function move(index:int):void
		{
			if (list_mask)
			{
				if (index >= limit || container[type.p] < 0)
				{
					container[type.p] = Maths.clamp( - index, - container.numChildren + limit, 0) * s;
				}
			}
		}
		
		public function validate():Boolean { return false; }
		
		private function tell(type:String):void { dispatchEvent(new Event(type)); }
	}
}
