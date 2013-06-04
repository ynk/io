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
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.ByteArray;
	import martian.m4gic.log;
	
	public class Flv extends Video 
	{
		use namespace hidden;
		
		static public const READY:String = 'videoReady';
		static public const PLAY:String = 'videoPlay';
		static public const PAUSE:String = 'videoPause';
		static public const STOP:String = 'videoStop';
		
		private var connection:NetConnection;
        private var stream:NetStream;
		private var client:ProxyClient;
		
		private var bytearray:ByteArray;
		
		hidden var 	_onmetadata:Function = null,
					_onxmpdata:Function = null,
					_oncuepoint:Function = null,
					_fps:Number = -1;
		
		public function get soundTransform():SoundTransform { return stream.soundTransform; }
		public function set soundTransform(s:SoundTransform):void { stream.soundTransform = s; }		
		
		public function get fps():Number { return _fps; }
		
		public function Flv(data:ByteArray = null)
		{
			super();
			if (data) { load(data); }
		}
		
		public function load(data:ByteArray):Flv
		{
			if (!data) { return this; }
				bytearray = data;
			
			connection = new NetConnection();
				connection.addEventListener(NetStatusEvent.NET_STATUS, netstatus);
				connection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, error);
				connection.connect(null);
				
			return this;
		}
		
		private function netstatus(e:NetStatusEvent):void
		{
            switch (e.info.code)
			{
                case 'NetConnection.Connect.Success':
					stream = new NetStream(connection);
						stream.bufferTime = 0;
						stream.inBufferSeek = true;
						stream.client = client = new ProxyClient(this);
						stream.addEventListener(NetStatusEvent.NET_STATUS, netstatus);
						stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, error);
					
					stream.play(null);
					stream.pause();
					
					stream.appendBytes(bytearray);
					attachNetStream(stream);
					break;
					
				case 'NetStream.Buffer.Empty':
				case 'NetStream.Play.Stop':
					dispatchEvent(new Event(Flv.STOP));
					break;
					
				default:
					log(e.info.code);
					break;
            }
        }
		
		private function error(e:AsyncErrorEvent):void { log('Flv: Async Error', stream.client, e.error.getStackTrace()); }
		
		public function play():Flv
		{
			dispatchEvent(new Event(Flv.PLAY));
			stream.resume();
			
			return this;
		}
		
		public function pause():Flv
		{
			dispatchEvent(new Event(Flv.PAUSE));
			stream.pause();
			
			return this;
		}
		
		public function dispose():void
		{
			stream.pause();
			
			stream.close();
			connection.close();
		}
		
		public function onmetadata(callback:Function):Flv
		{
			_onmetadata = callback;
			return this;
		}
		
		public function onxmpdata(callback:Function):Flv
		{
			_onxmpdata = callback;
			return this;
		}
		
		public function oncuepoint(callback:Function):Flv
		{
			_oncuepoint = callback;
			return this;
		}
	}
}

import flash.events.Event;
import martian.m4gic.display.Flv;
import martian.m4gic.log;

internal class ProxyClient
{
	use namespace hidden;
	
	private var flv:Flv;
	public function ProxyClient(flv:Flv):void { this.flv = flv; }
	
	public function onMetaData(...args):void
	{
		flv.width = args[0].width;
		flv.height = args[0].height;
		
		flv._fps = args[0].framerate;
		flv.dispatchEvent(new Event(Flv.READY));
		
		if (flv._onmetadata != null) { flv._onmetadata.call(null, args[0]); }
	}
	
	public function onXMPData(...args):void { if (flv._onxmpdata != null) { flv._onxmpdata.call(null, args[0]); } }
	public function onCuePoint(item:Object):void { if (flv._oncuepoint != null) { flv._oncuepoint.call(null, item); } }
}

internal namespace hidden;