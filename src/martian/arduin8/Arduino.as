package martian.arduin8
{
	import martian.m4gic.exec;
	import flash.utils.setTimeout;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.Socket;

	public class Arduino extends EventDispatcher
	{		
		//Events
		static public const CONNECTED:String = 'arduinoConnected';
		
		//Messaging constants
		static private const WATERMARK:int = 1304;
		static private const DEBUG_WATERMARK:int = 2903;
		
		static private const BOARD:int = -1;

		static private const DEBUG:int = 5;
		static private const FRAMERATE:int = 6;

		static private const GET:int = 11;
		static private const SET:int = 12;
		static private const NTF:int = 13;
		static private const UPT:int = 14;

		static private const VALUE:int = 21;
		static private const TYPE:int = 22;
		static private const MODE:int = 23;
		static private const WAVE:int = 24;




		private var socket:Socket;
		
		private var _debug:Boolean = true;
			public function get debug():Boolean { return _debug; }
			public function set debug(b:Boolean):void 
			{
				if (_debug != b)
				{
					send(BOARD, SET, DEBUG, b ? 1 : 0);
					_debug = b;
				}
			}
		
		private var _framerate:int = -1;
			public function get framerate():int { return _framerate; }
			public function set framerate(f:int):void
			{
				if (_framerate != f)
				{
					send(BOARD, SET, FRAMERATE, f);
					_framerate = f; 
				}
			}
			
		public function Arduino(framerate:int, autoconnect:Boolean = true)
		{
			_framerate = framerate;
			
			socket = new Socket();
			if (autoconnect) { connect(); }
		}
		
		public function connect(port:int = 5331, host:String = 'localhost'):void
		{
			if (!socket.connected)
			{
				socket.addEventListener(Event.CONNECT, onconnect);
				socket.addEventListener(ProgressEvent.SOCKET_DATA, ondata);
				socket.connect(host, port);	
			}
		}
		
		private function onconnect(e:Event):void
		{
			socket.removeEventListener(Event.CONNECT, onconnect);
			setTimeout(exec(tell, CONNECTED), 1000);
		}
		
		private function ondata(e:ProgressEvent):void
		{			
			var header:int = socket.readShort();

			if (header == DEBUG_WATERMARK)
			{
				trace(socket.readUTFBytes(socket.bytesAvailable - 1));
				socket.readUTFBytes(socket.bytesAvailable);
			}
			else if (header == WATERMARK)
			{
				var subject:int = socket.readShort(),
					command:int = socket.readShort(),
					property:int = socket.readShort(),
					value:int = socket.readInt();
				
				trace('s:', subject);
				trace('c:', command);
				trace('p:', property);
				trace('v:', value);
			}
			else { 	trace('unknown watermark:', header); }
		}
		
		public function send(subject:int, command:int, property:int, ...args):void
		{
			if (_debug) { trace(subject, command, property, args.toString()); }
			
			socket.writeShort(WATERMARK);
			socket.writeShort(subject);
			socket.writeShort(command);
			socket.writeShort(property);

			for each(var arg:* in args) { socket.writeInt(arg); }

			socket.flush();
		}
		
		public function tell(type:String):void { dispatchEvent(new Event(type)); }
	}
}
