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
	import flash.display.Sprite;
	import flash.events.*;

	public class QCM extends EventDispatcher implements Field
	{
		public function get asset():Object { return objects; }
		
		private var n:String;
			public function get name():String { return n; }
			public function set name(s:String):void { n = s; }
		
		public function get index():int { return objects[0].tabIndex; }
		public function set index(i:int):void
		{
			for (var j:int = 0; j < objects.length; j++) { objects[j].tabIndex = i + j; }
			tell(Event.TAB_INDEX_CHANGE);
		}

		public function get next():int { return objects[0].tabIndex + objects.length; }
		
		public function get value():Object
		{
			var code:int = 0;
			for (var j:int = 0; j < objects.length; j++) { code |= objects[j].alpha << j; }
			
			return code;
		}

		public function set value(value:Object):void
		{
			length = 0;
			
			for (var j:int = 0; j < objects.length; j++)
			{
				objects[j].alpha = 0;
				if ((int(value) >> j) & 0x1) { select(j); }
			}
			
			tell(Event.CHANGE);
		}
		
		
		
		
		
		private var objects:Array,
					last:int = -1,
					length:int;

		public var	max:int,
					mask:int;
		
		public function QCM(objects:Array, max:int = 1, mask:int = 0, index:int = 0)
		{
			this.objects = objects;
			this.last = 0;
			this.length = 0;
			this.max = max;
			this.mask = parseInt(mask.toString(16), 2);
			this.index = index;
			
			this.n = objects[0].name;

			init();
		}
		
		private function init():void
		{
			for (var j:int = 0; j < objects.length; j++) 
			{
				objects[j].alpha = 0;
				objects[j].buttonMode = true;
				objects[j].addEventListener(MouseEvent.CLICK, onclick, false, 0, true);
				objects[j].addEventListener(FocusEvent.FOCUS_IN, onfocusin, false, 0, true);
				objects[j].addEventListener(FocusEvent.FOCUS_OUT, onfocusout, false, 0, true);
			}
			
			tell(Event.CHANGE);
		}
		
		private function onclick(e:MouseEvent):void
		{
			for (var j:int = 0; j < objects.length; j++)
			{ if (e.currentTarget == objects[j]) { select(j); return; } }
		}
		
		private function onfocusin(e:FocusEvent):void { tell(Event.CHANGE); }
		private function onfocusout(e:FocusEvent):void { tell(Event.CHANGE); }
		
		private function select(id:int):void
		{
			objects[id].alpha = (objects[id].alpha == 0) ? 1 : 0;
			length += (objects[id].alpha == 1) ? 1 : -1;
			
			if (length > max)
			{
				objects[last].alpha = 0;
				length--;
			}
			
			last = id;
			tell(Event.CHANGE);
		}
		
		public function reset():void { value = 0; }
		
		public function validate():Boolean
		{
			if (mask == 0) { return true; }
			else { return (int(value) - mask) == 0; }
		}
		
		private function tell(type:String):void { dispatchEvent(new Event(type)); }
	}
}
