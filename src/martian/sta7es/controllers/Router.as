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

package martian.sta7es.controllers
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import flash.net.URLRequest;
	
	import flash.utils.getDefinitionByName;

	import martian.daem0n.core.Daemon;
	
	import martian.ev3nts.on;

	import martian.m4gic.log;
	import martian.m4gic.tools.objectize;
	import martian.m4gic.tools.Domain;
	import martian.m4gic.tools.Maths;
	
	import martian.sta7es.core.Controller;
	import martian.sta7es.core.Navigation;
	import martian.sta7es.core.Statement;
	
	import martian.t1me.data.Load;
	import martian.t1me.interfaces.Stackable;
	import martian.t1me.misc.Time;
	
	public class Router extends EventDispatcher implements Stackable, Controller
	{
		private var I:*;
		
		public var SEPARATOR:String = '/';
		public var OPTIONAL:String = 'default';
		
		public var navigation:Navigation;
		
		private var feeder:Load;
		private var feed:XML;
		private var current:String = 'initializing...';
		
		private var delegate:Object;

		public function Router(feed:*, delegate:Object = null)
		{
			if ((feed is String && String(feed).indexOf('.xml') > -1) || (feed is String && String(feed).indexOf('.php') > -1) || feed is URLRequest)
			{
				feeder = new Load(feed, Load.TEXT, false);
					on(feeder, Event.COMPLETE, ondata);
			}
			else if (feed is String) { this.feed = new XML(feed); }
			else if (feed is XML) { this.feed = feed; }
			else { throw new ArgumentError('Wrong argument type : feed (' + typeof(feed) + ')'); }

			this.delegate = delegate;
		}
		
		public function load():Controller 
		{
			start();
			return this;
		}
		
		public function start():void
		{
			if (feeder) { feeder.load(); }
			else { dispatchEvent(new Event(Time.STOP)); }
		}
		
		private function ondata(e:Event):void
		{
			store(XML(e.target.data));
			feeder.dispose();
		}
		
		private function store(xml:XML):void
		{
			feed = xml;
			dispatchEvent(new Event(Time.STOP));
		}
		
		public function handle(url:String, extra:Object = null):Statement 
		{
			if (!I) { I = Daemon.get('martian.daem0n.i18n'); }
			if (url == current) { return null; }

			var data:XML, default_state:Boolean, parameters:Object = '';
			
			if (url == '/')
			{
				var modules:XMLList = feed.states.state.slug.pattern.(valueOf() == '/');
				
				if (!modules || modules.length() == 0) { modules = feed.states.state.slug.(valueOf() == '/'); }
				if (!modules || modules.length() == 0) { throw new Error('No default state provided'); return null;  }
				
				data = modules[0].parent();
					if (data.name() != 'state') { data = data.parent(); }

				default_state = true;
			}
			else
			{
				var url_split:Array = url.split(SEPARATOR),
					expression:String,
					expression_split:Array,
					optionals:int = 0,
					parameter:String,
					constraint:String,
					validation:Boolean;
					
				for each (var state:XML in feed.states.state)
				{
					expression = state.slug.pattern != undefined ? state.slug.pattern.valueOf().toString() : state.slug.valueOf().toString();
					expression_split = expression.split(SEPARATOR);

					if (state..constraints != undefined) { optionals = state..constraints.children().attributes().(name() == OPTIONAL).length(); }
					else { optionals = 0; }
					
					if (!Maths.between(url_split.length, expression_split.length - optionals, expression_split.length)) { continue; }

					//quick solving
					if (expression.indexOf('{') == -1)
					{
						if (url == expression)
						{
							data = state;
							break;
						}
						else { continue; }
					}
					
					parameters = '<parameters>';
					validation = true;
					
					for (var i:int = 0; i < expression_split.length; i++)
					{
						if (i >= url_split.length)
						{
							if (state..constraints != undefined)
							{
								parameter = expression_split[i].substr(1, expression_split[i].length - 2);
								
								var node:XML = state..constraints.children().(name() == parameter)[0];
								
								parameters += '<' + parameter + '>' + node.attribute(OPTIONAL).toString() + '</' + parameter + '>';
							}
							
							continue;												
						}
						
						//i18n replacement
						if (I.available && url_split[i].charAt(0) == ':') { url_split[i] = I.get(url_split[i]); }
						
						//static part
						if (expression_split[i].indexOf('{') == -1)
						{
							if (url_split[i] != expression_split[i]) { break; }
							else { continue; }
						}
						
						//dynamic part
						parameter = expression_split[i].substr(1, expression_split[i].length - 2);
						parameters += '<' + parameter + '>' + url_split[i] + '</' + parameter + '>';

						if (state..constraints != undefined)
						{
							constraint = state..constraints.children().(name() == parameter)[0].toString();

							if (constraint.length == 0) { validation = true; }
							else if (constraint.charAt(0) == '@')
							{
								constraint = constraint.substr(1);
								validation = new RegExp(constraint).test(url_split[i]);
							}
							else if (delegate != null)
							{
								try { validation = (delegate[constraint].call(null, url_split[i]) === true); }
								catch(e:Error) { validation = false; }
							}
							
							if (!validation) { break; }
						}
					}
					
					parameters += '</parameters>';
					
					if (validation)
					{
						data = state;
						break;
					}
					else { continue; }
				}

				default_state = false;
			}

			if (!data)
			{
				if (feed.notfound) { return handle(feed.notfound.toString(), extra); }
				else { throw new Error('404 Not found'); }
			}
				
			var module:Class;
				try { module = getDefinitionByName(String(feed.states.@app) + '.' + data.module) as Class; }
				catch(e:Error) { throw new Error('Given state is not included : ' + String(feed.states.@app) + '.' + data.module); return null; }
			
			var transitions:XMLList = feed.transitions.transition.((@from == current || @from == '*') && (@to == state || @to == '*')),
				change:String, configuration:Object;
				
				if (XML(transitions[0]).hasSimpleContent()) { change = transitions[0] || String(feed.transitions.@default) || 'Slave'; }
				else
				{
					change = String(transitions[0].name);
					configuration = XML(transitions[0].parameters);
				}
				
			var transition:Class;
				try { transition = getDefinitionByName(String(feed.transitions.@app) + '.' + change) as Class; }
				catch (e:Error)
				{
					try { transition = getDefinitionByName(String('martian.sta7es.transitions.') + change) as Class; }
					catch(e:Error) { throw new Error('Given transition is not included : ' + String(feed.transitions.@app) + '.' + change); return null; }
				}
				
			current = url;

			if (navigation) { navigation.handle(current); }
				
			parameters = objectize(new XML(parameters));
			
			if (data.slug.parameters != undefined)
			{
				var xml_parameters:Object = objectize(data.slug.parameters);
				
				if (!parameters) { parameters = new Object(); }
				for(k in xml_parameters) { parameters[k] = xml_parameters[k]; }
			}
			
			if (extra)
			{
				var k:*;
				
				if ('module_parameters' in extra || 'transition' in extra || 'transition_parameters' in extra)
				{
					if ('module_parameters' in extra) { for (k in extra.module_parameters) { parameters[k] = extra.module_parameters[k]; } }
					if ('transition' in extra) { transition = extra.transition; }
					if ('transition_parameters' in extra) { for (k in extra.transition_parameters) { configuration[k] = extra.transition_parameters[k]; } }
				}
				else { for(k in extra) { parameters[k] = extra[k]; } }
			}
			
			return new Statement(module, { slug:current, module_parameters:parameters, transition:transition, transition_parameters:configuration });
		}
		
		public function dispose():void 
		{
			feeder.dispose();
			feeder = null;
		}
	}
}