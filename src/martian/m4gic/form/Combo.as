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
	import com.greensock.TweenMax;

	import flash.display.Shape;
	import flash.display.Sprite;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;

	import martian.m4gic.data.Ini;

	import martian.m4gic.graphics.draw;

	import martian.m4gic.tools.Maths;

	//TODO: Refactor Combo for working with List object and Fader for the scrollbar
	public class Combo extends EventDispatcher
	{
		private var textfield:Object,
					dropdown_btn:Sprite,
					dropdown_bg:Sprite,
					dropdown_container:Sprite,
					scroll_limit:int,
					itemrenderer:Class;
		
		private var value:Object = null;
			public function get data():Object { return value; }
		
		private var h:int = 0,
					dropdown_mask:Shape;
		
		public function Combo(config:Object)
		{
			var ini:Ini = new Ini(config);
				textfield			= ini.cast("textfield", Object, new Error("You must provide a valid textfield"));
				dropdown_btn		= ini.cast("dropdown_btn", Sprite, new Error("You must provide a valid dropdown_btn"));
				dropdown_bg			= ini.cast("dropdown_bg", Sprite, new Error("You must provide a valid dropdown_bg"));
				dropdown_container	= ini.cast("dropdown_container", Sprite, new Error("You must provide a valid dropdown_container"));
				itemrenderer 		= ini.cast("itemrenderer", Renderer, new Error("You must provide a valid Renderer Class or object"));
				scroll_limit		= ini.integer("scroll_limit", 5);
		}
		
		public function feed(entries:Array):void
		{
			var item:*, items:Array = new Array();
			
			for each (var entry:Object in entries)
			{
				item = new itemrenderer();
					item.label = entry.label;
					item.value = entry.value;
				
				h = item.height;
				
				items.push(item);
			}
			
			layout(items);
			
			open();
			activate();
			select(-1);
		}
		
		private function layout(items:Array):void
		{
			while(dropdown_container.numChildren) { dropdown_container.removeChildAt(0); }
			
			var i:int = 0, l:int = items.length;
			
			for (i = 0; i < l; i++)
			{
				items[i].y = i * h;
				dropdown_container.addChild(items[i]);
			}

			dropdown_bg.width = items[0].width;
			
			dropdown_bg.height = h;
				dropdown_bg.height *= l <= scroll_limit ? l : scroll_limit;
				
			if (l > scroll_limit)
			{
				if (!dropdown_mask)
				{
					dropdown_mask = new Shape();
						dropdown_container.parent.addChild(dropdown_mask);
						dropdown_container.mask = dropdown_mask;
				}
				
				draw(dropdown_mask).clear().placeholder(dropdown_bg.width, dropdown_bg.height);
			}
			else if (dropdown_mask)
			{
				dropdown_container.mask = null;
				dropdown_container.parent.removeChild(dropdown_mask);

				dropdown_mask = null;
			}
		}
		
		public function activate():void
		{
			if (dropdown_bg.visible) { close(); }
			
			textfield.addEventListener(MouseEvent.CLICK, toggle);
			
			dropdown_btn.buttonMode = true;
			dropdown_btn.addEventListener(MouseEvent.CLICK, toggle);
			
			dropdown_container.buttonMode = true;
			dropdown_container.addEventListener(MouseEvent.CLICK, choose);
		}
		
		public function desactivate():void
		{
			if (dropdown_bg.visible) { close(); }

			textfield.removeEventListener(MouseEvent.CLICK, toggle);
			
			dropdown_btn.buttonMode = false;
			dropdown_btn.removeEventListener(MouseEvent.CLICK, toggle);
			
			dropdown_container.buttonMode = false;
			dropdown_container.removeEventListener(MouseEvent.CLICK, choose);
		}
		
		public function open(e:MouseEvent = null):void
		{
			var d:Number = e != null ? .2 : 0;
			
			TweenMax.allTo([dropdown_bg, dropdown_container], d, { autoAlpha:1 }, d >> 1);

			if (dropdown_mask) { dropdown_container.addEventListener(Event.ENTER_FRAME, scroll); }
			if (e) { dropdown_bg.stage.addEventListener(MouseEvent.MOUSE_UP, close); }
		}
		
		public function close(e:MouseEvent = null):void
		{
			var d:Number = e != null ? .2 : 0;
			
			TweenMax.allTo([dropdown_container, dropdown_bg], d, { autoAlpha:0 }, d >> 1);
			
			if (dropdown_mask) { dropdown_container.removeEventListener(Event.ENTER_FRAME, scroll); }
			if (e) { dropdown_bg.stage.removeEventListener(MouseEvent.MOUSE_UP, close); }
		}
		
		public function toggle(e:MouseEvent = null):void
		{
			if (e) { e.stopImmediatePropagation(); }
			dropdown_bg.visible ? close(e) : open(e);
		}

		private function choose(e:MouseEvent = null):void
		{
			if (e) { e.stopImmediatePropagation(); }
			
			select(int(dropdown_container.mouseY / h));
			close(e);
		}
		
		private function scroll(e:Event):void
		{
			if (!Maths.between(dropdown_mask.mouseX, 0, dropdown_mask.width)) { return; }
			
			dropdown_container.y += (((dropdown_mask.height - dropdown_container.height) * (dropdown_mask.mouseY / dropdown_mask.height)) - dropdown_container.y) * .25;
				dropdown_container.y = Maths.clamp(dropdown_container.y, dropdown_mask.height - dropdown_container.height, 0);
		}
		
		public function select(index:int):void
		{
			if (index > dropdown_container.numChildren - 1) { return; }
			
			textfield.text = index >= 0 ? (dropdown_container.getChildAt(index) as Object).label : "";
			value = index >= 0 ? (dropdown_container.getChildAt(index) as Object).value : null; 
			
			dispatchEvent(new Event(Event.CHANGE));
		}
	}
}