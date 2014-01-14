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

package martian.m4gic.data
{
	import flash.utils.getQualifiedClassName;
	import martian.m4gic.tools.objectize;

	public class Ini
	{
		static private function type_of(object:*, match:*):Boolean
		{
			if (match is Class) { return (object is match); }
			else if (match is String) { return getQualifiedClassName(object) == match; }

			return false;
		}

		static public function check(object:Object, property:String, type:Class = null):Boolean
		{
			if (object && property in object)
			{
				if (type != null) { return object[property] is type; }
				return true;
			}
			return false;
		}

		static public function like(object:Object, pattern:Object, default_value:* = null):*
		{
			var target:Object = object;
				if (!target) { return default_value; }

			for (var property:String in pattern) { if (!check(target, property, pattern[property])) { return default_value; } }

			return target;
		}

		static public function extract(object:Object, property:String, type:Class = null, default_value:* = null):*
		{
			if (!object) { return default_value; }

			if (object[property] is XML && type === Object) { return objectize(object[property] as XML, true); }
			else if (check(object, property, type)) { return object[property]; }
			else if (object[property] is Class)
			{
				var foo:*;

				try { foo = new object[property](); }
				catch (e:Error) { return default_value; }

				if (foo is type) { return object[property]; }
			}

			if (default_value is Error) { throw default_value; }
			else { return default_value; }
		}

		public var config:Object;
			public function get keys():Array
			{
				var k:Array = new Array();
				for(var p:String in config) { k.push(p); }
				return k;
			}

		public function Ini(config:Object) { this.config = config; }

		public function star(property:String, default_value:* = null):* { return extract(config, property, null, default_value); }
		public function numeric(property:String, default_value:* = 0):* { return extract(config, property, Number, default_value) as Number; }
		public function unsigned(property:String, default_value:* = 0):uint { return extract(config, property, uint, default_value) as uint; }
		public function integer(property:String, default_value:* = 0):int { return extract(config, property, int, default_value) as int; }
		public function number(property:String, default_value:* = 0):Number { return extract(config, property, Number, default_value) as Number; }
		public function string(property:String, default_value:* = ""):String { return extract(config, property, String, default_value) as String; }
		public function boolean(property:String, default_value:* = false):Boolean { return extract(config, property, Boolean, default_value) as Boolean; }
		public function array(property:String, default_value:* = null):Array { return extract(config, property, Array, default_value) as Array; }
		public function method(property:String, default_value:* = null):Function { return extract(config, property, Function, default_value) as Function; }
		public function xml(property:String, default_value:* = null):XML { return extract(config, property, XML, default_value) as XML; }
		public function cast(property:String, type:Class, default_value:* = null):* { return extract(config, property, type, default_value); }
		public function exists(property:String):Boolean { if (config != null) { return config[property] != undefined; } return false; }
		public function enum(property:String, values:Array, default_value:* = null):*
		{
			if (!exists(property)) { return default_value; }

			var data:* = extract(config, property, null, null);
			for each(var value:* in values) { if (value == data) { return data; } }

			return default_value;
		}

		public function like(property:String, pattern:Object, default_value:* = null):*
		{
			var target:Object = extract(config, property, Object);
				if (!target) { return default_value; }

			return Ini.like(target, pattern, default_value);
		}

		public function dispose():void { config = null; }
	}
}