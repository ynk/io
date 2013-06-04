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

package martian.m4gic.tools
{
	import flash.system.ApplicationDomain;
	
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	public class Domain
	{
		static public function describe(object:*):XML { return describeType(object); }
		
		static public function report(object:*):String { return describeType(object).toString(); }
		
		static public function is_dynamic(object:*):Boolean
		{
			var desc:XML = describeType(object);
				return desc.@isDynamic == "true";
		}
		
		static public function identify(object:*, full:Boolean = true):String
		{
			var desc:XML = describeType(object);
			if (String(desc.@name).indexOf("builtin") != -1) { return format(desc.@base); }
			
			var name:String = format(desc.@name);
			
			return full ? name : name.substr(name.lastIndexOf("."));
		}
		
		static public function qualify(object:*, datamodel:Class):Boolean
		{
			if (extending(object, datamodel) || implementing(object, datamodel)) { return true; }
			
			var definition:XML = describeType(datamodel),
				accessors:XMLList = definition..accessor,
				contract:Object = new Object();
			
			for each(var accessor:XML in accessors)	{ if (String(accessor.@name) != "prototype") { contract[String(accessor.@name)] = define(String(accessor.@type)); } }
			
			var respect:Boolean = true,
				contract_id:String,
				object_id:String;
			
			for (var key:* in contract)
			{
				if (key in object)
				{
					object_id = identify(object[key]);
						if (object_id == "int") { object_id = "Number"; }
						
					contract_id = identify(contract[key]);
					
					if (object_id != contract_id) { respect = false; }
				}
				else { respect = false; }
			}
			
			return respect;
		}
		

		static public function define(full_classname:String):Class
		{
			if (ApplicationDomain.currentDomain.hasDefinition(full_classname)) { return ApplicationDomain.currentDomain.getDefinition(full_classname) as Class; }
			return null;
		}
		
		static public function pattern(object:Object):Class
		{
			var cls:String = getQualifiedClassName(object);
				return getDefinitionByName(cls) as Class;
		}		
		
		static public function extend(object:*):Array
		{
			var desc:XML = describeType(object);
			
			var inheritances:Array = new Array();
			
			inheritances.push(format(desc.@name));
			for each(var imp:XML in desc..extendsClass) { inheritances.push(format(imp.@type)); }
			
			return inheritances;
		}
		
		static public function extending(object:*, cls:Class):Boolean
		{
			var inheritances:Array = extend(object);
			var pack_class:String = identify(cls);
			
			for each(var ext:String in inheritances) { if (ext === pack_class) { return true; } }
			return false;
		}
		
		static public function implement(object:*):Array
		{
			var desc:XML = describeType(object);
			
			var interfaces:Array = new Array();
			
			for each(var imp:XML in desc..implementsInterface) { interfaces.push(format(imp.@type)); }
			
			return interfaces;
		}
		
		static public function implementing(object:*, cls:Class):Boolean
		{
			var interfaces:Array = implement(object);
			var pack_class:String = identify(cls);
			
			for each(var imp:String in interfaces) { if (imp === pack_class) { return true; } }
			return false;
		}
		
		static public function introspect(object:*, echo:Boolean = true):String
		{
			var report:String = "[Introspection]\n";
			for (var key:* in object) { report += "\tkey: " + key.toString() + ", value: " + (object[key] != null ? object[key].toString() : "null") + " (" + typeof(object[key]) + ")\n"; }
			
			if (echo) { trace(report); }
			
			return report;
		}

		static private function format(string:*, double:Boolean = true):String
		{
			string = String(string);
			return double ? string.split("::").join(".") : string.substr(0, string.lastIndexOf(".")) + "::" + string.substr(string.lastIndexOf(".") + 1);
		}
		
		public function Domain() {}
	}
}