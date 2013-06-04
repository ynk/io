package martian.m4gic.net 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.system.Security;
	import flash.utils.ByteArray;
	
	public class Client extends EventDispatcher 
	{
		static public const	CONNECTED:String = "clientConnected";
		static public const	DISCONNECTED:String = "clientDisconnected";
		static public const	FRIEND_CONNECTED:String = "friendConnected";
		static public const	FRIEND_DISCONNECTED:String = "friendDisconnected";
		static public const	DATA_RECEIVED:String = "dataReceived";
		
		private var socket:Socket,
					buffer:ByteArray = new ByteArray(),
					buffering:Boolean = false, length:uint = 0;
		
		private var uid:uint = NaN;
			public function get id():uint { return uid; }
			
		protected var packet:Packet;
			public function get data():Object { return packet ? { sender:packet.sender, type:packet.type, content:packet.data } : null; }
			
		public var debug:Boolean = false;	
			
		public function get connected():Boolean { return !isNaN(uid); }
			
		public function Client(debug:Boolean = false)
		{
			this.socket = new Socket();
			this.debug = debug;
		}
		
		final public function connect(port:int, ip:String = '127.0.0.1'):void
		{
			Security.loadPolicyFile("xmlsocket://" + ip + ":" + port);
			
			socket = new Socket();
				socket.addEventListener(Event.CONNECT, onconnect);
				socket.addEventListener(IOErrorEvent.IO_ERROR, onerror);
				socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onerror);
				socket.addEventListener(ProgressEvent.SOCKET_DATA, ondata);
				socket.addEventListener(Event.CLOSE, onclose);
				socket.connect(ip, port);
		}
		
		private function onerror(e:Event):void {}
		
		private function onconnect(e:Event):void 
		{
			var packet:Packet = new Packet();
				packet.type = Packet.HANDSHAKE;
			
			send(packet.bytearray);
		}
		
		private function onclose(e:Event):void { tell(Client.DISCONNECTED); }
		
		private function ondata(e:ProgressEvent):void 
		{
			if (!buffering)
			{
				buffering = true;
				length = (e.target as Socket).readUnsignedInt();
			}
			
			(e.target as Socket).readBytes(buffer);
			if (buffering && length == buffer.length) { read(e.target as Socket); }
		}
		
		private function read(socket:Socket):void
		{	
			packet = Packet.dump(buffer, debug);
				if (packet == null) { return; }
			
			switch(packet.type)
			{
				case Packet.HANDSHAKE:
					uid = packet.target;
					packet.sender = NaN;
					
					tell(Client.CONNECTED);
					return;
					
				case Packet.FRIEND_COME:
					tell(Client.FRIEND_CONNECTED);
					return;
				
				case Packet.FRIEND_QUIT:
					tell(Client.FRIEND_DISCONNECTED);
					return;
					
				case Packet.BROADCAST:
				case Packet.NOTIFICATION:
					tell(Client.DATA_RECEIVED);
					return;	
					
				default:
					packet = handle(packet);
					tell(Client.DATA_RECEIVED);
					return;
			}
			
			buffer = new ByteArray();
		}
		
		final public function broadcast(data:Object):void
		{
			var packet:Packet = new Packet();
				packet.type = Packet.BROADCAST;
				packet.sender = uid;
				packet.target = int.MIN_VALUE;
				packet.data = data;
				
			send(packet.bytearray);	
		}
		
		final public function notify(id:uint, data:Object):void
		{
			var packet:Packet = new Packet();
				packet.type = Packet.NOTIFICATION;
				packet.sender = uid;
				packet.target = id;
				packet.data = data;
				
			send(packet.bytearray);
		}
		
		final public function raw(type:int, data:Object):void
		{
			var packet:Packet = new Packet();
				packet.type = type;
				packet.parent = Packet.RAW;
				packet.sender = uid;
				packet.target = int.MIN_VALUE;
				packet.data = data;
				
			send(packet.bytearray);
		}
		
		protected function send(data:ByteArray):void
		{
			var bytearray:ByteArray = new ByteArray();
				bytearray.writeUnsignedInt(data.length);
				bytearray.writeBytes(data);
				
			socket.writeBytes(bytearray);
			socket.flush();
		}
		
		protected function handle(packet:Packet):Packet { return packet; }
		
		private function tell(type:String):void { dispatchEvent(new Event(type)); }
	}
}