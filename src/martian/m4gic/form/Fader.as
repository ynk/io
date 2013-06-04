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
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import martian.m4gic.data.Ini;
	
	import martian.m4gic.tools.Maths;
	
	public class Fader extends EventDispatcher implements Field
	{
		static private const H:Object = { p:"x", s:"width", m:"mouseX", d:37, i:39 };
		static private const V:Object = { p:"y", s:"height", m:"mouseY", d:38, i:40 };
		
		static public const HORIZONTAL:int = 0x0;
		static public const VERTICAL:int = 0x1;
		
		public function get asset():Object { return null; }

		private var n:String;
			public function get name():String { return n; }
			public function set name(s:String):void { n = s; }

			
		public function get index():int
		{
			if (dnbtn) { return dnbtn.tabIndex; }
			else if (thumb) { return thumb.tabIndex; }
			else if (upbtn) { return upbtn.tabIndex; }
			
			return -1;
		}
		public function set index(i:int):void
		{
			var j:int = i;
			
			if (upbtn) { upbtn.tabIndex = j++; }
			if (thumb) { thumb.tabIndex = j++; }
			if (dnbtn) { dnbtn.tabIndex = j++; }
			
			tell(Event.TAB_INDEX_CHANGE);
		}
		
		public function get next():int
		{
			var j:int = index;
			
			if (upbtn) { j++; }
			if (thumb) { j++; }
			if (dnbtn) { j++; }
			
			return j;
		}

		private var v:Number = 0;
			public function get value():Object { return v; }
			public function set value(o:Object):void
			{
				v = Maths.clamp(Number(o), range[0], range[1]);
				
				if (thumb && track) { thumb[type.p] = track[type.p] + v * (track[type.s] - thumb[type.s]); }
			}

		private var type:Object,
					track:Sprite,
					thumb:Sprite,
					range:Array,
					upbtn:Sprite,
					dnbtn:Sprite,
					reszb:Boolean,
					offset:int = 0,
					activated:Boolean = false;
		
		public var	coeff:Number = 1,
					step:Number;
		
		public function Fader(type:int, assets:Object, valid:String = "0,1", step:Number = 0.05)
		{
			this.type	= type == HORIZONTAL ? H : V;
			this.range  = valid.split(",");
				this.range[0] = parseFloat(this.range[0]);
				this.range[1] = parseFloat(this.range[1]);
				
			this.step = step;
			
			var ini:Ini = new Ini(assets);
				thumb = ini.cast("thumb", Sprite, null);
				track = ini.cast("track", Sprite, null);
				upbtn = ini.cast("up", Sprite, null);
				dnbtn = ini.cast("down", Sprite, null);
				reszb = ini.boolean("resizable", true);
			
			activate();
		}

		public function validate():Boolean { return Maths.between(Number(value), range[0], range[1]); }

		public function activate():void
		{
			if (activated) { return; }
				activated = true;
			
			if (track)
			{
				track.addEventListener(MouseEvent.CLICK, mClick, false, 0, true);
				if (reszb) { track.stage.addEventListener(Event.RESIZE, resize); }
			}
			
			if (thumb)
			{
				thumb.buttonMode = true;
				thumb.addEventListener(MouseEvent.MOUSE_DOWN, mDown, false, 0, true);
			}
			
			if (upbtn)
			{
				upbtn.buttonMode = true;
				upbtn.addEventListener(MouseEvent.CLICK, bUp, false, 0, true);
			}
			
			if (dnbtn)
			{
				dnbtn.buttonMode = true;
				dnbtn.addEventListener(MouseEvent.CLICK, bDn, false, 0, true);
			}
		}
		
		public function desactivate():void
		{
			if (!activated) { return; }
				activated = false;
				
			if (track)
			{
				track.removeEventListener(MouseEvent.CLICK, mClick);
				if (reszb) { track.stage.removeEventListener(Event.RESIZE, resize); }
			}
			
			if (thumb)
			{
				thumb.buttonMode = false;
				thumb.removeEventListener(MouseEvent.MOUSE_DOWN, mDown);
			}
			
			if (upbtn)
			{
				upbtn.buttonMode = false;
				upbtn.removeEventListener(MouseEvent.CLICK, bUp);
			}
			
			if (dnbtn)
			{
				dnbtn.buttonMode = false;
				dnbtn.removeEventListener(MouseEvent.CLICK, bDn);
			}
		}
		
		private function mDown(e:MouseEvent):void
		{
			if (e) { e.stopImmediatePropagation(); }
			
			offset = thumb[type.m] + track[type.p];
			
			thumb.stage.addEventListener(MouseEvent.MOUSE_MOVE, mMove, false, 0, true);
			thumb.stage.addEventListener(MouseEvent.MOUSE_UP, mUp, false, 0, true);			
		}
		
		private function mMove(e:MouseEvent):void
		{
			if (e) { e.stopImmediatePropagation(); }
			
			value = Maths.clamp((thumb.parent[type.m] - offset) / (track[type.s] - thumb[type.s])) * range[1];
			
			tell(Event.CHANGE);
		}
		
		private function mUp(e:MouseEvent):void
		{
			if (e) { e.stopImmediatePropagation(); }
			
			offset = 0;
			
			thumb.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mMove);
			thumb.stage.removeEventListener(MouseEvent.MOUSE_UP, mUp);	
		}
		
		private function mClick(e:MouseEvent):void
		{
			if (e) { e.stopImmediatePropagation(); }
			
			if (thumb)
			{
				offset = (thumb[type.s] * .5) + track[type.p];
				mMove(null);
			}
			else
			{
				value = Maths.clamp(track[type.m] / track[type.s]) * range[1];
				tell(Event.CHANGE);
			}
		}
		
		private function bUp(e:MouseEvent):void { value = Number(value) - step; tell(Event.CHANGE); }
		private function bDn(e:MouseEvent):void { value = Number(value) + step; tell(Event.CHANGE); }
		
		private function resize(e:Event):void
		{
			thumb[type.p] = track[type.s] * v;
			tell(Event.CHANGE);
		}
		
		public function tell(type:String):void { dispatchEvent(new Event(type)); }
	}
}
