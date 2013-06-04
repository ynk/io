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

package martian.ev3nts.helpers
{
	import flash.events.IEventDispatcher;
	
	//TODO refactor pour evnt.on et evnt.off
	public function on(dispatcher:IEventDispatcher, event:String, method:Function, ...parameters):Object
	{
		var handler:Function = function(e:* = null):void
		{
			if (e) { dispatcher.removeEventListener(event, handler); }
			
			if (parameters.length > 0)
			{
				try { method.apply(null, new Array(e).concat(parameters)); }
				catch (x:ArgumentError) { method.apply(null, parameters); }
			}
			else
			{
				try { method.call(null, e); }
				catch (x:ArgumentError) { method.call(); }
			}
			
			dispatcher = null;
			event = "";
			method = null;
			parameters = null;
		};
		
		dispatcher.addEventListener(event, handler/*, false, 0, true*/);
		
		return dispatcher as Object;
	}
}