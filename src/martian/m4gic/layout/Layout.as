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

package martian.m4gic.layout
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;

	import flash.events.Event;

	import martian.daem0n.core.Daemon;

	public class Layout extends Daemon
	{
		static public function apply(container:DisplayObjectContainer, layout:String, margin:Spacing = null):void
		{
			if (!H || !V)
			{
				H = new Adapter("horizontal", "x", "width", "y", "height", "left", "right", "top", "bottom");
				V = new Adapter("vertical", "y", "height", "x", "width", "top", "bottom", "left", "right");
			}
			
			var t:Adapter = layout == HORIZONTAL ? H : V;
			var m:Spacing = margin ? margin : new Spacing();
			
			var i:int = 0, l:int = container.numChildren, o:Number = m[t.b], s:DisplayObject;
			
			for (i = 0; i < l; i++)
			{
				s = container.getChildAt(i);
				s[t.p] = o;
				
				o += s[t.s] + m[t.a];
			}
		}
		
		
		
		static private var s:Stage;
		static private function invalidate(r:Stage):void
		{
			if (s || !r) { return; }
				s = r;
				
			H = new Adapter("horizontal", "x", "width", "y", "height", "left", "right", "top", "bottom");
			V = new Adapter("vertical", "y", "height", "x", "width", "top", "bottom", "left", "right");
				
			s.addEventListener(Event.ENTER_FRAME, function(e:Event):void { s.invalidate(); }, false, int.MAX_VALUE);
		}
		
		static private var H:Adapter;
		static private var V:Adapter;
		
		
		
		static public const HORIZONTAL:String = "horizontal";
		static public const VERTICAL:String = "vertical";
		
		static public const ADJUST:int = 0x2;
		static public const OVERFLOW:int = 0x3;
		
		private var w:Number = NaN;
			public function get width():Number { return w * reference.scaleX; }
			public function set width(n:Number):void { w = n / reference.scaleX; refresh(); }
		
		private var h:Number = NaN;
			public function get height():Number { return h * reference.scaleY; }
			public function set height(n:Number):void { h = n * reference.scaleY; refresh(); }
		
		private var t:Object;
			public function get type():String { return t.d; }
			public function set type(i:String):void { t = (i == HORIZONTAL ? H : V); refresh();	}
			
		public var filling:int = ADJUST;
		
		public var margin:Spacing = new Spacing();
		public var padding:Spacing = new Spacing();
		public var gap:Spacing = new Spacing();
			
		public function Layout(global:Boolean = false) { super(global); }
		
		public function hook(container:Sprite, type:String, filling:int, active:Boolean = true):void
		{
			if (!$hook(container)) { return; }
				invalidate(stage);
				
				this.type = type;
				this.filling = filling;
				
			if (active) { activate(); }
		}
		
		public function kill():void { if (!$kill()) { return; } }
		
		public function activate():void
		{
			if (!$activate()) { return; }
				reference.addEventListener(Event.RENDER, refresh);
				padding.addEventListener(Event.CHANGE, refresh);
				margin.addEventListener(Event.CHANGE, refresh);
				
				refresh();
		}
		
		public function deactivate():void
		{
			if (!$deactivate()) { return; }
				reference.removeEventListener(Event.RENDER, refresh);
		}
		
		public function update():void { refresh(); }
		
		private function refresh(e:Event = null):void 
		{
			var i:int = 0, l:int = reference.numChildren, o:Number = padding[t.b] + gap[t.b], p:Number = 0, q:Number = padding[t.rb] + gap[t.rb], r:Number = 0, s:DisplayObject;
			
			for (i = 0; i < l; i++)
			{
				s = reference.getChildAt(i);
				
				if (!isNaN(this[t.s]))
				{
					r = filling == ADJUST ? s[t.s] : 0;
						
					if (this[t.s] <= o + r) 
					{
						o = padding[t.b] + gap[t.b];
						q += p + gap[t.rb] + gap[t.ra];
					}
				}
				
				s[t.p] = o;
				s[t.rp] = q;
				
				if (!e || e.type != Event.REMOVED || (e.type == Event.REMOVED && reference.getChildAt(i) != e.target))
				{
					o += (s[t.s] + gap[t.b] + gap[t.a]);
					p = Math.max(p, s[t.rs]);
				}
			}
		}
	}
}

internal class Adapter
{
	public function Adapter(d:*, p:*, s:*, rp:*, rs:*, b:*, a:*, rb:*, ra:*)
	{
		var args:Array = ["d", "p", "s", "rp", "rs", "b", "a", "rb", "ra"];
		for (var i:int = 0; i < args.length; i++) { this[args[i]] = arguments[i]; }
	}
	
	public var d:*; //description
	
	public var p:*; //position
	public var s:*; //size
	
	public var rp:*; //reverse position
	public var rs:*; //reverse size
	
	public var b:*; //spacing before
	public var a:*; //spacing after
	
	public var rb:*; //reverse spacing before
	public var ra:*; //reverse spacing after
}