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

package martian.m4gic
{
	import flash.external.ExternalInterface;
	import flash.system.Capabilities;
	
	/**
	 * An enhanced trace function designed to also trace in firebug
	 */
	
	public function log(...args):String
	{
		//for readable purposes
		args.forEach(function(item:*, index:int, array:Array):void
		{
			if (item == null) { array[index] = 'null'; }
			else if (item == undefined) { array[index] = 'undefined'; }
		});
		
		var data:String = args.join(' ');
		var level:int = 1;
		
		if (new RegExp('^[1-3]:\\s?').test(data))
		{
			level = parseInt(data.charAt(0));
			data = data.substr(data.indexOf(':'));
		}
		
		if (!Capabilities.isDebugger)
		{
			trace(data);
			return data;
		}
		
		var line:String = "";
		
		try	{ throw new Error(); }
		catch (e:Error)
		{
			var stack:String = e.getStackTrace().split('\n')[2];
				stack = stack.substr(stack.lastIndexOf('['));
				
			var token:String = 	stack.indexOf('\\') > -1 ? '\\' : '/';
				
			line = '[' + stack.substr(stack.lastIndexOf(token) + 1, stack.lastIndexOf(']') - 1);
				line = line.replace(new RegExp('[\\t\\r\\n]*', 'g'), '');
		}
		
		var now:Date = new Date();
		
		if (line.length > 0) { line += '\t (' + [now.date, (now.month + 1), now.fullYear].join('/') + ' ' + [now.hours, now.minutes, now.seconds, now.milliseconds].join(':') + ') \t'; }
		trace(line, data);
		
		if (ExternalInterface.available)
		{
			try
			{
				if (ExternalInterface.call('eval', 'console != undefined'))
				{
					var call:String = 'log';
						if (level == 2) { call = 'info'; }
						else if (level == 3) { call = 'warn'; }
						
					ExternalInterface.call('console.' + call, line + ' ' + data);
				}
			}
			catch (e:SecurityError) { return data; }
		}
		
		return data;
	}
}