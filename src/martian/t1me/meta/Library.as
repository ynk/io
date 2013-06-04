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

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/

package martian.t1me.meta
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import flash.net.URLRequest;
	
	import flash.utils.Dictionary;
	
	import martian.ev3nts.helpers.on;

	import martian.t1me.data.Load;
	import martian.t1me.interfaces.*;

	import martian.t1me.misc.Time;

	public class Library extends EventDispatcher implements Stackable, Progressive, Pausable
	{
		public function get progress():Number { return queue ? (queue as Progressive).progress : -1; }
		
		public function get data():Vector.<Stackable> { return (queue as Queue).stack || null; }
		public function get(key:String):* { return Load(keys[key]).data || null; }
		public function get names():Array
		{
			var names:Array = new Array();
			for (var key:String in keys) { names.push(key); }
			
			return names;
		}
		
		private var feeder:Load;
		private var feed:XML;
		private var queue:Stackable;	
		private var keys:Dictionary;
		
		public function Library(feed:*, cache:Boolean = false)
		{
			if ((feed is String && String(feed).indexOf('.xml') > -1) || feed is URLRequest)
			{
				feeder = new Load(feed, Load.TEXT, cache);
					on(feeder, Event.COMPLETE, ondata);
			}
			else if (feed is String) { this.feed = new XML(feed); }
			else if (feed is XML) { this.feed = feed; }
			else { throw new ArgumentError('Wrong argument : feed'); }
		}
		
		public function load():void { start(); }
		
		public function start():void
		{
			if (feeder)	{ feeder.load(); }
			else { parse(feed); }
		}
		
		private function ondata(e:Event):void
		{
			feed = XML(e.target.data);
				parse(feed);
		}
		
		public function pause():void { if (queue) { (queue as Pausable).pause(); } }
		public function resume():void { if (queue) { (queue as Pausable).resume(); } }
		public function get status():int { return (queue) ? (queue as Pausable).status : Time.ERROR; }
		
		private function parse(xml:XML):void
		{
			keys = new Dictionary();
			
			if (xml.name() == 'queue') { queue = new Queue(parseInt(xml.@limit) || 2); }
			else if (xml.name() == 'group') { queue = new Group(); }
			else { queue = new Sequence(); }
			
			read(xml, (queue as Queue).stack);
			
			on(queue, Time.STOP, stop);
			queue.start();
		}
		
		private function read(xml:XML, stack:Vector.<Stackable>):void
		{
			var children:XMLList = xml.children(),
				queue:Queue, load:Load,
				url:String, type:String, cache:Boolean;
				
			for each (var child:XML in children)
			{
				queue = null;
				load = null;
				
				if (child.name() == 'queue') { queue = new Queue(parseInt(child.@limit) || 2); }
				else if (child.name() == 'group') { queue = new Group(); }
				else if (child.name() == 'sequence') { queue = new Sequence(); }
				
				if (queue)
				{
					read(child, queue.stack);
					stack.push(queue);
				}
				else
				{
					url = String(child.valueOf());
					type = String(child.name()).toLowerCase();
					cache = String(child.@cache).toLowerCase() == 'true';

					stack.push(new Load(url, type, cache));
					
					var key:String = ''
						if (child.@key != undefined) { key = String(child.@key); }
						else { key = url.substring(url.lastIndexOf('/') + 1, url.indexOf('?') != -1 ? url.indexOf('?') : int.MAX_VALUE); }
						
					keys[key] = stack[stack.length - 1];	
						
				}
			}
		}	
		
		private function stop():void
		{
			tell(Event.COMPLETE);
			tell(Time.STOP);
		}
		
		public function dispose():void { keys = null; }
		
		protected function tell(e:String):void { dispatchEvent(new Event(e)); }
	}
}