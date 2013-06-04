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

package martian.t1me.misc
{
	import flash.display.Sprite;
	
	import flash.events.Event;
	
	import martian.t1me.interfaces.Progressive;
	
	public class Stepper extends Sprite
	{
		public function Stepper() {}
		
		private var item:Progressive;
		
		public function attach(progressive:Progressive):void
		{
			item = progressive;
				item.addEventListener(Time.STEP, step);
				item.addEventListener(Time.STOP, clean);
		}
		
		public function detach():void
		{
				item.removeEventListener(Time.STOP, clean);
				item.removeEventListener(Time.STEP, step);
			item = null;
		}
		
		private function step(e:Event):void { progress(item.progress); }
		private function clean(e:Event):void { stop(); detach(); }
		
		protected function progress(percent:Number):void {}
		protected function stop():void {}
	}
}