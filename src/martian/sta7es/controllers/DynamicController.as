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

package martian.sta7es.controllers 
{
	import flash.utils.getDefinitionByName;
	
	import martian.sta7es.core.Controller;
	import martian.sta7es.core.Statement;
	import martian.sta7es.transitions.Slave;

	public class DynamicController implements Controller 
	{
		private var module_package:String;
		private var transition_package:String;
		
		public function DynamicController(module_package:String = "", transition_package:String = "")
		{
			this.module_package = module_package;
			this.transition_package = transition_package;
		}
		
		public function handle(url:String, extra:Object = null):Statement 
		{
			var module:Class, transition:Class, path:Array = url.split('/');
			
			try { module = getDefinitionByName(module_package + "." + path[0]) as Class; }
			catch (e:Error) { return null; }
			
			if (path[1])
			{
				try { transition = getDefinitionByName(transition_package + "." + path[1]) as Class; }
				catch (e:Error) { transition = Slave; }
			}
			
			return new Statement(module, { module_parameters:extra, transition:transition });
		}
	}
}