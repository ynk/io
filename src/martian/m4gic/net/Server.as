package martian.m4gic.net
{
/*	import flash.display.Loader;
	import flash.display.LoaderInfo;
	
	import flash.errors.IOError;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.events.ServerSocketConnectEvent;
	
	import flash.net.ServerSocket;
	import flash.net.Socket;
	
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import martian.ev3nts.Evnt;
	import martian.m4gic.data.Ini;
	import martian.m4gic.tools.Arrays;
	import martian.m4gic.tools.Domain;
*/	
	
	public class Server// extends EventDispatcher 
	{
/*		static public var log:Function = function(...args):void { trace.apply(null, args);  };
		
		static private var UID:int = 1;
		
		static public const BROADCAST:String = 'serverBroadcast';
		static public const NOTIFY:String = 'serverNotify';
		
		private var server:ServerSocket, buffer:ByteArray = new ByteArray();
		
		public var port:int, ip:String, debug:Boolean = false;
		
		protected var length:int = 0;
		protected var clients:Dictionary;
		
		private var handler:Handler;
		
		protected function id(socket:Socket):uint
		{
			for (var uid:* in clients) { if (socket == clients[uid]) { return uid; } }
			return 0;
		}
		
		public function Server(port:int = 8888, ip:String = '0.0.0.0')
		{
			this.server = new ServerSocket();
			this.clients = new Dictionary();
			
			this.port = port;
			this.ip = ip;
		}
		
		final public function listen():Boolean
		{
			if (server.listening) { return false; }
			
			server = new ServerSocket();
				server.addEventListener(ServerSocketConnectEvent.CONNECT, onconnect);
			
			clients = new Dictionary();
			
			try
			{
				server.bind(port, ip);
				server.listen();
			}
			catch (e:IOError)
			{
				server.removeEventListener(ServerSocketConnectEvent.CONNECT, onconnect);
				return false;
			}
			
			return true;
		}
		
		final public function kill():Boolean
		{
			if (!server.listening) { return false; }
			
			server.removeEventListener(ServerSocketConnectEvent.CONNECT, onconnect);
				
			var packet:Packet = new Packet();
				packet.type = Packet.CLOSE;
				packet.sender = 0;
			
			broadcast(packet.bytearray);
			server.close();
			
			return true;
		}
		
		private function onconnect(e:ServerSocketConnectEvent):void 
		{
			e.socket.addEventListener(ProgressEvent.SOCKET_DATA, ondata, false, 0, true);
			e.socket.addEventListener(Event.CLOSE, onclose, false, 0, true);
		}
		
		private function ondata(e:ProgressEvent):void 
		{
			Server.log('bytes received :', e.bytesLoaded);
			
			(e.target as Socket).readBytes(buffer);
			if (e.bytesLoaded < Packet.BUFFER_MAX_SIZE) { read(e.target as Socket); }
			else { log('Packet part received'); }
		}
		
		private function read(socket:Socket):void
		{
			Server.log('--- reading packet');
			
			var packet:Packet = Packet.dump(buffer);
				if (packet == null) { return; }
				
			packet.sender = id(socket);
				
			if (handler)
			{
				if (handler.type == null || Arrays.contains(handler.type, packet.type) != -1)
				{
					packet = handler.handle(packet, socket);
					if (packet == null) { return; }
				}
			}
			
			switch(packet.type)
			{
				case Packet.INVALID:
					return;
				
				case Packet.POLICY:
					notify(socket, Packet.policyfile(port));
					return;
				
				case Packet.HANDSHAKE:
					if (id(socket) != 0) { return; }
					
					var answer:Packet = new Packet();
						answer.type = Packet.HANDSHAKE;
						answer.target = UID;
						answer.data = packet.data;
						
					notify(socket, answer.bytearray);
					
					var inform:Packet = new Packet();
						inform.type = Packet.FRIEND_COME;
						inform.sender = UID;
						
					broadcast(inform.bytearray, socket);
					clients[UID++] = socket;
					return;
					
				case Packet.FRIEND_COME:
				case Packet.FRIEND_QUIT:
					return;
					
				case Packet.BROADCAST:
					broadcast(packet.bytearray, socket);
					return;
					
				case Packet.NOTIFICATION:
					notify(packet.target, packet.bytearray);
					return;
					
				default:
					if (packet.parent == Packet.BROADCAST) { broadcast(packet.bytearray, socket); }
					else if (packet.parent == Packet.NOTIFICATION) { notify(packet.target, packet.bytearray); }
					else { handle(packet.bytearray, socket); }
					return;
			}
			
			buffer = new ByteArray();
		}
		
		protected function handle(bytearray:ByteArray, sender:Socket):void {}
		
		private function onhandler(e:Evnt):void
		{
			var ini:Ini = new Ini(e.data),
				data:ByteArray = ini.cast('data', ByteArray, new Error('invalid event data'));
			
			switch(e.type)
			{
				case BROADCAST:
					var except:Socket = ini.cast('except', Socket);
					broadcast(data, except);
					break;
				
				case NOTIFY:
					var target:* = ini.star('target', new Error('invalid event target'));
					notify(target, data);
					break;
			}
		}
		
		private function onclose(e:Event):void
		{
			for(var uid:* in clients)
			{
				if (e.target == clients[uid])
				{
					delete clients[uid];
					
					var packet:Packet = new Packet();
						packet.type = Packet.FRIEND_QUIT;
						packet.sender = uid;
						
					broadcast(packet.bytearray);	
					return;
				}
			}
		}
		
		final public function broadcast(data:ByteArray, except:Socket = null):void
		{
			for each(var client:Socket in clients) { if (client != except) { send(client, data); } }
		}
		
		final public function notify(target:*, data:ByteArray):void
		{
			if (target is int) { target = clients[target]; }
			if (!(target is Socket)) { return; }
			
			send(target, data);
		}
		
		private function send(socket:Socket, data:ByteArray):void
		{
			var tmp:ByteArray;
				
			Server.log(data.bytesAvailable, data.bytesAvailable % Packet.BUFFER_MAX_SIZE);
				
			do
			{
				tmp = new ByteArray();
					data.readBytes(tmp, 0, Packet.BUFFER_MAX_SIZE < data.bytesAvailable ? Packet.BUFFER_MAX_SIZE : data.bytesAvailable);
					tmp.position = 0;
					
				socket.writeBytes(tmp);
				socket.flush();
			}
			while (data.bytesAvailable > 0)
		}
		
		final public function plugin(bytearray:ByteArray):void
		{
			var context:LoaderContext = new LoaderContext();
				context.applicationDomain = ApplicationDomain.currentDomain;
				context.allowLoadBytesCodeExecution = true;
				context.allowCodeImport = true;
				
			var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onload);
				loader.loadBytes(bytearray, context);
		}
		
		private function onload(e:Event):void 
		{
			var loaderinfo:LoaderInfo = e.target as LoaderInfo,
				target:* = loaderinfo.content;
				
			loaderinfo.removeEventListener(Event.COMPLETE, onload);	
			
			if (Domain.implementing(target, Handler))
			{
				handler = target as Handler;
					handler.addEventListener(Event.INIT, oninit);
					handler.init();
				
				log('--- plugin loaded : ', handler.name);
				log('--- handles messages type : ', handler.type ? handler.type.toString() : 'all');
			}
			else
			{
				log('--- invalid plugin');
				loaderinfo.loader.unloadAndStop();
			}
		}
		
		public function oninit(e:Event):void
		{
			handler.log = Server.log as Function;
		}
*/	}
}