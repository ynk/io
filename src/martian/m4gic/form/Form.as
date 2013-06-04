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
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLVariables;

	public class Form extends EventDispatcher implements Field
	{
		public function get asset():Object { return objects; }

		private var n:String;
			public function get name():String { return n; }
			public function set name(s:String):void { n = s; }

		private var i:int = 0;
			public function get index():int { return objects[0].index; }
			public function set index(i:int):void
			{
				objects[0].index = i;
				
				for (var j:int = 1; j < objects.length; j++) { objects[j].index = objects[j - 1].next; }
				tell(Event.TAB_INDEX_CHANGE);
			}

		public function get next():int { return objects[objects.length - 1].next; }

		public function get value():Object
		{
			var result:Object = new Object();
				for each(var object:Field in objects) { result[object.name] = object.value; }
			
			return result;
		}
		
		public function set value(o:Object):void
		{
			for each(var object:Field in objects) { if (object.name in o) { object.value = o[object.name]; } }
		}
		
		private var objects:Vector.<Field>;
		public var errors:Vector.<Field>;
		
		public function Form(name:String, index:int = 0)
		{
			this.n = name;
			this.i = index;
			
			objects = new Vector.<Field>;
			errors = new Vector.<Field>;
		}

		public function get(at:int):Field { return objects[at]; }

		public function add(field:Field, at:int = -1):Form
		{
			if (at < 0) { objects.push(field); }
			else { objects.splice(at, 0, field); }
			
			field.addEventListener(Event.CHANGE, update);
				update(null);
			
			index = i + objects[0].index;
			
			return this;
		}

		public function remove(field:Field):Form
		{
			for (var i:int = 0, object:Field; object = objects[i]; i++)
			{
				if (object == field)
				{
					objects.splice(i, 1);
					index = objects[0].index;
					return this;
				}
			}
			
			return this;
		}
		
		private function update(e:Event):void { tell(Event.CHANGE); }
		
		public function validate():Boolean
		{
			errors = new Vector.<Field>();
				for (var i:int = 0; i < objects.length; i++) { if (!objects[i].validate()) { errors.push(objects[i]); } }
			
			return (errors.length == 0);
		}
		
		public function export(overwrite:Object = null):URLVariables
		{
			if (!overwrite) { overwrite = new Object(); }
			
			var vars:URLVariables = new URLVariables();
				for (var i:int = 0; i < objects.length; i++) { vars[overwrite[objects[i].name] ? overwrite[objects[i].name] : objects[i].name] = objects[i].value; }
				
			return vars;
		}
		
		private function tell(type:String):void { dispatchEvent(new Event(type)); }
	}
}
