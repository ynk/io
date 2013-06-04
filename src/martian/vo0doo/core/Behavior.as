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

package martian.vo0doo.core
{
	import flash.display.*;
	import flash.events.*;
	
	/**
	 * This is an abstract class for all the daemons.
	 * It implements a very small safe way to register/release references
	 * of the daemon and activate/desactivate the daemon functions.
	 */
	public class Behavior extends EventDispatcher
	{
		protected var name:String = "";
		
		protected var target:*;

		private var hooked:Boolean = false;
		private var activated:Boolean = false;
			public function get available():Boolean { return (hooked && activated); }		
		
		public function Behavior() {}
		
		protected function $hook(target:DisplayObject):Boolean
		{
			if (!available)
			{
				this.target = target;
				hooked = true;
			}
			
			return hooked;
		}
		
		protected function $kill():Boolean
		{
			if (available)
			{
				if (activated) { $deactivate(); }
				
				this.target = null;
				hooked = false;
			}
			
			return hooked;
		}
		
		protected function $activate():Boolean
		{
			if (hooked && !activated) { activated = true; }
			return activated;
		}
		
		protected function $deactivate():Boolean
		{
			if (hooked && activated) { activated = false; }
			return !activated;
		}
		
		public function perform():void {}
	}
}