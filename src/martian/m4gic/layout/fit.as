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

package martian.m4gic.layout
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import martian.m4gic.data.Ini;

	public function fit(target:*, parameters:Object = null, apply:Boolean = true):*
	{
		if (target is Array)
		{
			var rectangles:Array = new Array();
			for each(var element:* in target) { rectangles.push(fit(element, parameters, apply)); }
			
			return rectangles;
		}
		
		var ini:Ini = new Ini(parameters),
			to:DisplayObject = ini.cast("to", DisplayObject, new Error("You must provide a valid hook to target")),
			on:String = ini.string("on", "biggest"),
			math:Function = ini.string("and", null) ? Math[parameters["and"]] : null,
			offset:Point = new Point(),
			compute:Rectangle = new Rectangle();
		
		var width:Number = !(to is Stage) ? to.width : (to as Stage).stageWidth,
			height:Number = !(to is Stage) ? to.height : (to as Stage).stageHeight;
			
		if (!(to is Stage) && (target.parent != to.parent)) { offset.add(target.localToGlobal(new Point()).subtract(to.localToGlobal(new Point()))); }
		
		var sclX:Number = target.scaleX,
			sclY:Number = target.scaleY,
			tmpX:Number, tmpY:Number;
			
		target.scaleX = target.scaleY = 1;

		if (on == "box")
		{
			compute.width  = width;
			compute.height = height;
		}
		else if (on == "width")
		{
			compute.width  = width;
		}
		else if (on == "height")
		{
			compute.height = height;
		}
		else if (on == "biggest")
		{
			tmpX = (offset.x + width) / target.width,
			tmpY = (offset.y + height) / target.height;
				
			tmpX = tmpX > tmpY ? tmpX : tmpY;
			tmpY = tmpX;
			
			compute.width  = target.width  * tmpX;
			compute.height = target.height * tmpY;
		}
		else if (on == "smallest")
		{
			tmpX = (offset.x + width) / target.width,
			tmpY = (offset.y + height) / target.height;
				
			tmpX = tmpX < tmpY ? tmpX : tmpY;
			tmpY = tmpX;
			
			compute.width  = target.width  * tmpX;
			compute.height = target.height * tmpY;
		}
		
		if (apply)
		{
			if (on != "height") { target.width  = math != null ? math.call(null, compute.width)  : compute.width; }
			if (on != "width")  { target.height = math != null ? math.call(null, compute.height) : compute.height; }
		}
		
		return compute;
	}
}
