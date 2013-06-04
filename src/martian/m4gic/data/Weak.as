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
	import flash.utils.*;
	
	public dynamic class Weak extends Proxy
	{
		private var item:Dictionary;
		
		public function Weak(weak:Object)
		{
			item = new Dictionary(true);
				item[weak] = true;
		}
		
		public function get object():*
		{
			for (var weak:* in item) { return weak; }
			return undefined;
		}
		
		override flash_proxy function callProperty(methodName:*, ... args):* { return object ? object[methodName].apply(object, args) : undefined; }
		override flash_proxy function getProperty(name:*):* { return object ? object[name] : undefined; }
		override flash_proxy function setProperty(name:*, value:*):void { object ? object[name] = value : null; }
		override flash_proxy function hasProperty(name:*):Boolean { return object ? object[name] != undefined : false; }
		override flash_proxy function deleteProperty(name:*):Boolean { return false; }
	}
}