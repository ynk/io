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
	public function unnamespace(xml:XML, prefix_namespaces:Boolean = false):XML 
	{
		var tmp:String = xml.toXMLString();
			tmp = tmp.replace(new RegExp("((xmlns(:\\w+)?)|(xsi(:\\w+)?))\\s*=\\s*(\"[^\"]*\")", 'g'), '');
			
		if (!prefix_namespaces) { tmp = tmp.replace(new RegExp("<(/?)\\w+:", 'g'), "<$1"); }
		else { tmp = tmp.replace(new RegExp("<(/?)(\\w+):", 'g'), "<$1$2"); }
			
		return new XML(tmp);
	}
}