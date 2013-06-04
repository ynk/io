package martian.m4gic.tools 
{
	import martian.m4gic.log;
	
	public function objectize(xml:*, schema:Object = null, keep_raw:Boolean = false):Object
	{
		if (xml is String) { xml = new XML(xml); }
		if (!xml || !(xml is XML)) { return null; }
		
		var children:XMLList = xml.children(),
			object:Object = new Object();
		
		for each(var child:XML in children)
		{
			var name:String = String(child.name()),
				value:* = null;
					
			if (child.@ignore != undefined) { continue; }
			if (object[name] != undefined && !(object[name] is Array)) { object[name] = [object[name]]; }
			
			if (child.hasSimpleContent())
			{
				if (schema && schema[name] && schema[name] is Class) { value = schema[name](child.valueOf()); }
				else 
				{
					var is_numeric:Boolean = !isNaN(parseFloat(String(child.valueOf())));
						if (child.@type == 'string') { is_numeric = false; }
						
					value = is_numeric ? parseFloat(String(child.valueOf())) : String(child.valueOf());
					if (value is String) { if (value.toLowerCase() === 'true' || value.toLowerCase() === 'false') { value = (value.toLowerCase() == 'true'); } }
				}
			}
			else { value = objectize(child, schema); }
			
			if (object[name] is Array) { object[name].push(value); }
			else { object[name] = value; }
		}
		
		if (keep_raw) { object['__rawdata__'] = xml; }
		
		return object;
	}
}