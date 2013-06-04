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
	public class Arrays
	{
		public function Arrays() { }
		
		static public function shuffle(array:Array):Array
		{
			var dump:Array = array.concat(), rnd:int,
				index:int = dump.length - 1, tmp:*;
			
			for (var i:int = 0; i < index; i++)
			{
				rnd = Math.random() * index;
				
				tmp = dump[i];
				dump[i] = dump[rnd];
				dump[rnd] = tmp;
			}
			
			return dump;
		}
		
		static public function contains(array:Array, object:*):int
		{
			var l:int = array.length;
			for (var i:int = 0; i < l; i++) { if (object == array[i]) { return i; } }
			return -1;
		}
		
		static public function partially(array:Array, string:String):int
		{
			var l:int = array.length;
			for (var i:int = 0; i < l; i++) { if (string.indexOf(array[i]) > -1) { return i; } }
			return -1;
		}
		
		static public function count(array:Array, object:*):int
		{
			var l:int = array.length, c:int = 0;
			for (var i:int = 0; i < l; i++) { if (object == array[i]) { c++; } }
			return c;
		}
		
		static public function distribute(data:Array, ...holders):void { for (var i:int = 0; i < data.length; i++) { holders[int(i % holders.length)].push(data[i]); } }
	}
}