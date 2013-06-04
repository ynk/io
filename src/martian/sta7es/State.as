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

package martian.sta7es
{
	import flash.display.*;
	import martian.m4gic.gc;
	import martian.m4gic.log;
	
	import flash.events.*;
	
	import martian.daem0n.core.Daemon;
	
	import martian.ev3nts.helpers.on;
	
	import martian.m4gic.tools.Maths;
	
	import martian.sta7es.core.Controller;
	import martian.sta7es.core.Module;
	import martian.sta7es.core.Statement;
	import martian.sta7es.core.Transition;

	public class State extends Daemon
	{
		static public const START:String = 'stateStart';
		static public const SWAP:String = 'stateSwap';
		static public const STOP:String = 'stateStop';
		
		static public const IMMEDIATLY:int = 0;
		static public const AFTER:int = 1;
		
		public var SEPARATOR:String = '/';
		public var DEBUG:Boolean = false;
		
		private var c:*, D:*, h:Array, i:Boolean = true, m:Boolean = false, q:Statement, t:*;
		public var controller:Controller;
		
		public function get current():* { return c; }
		
		public function State() { name = 'State'; }
		
		public function hook(container:Sprite, controller:Controller = null, history:Boolean= true, active:Boolean = true):void
		{
			if (!$hook(container)) { return; }
			
			this.controller = controller;
			c = reference.numChildren > 0 ? reference.getChildAt(0) : reference.addChild(new Shape());
			
			if (history) { h = new Array(); }
			
			if (active) { activate(); }
		}
		
		public function activate():void
		{
			if (!$activate()) { return; }
			
			D = Daemon.get('martian.sta7es.DeepLinking');
			if (D.available) { D.addEventListener(D.EXTERNAL, change); }
		}
		
		public function deactivate():void
		{
			if (!$deactivate()) { return; }
			
			if (D.available) { D.removeEventListener(D.EXTERNAL, change); }
		}
		
		public function control(controller:Controller, refresh:Boolean = false):void
		{
			this.controller = controller;
			if (D.available || refresh) { change(null); }
		}
		
		public function update(at:int):void
		{
			if (!D.available) { return; }
			i = (at == IMMEDIATLY);
		}
		
		private function change(e:Event):void
		{
			if (controller == null || !D.available) { return; }
			
			var path:Array;
			
			if (D.path.length > 0)
			{
				path = D.path;
					path.pop();
			}
			else { path = new Array(''); }
			
			execute(controller.handle(path.join(SEPARATOR)));
		}
		
		public function back(level:int = 1):void
		{
			if (!h) { return; }
			
			level = Maths.clamp(level, 1, h.length);
			load(h[h.length - level]);
		}
		
		public function load(path:String, extra:Object = null):void
		{
			if (controller == null) { return; }
			execute(controller.handle(path, extra));
		}
		
		public function execute(statement:Statement):void { swap(statement); }
		
		private function swap(statement:Statement):void
		{
			if (DEBUG)
			{
				log('*************************');
				log('State: ' + (statement ? statement.toString() : 'null'));
			}
			if (!statement) { return; }
			
			if (m) { q = statement; return; }
			else
			{
				q = null;
				
				m = true;
				stage.mouseChildren = false;
			}
			
			if (DEBUG && statement.slug.length != 0) { log('State: ' + statement.slug); }
			
			var module:Class = statement.module,
				module_parameters:Object = statement.module_parameters,
				transition:Class = statement.transition,
				transition_parameters:Object = statement.transition_parameters,
				slug:String = statement.slug;
				
			var n:*, t:*;
			
			var f:Function = function():void
			{
				if (DEBUG) { log('State: module ready event caught !'); }
				
				if (D.available && i) { D.value = slug; }
				if (D.available) { D.lock(); }
				
				t = new transition(c, n);
					on(t, Transition.READY, function():void
					{
						if (DEBUG) { log('State: transition ready event caught !'); }
						
						on(t, Transition.SWAP, function():void
						{
							tell(State.SWAP);
						});
						
						on(t, Transition.STOP, function():void
						{
							if (DEBUG) { log('State: transition stop event caught !'); }
							
							if (D.available)
							{ 
								D.unlock();
								if (!i) { D.value = slug; }
							}
							
							m = false;
							stage.mouseChildren = true;
							
							if (c is Module)
							{
								if (DEBUG) { log('State: old module memory release'); }
								c.kill();
							}
							
							c = n;
							n = null;
							
							if (DEBUG) { log('State: end of process'); }
							tell(STOP);
							
							queue();
							gc();
						});

						
						if (DEBUG) { log('State: transition start() call. waiting for stop event...'); }
						t.start();
					});
					
					if (DEBUG) { log('State: transition setup() call. waiting for ready event...'); }
					t.setup(module_parameters, transition_parameters);
					
				if (h) { h.push(statement.slug); }
			};
			
			n = new module();
			
			tell(START);
			
			if (n is Module)
			{
				if (DEBUG) { log('State: module init() call. waiting for ready event...'); }
				on(n, Module.READY, f.call);
				n.init(module_parameters);
			}
			else { f.call(); }	
		}
		
		private function queue():void { if (q) { execute(q); } }
	}
}