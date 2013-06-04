package martian.m4gic.net 
{
	import flash.events.IEventDispatcher;
	import flash.net.Socket;
	
	public interface Handler extends IEventDispatcher
	{
		function get name():String;
		function get type():Array;
		
		function set log(callback:Function):void;
		
		function init():void;
		function handle(packet:Packet, sender:Socket):Packet;
	}	
}