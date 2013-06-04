/*
Copyright (c) 2010 julien barbay <barbay.julien@gmail.com>

 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the 'Software'), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:

 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
*/

package martian.daem0n 
{
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import martian.daem0n.core.Daemon;
	
	import martian.m4gic.data.Weak;
	
	import martian.sta7es.core.Controller;
	
	import martian.t1me.data.Load;
	import martian.t1me.interfaces.Stackable;
	import martian.t1me.misc.Time;
	import martian.t1me.trigger.Call;
	
	public class i18n extends Daemon
	{
		public var	locales:Object,
					controller:Controller;
		
		public var prefix:String = ':';			
					
		private var lang:String = '';
			public function get locale():String { return lang; }
			
		private var raw:XML;
			public function get data():XML { return raw; }
			
		private var loading:Boolean = false;
			override public function get available():Boolean { return loading; }
			
		private var bindings:Dictionary;	
			
		public function i18n() { }
		
		public function hook(sources:Object, controller:Controller = null):void
		{
			name = 'i18n';
			
			this.locales = sources;
			this.controller = controller;
			
			bindings = new Dictionary();
		}
		
		public function translate(locale:String, directly:Boolean = true):Stackable
		{
			if (loading || this.lang == locale.toLowerCase()) { return null; }
				this.lang = locale.toLowerCase();
				
			var feed:* = locales[locale] || locales['*'] || locales[locales['default']] || null;
				if (feed is String && feed.indexOf('*') > -1) { feed = feed.replace('*', locale); }
				
			var stackable:Stackable;	
				
			if ((feed is String && String(feed).indexOf('.xml') != -1) || feed is URLRequest)
			{
				stackable = new Load(feed, Load.TEXT);
					stackable.addEventListener(Time.START, function(e:Event):void
					{
						stackable.removeEventListener(Time.START, arguments.callee);
						loading = true;
					});
			}
			else if (feed is String) { stackable = new Call(oncomplete, 10, new XML(feed)); }
			else if (feed is XML) { stackable = new Call(oncomplete, 10, feed); }
			else { throw new ArgumentError('Unknown or invalid locale' + locale); return null; }
			
			if (stackable is Load)
			{
				stackable.addEventListener(Time.STOP, function(e:Event):void
				{
					stackable.removeEventListener(Time.STOP, arguments.callee);
					 oncomplete(stackable);
				});
				
				if (directly) { stackable.start(); }
				
				return stackable;
			}
			else if (directly) { oncomplete(feed is XML ? feed : new XML(feed)); }
			
			return null;
		}
		
		private function oncomplete(arg:*):void 
		{
			raw = arg is Load ? new XML(arg.data) : arg;
			if (arg is Load) { arg.dispose(); }
			
			refresh();
			
			loading = false;
		}
		
		public function get(key:String):String
		{
			key = key.replace(prefix, '');
			
			var levels:Array = key.split('.'),
				current:XMLList = XMLList(raw);
				
			for (var i:int = 0; i < levels.length; i++)
			{
				if (isNaN(levels[i])) { current = current.child(levels[i]); }
				else { current = XMLList(current[levels[i]]); }
			}
			
			return current.valueOf();
		}
		
		public function find(translation:String):String
		{
			translation = translation.replace(prefix, '');
			
			//TODO reverse find
			
			return '';
		}
		
		public function bind(target:*, key:String, directly:Boolean = true, weak:Boolean = true):String
		{
			var dump:*;
			
			if (target['text'] != undefined || target is Function) { bindings[(dump = (weak ? new Weak(target) : target))] = key; }
			else { throw new Error('invalid target type. TextField or Function only'); return; }
			
			if (directly) { render(dump); }
			
			return get(key);
		}
		
		public function unbind(arg:* = null):void
		{
			for (var target:* in bindings)
			{
				//TODO : verifier que ca fonctionne avec les weakrefs
				if (!arg || arg == target)
				{
					delete bindings[target];
					if (arg) { return; }
				}
			}
		}
		
		public function refresh():void { for (var target:* in bindings) { render(target); } }
	
		private function render(target:*):void 
		{
			if (target is Weak) { target.text = get(bindings[target]); }
			else if (target is Function) { target.call(null, get(bindings[target])); }
		}
	}
}