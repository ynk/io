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

package martian.t1me.data
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	import flash.net.Responder;
	
	import martian.t1me.interfaces.Stackable;
	import martian.t1me.misc.Time;
	
	public class Message extends EventDispatcher implements Stackable
	{
		static public var GATEWAY:String = "http://localhost/_amf/gateway.php";
		static public var DEBUG:Boolean = true;
		
		static private var cnx:NetConnection;
		static private var rsp:Responder;
			static private function connect():void
			{
				cnx = new NetConnection();
					cnx.objectEncoding = ObjectEncoding.AMF0;
					cnx.addEventListener(NetStatusEvent.NET_STATUS, status);
					cnx.connect(GATEWAY);
			}
			
			static private function status(e:NetStatusEvent):void { if (DEBUG) { trace(e.info.code); } }
		
		public var f:String;
		public var a:Array;
		
		private var rsp:Responder;
		
		private var raw:*;
			public function get data():Object { return raw; }
			
		public function Message(method:String, ...parameters)
		{
			if (!cnx) { connect(); }
			
			f = method;
			a = parameters;
			
			rsp = new Responder(success, failure);
		}
		
		public function send():void { start(); }
		
		public function start():void
		{
			cnx.call.apply(null, new Array(f, rsp).concat(a));
			dispatchEvent(new Event(Time.START));
		}
		
		private function success(arg:Object):void
		{
			raw = arg;
			
			dispatchEvent(new Event(Event.COMPLETE));
			dispatchEvent(new Event(Time.STOP));
		}
		
		private function failure(arg:Object):void
		{
			raw = arg;
			
			dispatchEvent(new Event(Event.CANCEL));
			dispatchEvent(new Event(Time.STOP));
		}
		
		public function dispose():void { raw = null; }
	}
}