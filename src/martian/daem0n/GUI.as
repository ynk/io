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

package martian.daem0n
{
	import flash.display.*;
	
	import flash.utils.Dictionary;
	
	import martian.daem0n.core.Daemon;
		
	public class GUI extends Daemon
	{
		private var labels:Dictionary;
		private var layers:Array;
		
		public function GUI() { name = "GUI"; }
		
		public function hook(container:Sprite, length:* = 3):void 
		{
			if (!$hook(container)) { return; }
			
			if (isNaN(length) && !(length is Array)) { throw new Error('length can be an array of strings or a length'); }	
			
			var sprites:int = length is Array ? length.length : length;
				if (sprites < 1) { sprites = 1; }
				
				
			labels = new Dictionary();				
				
			layers = new Array(sprites);
				for (var i:int = 0; i < sprites; i++)
				{
					layers[i] = reference.addChild(new Sprite()) as Sprite;
					if (length is Array)
					{
						labels[length[i]] = i;
						layers[i].name = length[i];
					}
				}
			
			$activate();
		}
		
		public function kill():void
		{
			if (!$kill()) { return; }
			
			labels = null;	
				
				for (var i:int = 0; i < layers.length; i++)
				{ layers[i] = null; }
				
			layers = null;
		}
		
		public function get(identifier:*):* { return layer(identifier); }
		
		public function layer(identifier:*):*
		{
			if (available)
			{
				var index:int;
				if (identifier is int) { index = identifier; }
				else if (identifier is String) { index = labels[identifier]; }
				
				return layers[index];
			}
			
			return null;
		}
		
		public function replace(identifier:*, replacement:*, return_old:Boolean = false):*
		{
			if (available)
			{
				var index:int;
				if (identifier is int) { index = identifier; }
				else if (identifier is String) { index = labels[identifier]; }
				
				reference.addChild(replacement);
				reference.swapChildren(layers[index], replacement);
				reference.removeChild(layers[index]);
				
				var tmp:* = layers[index];
				layers[index] = replacement;
				if (identifier is String) { layers[index].name = identifier; }
				
				return return_old ? tmp : replacement;
			}
			
			return null;
		}
		
		public function label(depth:int, name:String):void
		{
			if (available)
			{
				labels[name] = depth;
				layers[depth].name = name;
			}
		}	
	}
}