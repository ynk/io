/*
Copyright (c) 2010 julien barbay <barbay.julien@gmail.com>

 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the 'Software'), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:

 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
*/

package martian.m4gic.layout
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	
	import flash.geom.Point;
	
	import martian.m4gic.data.Ini;
	import martian.m4gic.tools.Geoms;
	
	public function align(target:*, parameters:Object = null, apply:Boolean = true):*
	{
		if (target is Array)
		{
			var points:Array = new Array();
			for each(var element:* in target) { points.push(align(element, parameters, apply)); }
			
			return points;
		}
		
		var ini:Ini = new Ini(parameters),
			to:Object = ini.like('to', { x:Number, y:Number }, new Error('You must provide a valid hook to target')),
			on:int = 0, policy:String = ini.string('on', 'topleft'),
			offset:* = Geoms.position(ini.star('offset', 0)),
			math:Function = Math[ini.string('and')] || ini.method('and'),
			compute:Point = new Point();
			
		if (policy.indexOf('top') != -1) { on += 0x000001; }
		else if (policy.indexOf('middle') != -1) { on += 0x000010; }
		else if (policy.indexOf('bottom') != -1) { on += 0x000100; }
		
		if (policy.indexOf('left') != -1) { on += 0x001000; }
		else if (policy.indexOf('center') != -1) { on += 0x010000; }
		else if (policy.indexOf('right') != -1) { on += 0x100000; }
			
		if (to.width == undefined) { to.width = 0; }
		if (to.height == undefined) { to.height = 0; }
		
		var width:Number = !(to is Stage) ? to.width : (to as Stage).stageWidth,
			height:Number = !(to is Stage) ? to.height : (to as Stage).stageHeight;
			
		if (to is DisplayObject && !(to is Stage) && (target.parent != to.parent)) { offset.add(target.localToGlobal(new Point()).subtract(to.localToGlobal(new Point()))); }
			
		if 		(on & 0x000001) { compute.y = offset.y + to.y; }
		else if (on & 0x000010) { compute.y = offset.y + to.y + (height - target.height) / 2; }
		else if (on & 0x000100)	{ compute.y = offset.y + to.y + height - target.height; }
		else	{ compute.y = target.y }
		
		if 		(on & 0x001000) { compute.x = offset.x + to.x; }
		else if (on & 0x010000) { compute.x = offset.x + to.x + (width - target.width) / 2; }
		else if (on & 0x100000) { compute.x = offset.x + to.x + width - target.width; }
		else	{ compute.x = target.x }
		
		if (apply)
		{
			target.x = math != null ? math.call(null, compute.x) : compute.x;
			target.y = math != null ? math.call(null, compute.y) : compute.y;
		}
		
		return apply ? target : compute;
	}
}