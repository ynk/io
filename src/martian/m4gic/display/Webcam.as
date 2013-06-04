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

package martian.m4gic.display 
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.ActivityEvent;
	import flash.events.Event;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import flash.media.Camera;
	import flash.media.Video;
	
	import martian.m4gic.graphics.draw;

	public class Webcam extends Sprite
	{
		static public const PLAYING:String = "playing";
		static public const STOPPED:String = "stopped";
		
		private var video:Video;
		
		private var buffer:BitmapData;
			public function get output():BitmapData { return buffer.clone(); }
			
		private var t:uint = NaN;	
		private var s:Boolean = false;
			public function get status():String { return s ? PLAYING : STOPPED; }
			
		private var f:int = 60;	
			public function get framerate():int { return f; }
			public function set framerate(i:int):void 
			{
				f = i;
				if (s) { stop(); start(); }
			}
			
		public function get brightness():int
		{
			var bmd:BitmapData = output,
				b:uint = 0,	c:int;
			
			for (var y:int = 0; y < bmd.height; y++)
			{
				for (var x:int = 0; x < bmd.width; x++)
				{
					c = bmd.getPixel(x, y);
					b += Math.max(c >> 16, c >> 8 & 0xFF, c & 0xFF);
				}
			}
			
			return b / (bmd.width * bmd.height);
		}
			
			
		public function Webcam(width:int = 320, height:int = 240)
		{
			var camera:Camera = Camera.getCamera();
				camera.addEventListener(ActivityEvent.ACTIVITY, onactivate);
				camera.setMode(width, height, 60);
			
			video = new Video(width, height);
				video.attachCamera(camera);
			
			buffer = new BitmapData(width, height, false, 0);
				draw(this).bitmap(buffer);
		}
		
		private function onactivate(e:ActivityEvent):void { dispatchEvent(new Event('ready')); }
		
		public function start():void
		{
			if (!s)
			{
				t = setInterval(enterframe, 1000 / f);
				s = true;
			}
		}
		
		public function stop():void
		{
			if (s)
			{
				clearInterval(t);
				s = false;
			}
		}
		
		private function enterframe():void
		{
			buffer.unlock();
			buffer.draw(video);
			buffer.lock();
		}
	}
}