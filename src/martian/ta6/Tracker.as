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

package martian.ta6 
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;
	import flash.net.*;
	import flash.utils.*;

	import martian.ev3nts.helpers.on;
	import martian.m4gic.log;
	import martian.t1me.data.Load;
	
	import martian.daem0n.core.Daemon;
	
	public class Tracker extends Daemon 
	{
		static private var STOPPED:int = 0;
		static private var RECORDING:int = 1;
		static private var PLAYING:int = 2;
		
		static private var length:int = 10;
		static private var events:Array = [	MouseEvent.CLICK,
											MouseEvent.DOUBLE_CLICK,
											MouseEvent.MOUSE_DOWN,
											MouseEvent.MOUSE_UP,
											MouseEvent.MOUSE_MOVE,
											MouseEvent.MOUSE_OUT,
											MouseEvent.MOUSE_OVER,
											MouseEvent.ROLL_OUT,
											MouseEvent.ROLL_OVER,
											MouseEvent.MOUSE_WHEEL ];
		
		private var status:int;
		private var data:ByteArray;
		private var zero:int;
		private var dp:InteractiveObject;
		
		public var filename:String = new Date().getTime().toString();
		
		public function Tracker() {}
		
		public function hook(stage:Stage):void { if (!$hook(stage)) { return; } }
		public function kill():void { if (!$kill()) { return; } }
		
		//READING PART
		public function load(data:* = null):void
		{
			if (!data)
			{
				var file:FileReference = new FileReference();
					on(file, Event.SELECT, onselect);
					file.browse([new FileFilter("mouse tracker file", "*.trk")]);
			}
			else if (data is ByteArray) { play(data as ByteArray); }
			else
			{
				var loader:Load = new Load(data, Load.BINARY);
					on(loader, Event.COMPLETE, onload);
					loader.load();
			}
		}
		
		private function onselect(e:Event):void 
		{
			var file:FileReference = e.target as FileReference;
				on(file, Event.COMPLETE, onload);
				file.load();
		}
		
		private function onload(e:Event):void { play(e.target.data as ByteArray); }
		
		public function play(track:ByteArray):void
		{
			if (status != STOPPED) { return; }
			
			data = track;
			
			if (data.readUTFBytes(3) != "TRK")
			{
				throw new Error("Invalid file format");
					data = null;
					return;
			}
			
			zero = getTimer();
				setTimeout(step, data.readInt());
				
			status = PLAYING;
		}
		
		private function step():void
		{
			var type:String = events[data.readInt()],
				stagex:int = data.readInt(),
				stagey:int = data.readInt(),
				localx:int = data.readInt(),
				localy:int = data.readInt(),
				buttondown:Boolean = data.readBoolean(),
				altkey:Boolean = data.readBoolean(),
				ctrlkey:Boolean = data.readBoolean(),
				shitkey:Boolean = data.readBoolean(),
				delta:int = data.readInt(),
				time:int = -1;
				
			try { time = data.readInt(); }
			catch(e:Error) {}
				
			if (type.indexOf("Out") != -1) { this.dp.dispatchEvent(new MouseEvent(type, true, false, localx, localy, null, ctrlkey, altkey, shitkey, buttondown, delta)); }
			else
			{
				var dp:DisplayObject, dps:Array = stage.getObjectsUnderPoint(new Point(stagex, stagey));
					if (dps.length == 0) { return; }
				
				dps = dps.reverse();
				
				for (var i:int = 0; i < dps.length; i++)
				{
					dp = find(dps[i]);
					if (dp) { break; }
				}
				
				if(!dp && i == dps.length) { dp = stage; }
				this.dp = dp as InteractiveObject;
				
				this.dp.dispatchEvent(new MouseEvent(type, true, false, localx, localy, null, ctrlkey, altkey, shitkey, buttondown, delta));
			}
			
			if (time >= 0) { setTimeout(step, time); }
			else
			{
				log("end of replay");
				status = STOPPED;
			}
		}

	private function find(base:DisplayObject):DisplayObject
	{
		if (!base) { return null; }
		
		var dp:DisplayObject;
		
		while(!dp)
		{
			if (base == stage) { break; }
			else if (base is InteractiveObject)
			{
				if (!(base as InteractiveObject).mouseEnabled) { base = base.parent; }
				else if (getQualifiedClassName(base).indexOf("MainTimeline") != -1) { base = base.parent; }
				else
				{
					var parent:DisplayObjectContainer = base.parent as DisplayObjectContainer;
					
					while (parent != null)
					{
						if (!parent.mouseChildren) { break; }
						parent = parent.parent;
					}
					
					dp = !parent ? base : parent;
					break;
				}
			}
			else { base = base.parent; }
		}
		
		return dp;
	}
		
		//RECORDING PART
		public function record():void
		{
			if (status != STOPPED) { return; }
			
			zero = getTimer();
			
			for (var i:int = 0; i < length; i++) { stage.addEventListener(events[i], proxy, true, int.MAX_VALUE - i); }
				data = new ByteArray();
				data.writeUTFBytes("TRK");
				
			status = RECORDING;
		}
		
		public function save():void
		{
			if (status != RECORDING) { return; }
			
			for (var i:int = 0; i < length; i++) { stage.removeEventListener(events[i], proxy, true); }
			
			data.position = 0;
			
			var file:FileReference = new FileReference();
				file.save(data, filename + ".trk");
			
			status = STOPPED;
		}
		
		private function proxy(e:MouseEvent):void 
		{
			var dp:InteractiveObject = e.target as InteractiveObject;
			
			if (!dp.hasEventListener(e.type))
			{
				var ignore:Boolean = true;
					dp = dp.parent;
					
				while (dp != stage)
				{
					if (dp.hasEventListener(e.type)) { ignore = false; break;  }
					dp = dp.parent;
				}
			}
			
			data.writeInt(getTimer() - zero);
			data.writeInt(indexOf(e.type));
			data.writeInt(e.stageX);
			data.writeInt(e.stageY);
			data.writeInt(e.localX);
			data.writeInt(e.localY);
			data.writeBoolean(e.buttonDown);
			data.writeBoolean(e.altKey);
			data.writeBoolean(e.ctrlKey);
			data.writeBoolean(e.shiftKey);
			data.writeInt(e.delta);
			
			zero = getTimer();
		}
		
		private function indexOf(event:String):int
		{
			for (var i:int = 0; i < length; i++) { if (event == events[i]) { return i; } }
			return -1;
		}
	}
}