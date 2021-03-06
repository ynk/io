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

package martian.sta7es.core
{
	import flash.display.Sprite;
	
	import flash.events.Event;
	
	import martian.ev3nts.helpers.on;
		
	public class Module extends Sprite
	{
		static public const READY:String = "mready";
		static public const SHOWN:String = "mshown";
		static public const HIDDEN:String = "mhidden";
		static public const KILLED:String = "mkilled";
		
		protected var tmp:Object = new Object();
		
		public function Module(resizable:Boolean = true):void
		{
			if (resizable)
			{
				on(this, Event.ADDED_TO_STAGE, onadded);
				on(this, Event.REMOVED_FROM_STAGE, onremoved);
			}
		}
		
		public function init(args:Object = null):void { tell(Module.READY, false); }
		public function show(args:Object = null):void { tell(Module.SHOWN, false); }
		public function hide(args:Object = null):void { tell(Module.HIDDEN, false); }
		public function kill(args:Object = null):void { tell(Module.KILLED, false); }
		
		public function resize():void {}
		
		private function onadded():void { stage.addEventListener(Event.RESIZE, onresize); }
		private function onremoved():void { stage.removeEventListener(Event.RESIZE, onresize); }
		private function onresize(e:Event):void { resize(); }
		
		public function tell(event:String, bubbles:Boolean = true):void { dispatchEvent(new Event(event, bubbles, true)); }
	}
}