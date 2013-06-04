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

package martian.daem0n.core
{
	import flash.display.*;
	import flash.events.*;
	
	import flash.utils.getDefinitionByName;
	
	/**
	 * This is an abstract class for all the daemons.
	 * It implements a very small safe way to register/release references
	 * of the daemon and activate/desactivate the daemon functions.
	 */
	public class Daemon extends EventDispatcher
	{
		static private var daemons:Array = new Array();
			static public function get(arg:*):*
			{
				var daemon:*;
				
				if (arg is String)
				{
					if (arg.indexOf(".") == -1) { for each(daemon in daemons) { if (daemon.name == arg) { return daemon; } } }
					else
					{
						var cls:Class = null;
						
						try { cls = getDefinitionByName(arg) as Class; }
						catch (e:Error) { arg = null; }
						
						arg = cls;
					}
				}
				
				if (arg is Class) { for each(daemon in daemons) { if (daemon is arg) { return daemon; } } }
				else if (arg is int && arg >= 0 && arg < daemons.length) { return daemons[arg]; }
				
				return { available:false };
			}
		
		protected var name:String = "abstract daemon";
		
		protected var reference:Sprite;
		protected var stage:Stage;

		private var hooked:Boolean = false;
		private var activated:Boolean = false;
			public function get available():Boolean { return (hooked && activated); }		
		
		public function Daemon(global:Boolean = true) { if (global) { daemons.push(this); } }
		
		protected function $hook(container:DisplayObject, full:Boolean = true):Boolean
		{
			if (!available)
			{
				if (!(container is Stage))
				{
					reference = Sprite(container);
					stage = full ? reference.stage : null;
				}
				else 
				{
					reference = null;
					stage = Stage(container);
				}
				
				hooked = true;
			}
			
			return hooked;
		}
		
		protected function $kill():Boolean
		{
			if (available)
			{
				if (activated) { $deactivate(); }
				
				reference = null;
				stage = null;
				
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
		
		protected function tell(type:String):void { dispatchEvent(new Event(type)); }
	}
}