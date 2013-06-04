package martian.ev3nts.helpers 
{
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	
	public class evnt 
	{
		static private var data:Object = new Object();
		
		static public function any(dispatchers:*, event:String, method:Function, ...parameters):Object
		{
			if (dispatchers is IEventDispatcher) { dispatchers = [dispatchers]; }
			
			for each(var dispatcher:IEventDispatcher in dispatchers)
			{
				if (!data[dispatcher]) { data[dispatcher] = new Array(); }
				
				var proxy:Proxy = new Proxy();
					proxy.parameters = parameters;
					proxy.method = method;
					proxy.event = event;
					proxy.times = -1;
					
				data[dispatcher].push(proxy);
				
				if (dispatcher is Sprite && (event == MouseEvent.CLICK || event == MouseEvent.MOUSE_OVER || event == MouseEvent.ROLL_OVER)) { (dispatcher as Sprite).buttonMode = true; }
				
				dispatcher.addEventListener(event, handler);
			}
			
			return dispatchers.length != 1 ? dispatchers : dispatchers[0];
		}
		
		static public function once(dispatcher:IEventDispatcher, event:String, method:Function, ...parameters):Object
		{
			if (!data[dispatcher]) { data[dispatcher] = new Array(); }
			
			var proxy:Proxy = new Proxy();
				proxy.parameters = parameters;
				proxy.method = method;
				proxy.event = event;
				proxy.times = 1;
				
			data[dispatcher].push(proxy);
			
			if (dispatcher is Sprite && (event == MouseEvent.CLICK || event == MouseEvent.MOUSE_OVER || event == MouseEvent.ROLL_OVER)) { (dispatcher as Sprite).buttonMode = true; }
			
			dispatcher.addEventListener(event, handler);
			
			return dispatcher as Object;
		}
		
		static public function cancel(dispatchers:*, events:* = null, method:Function = null):void
		{
			if (dispatchers is IEventDispatcher) { dispatchers 	= [dispatchers]; }
			
			if (!events) 					 	 { events 		= new Array(); }
			else if (events is String) 			 { events 		= [events]; }
			else if (events is Function)
			{
				method		= events;
				events 		= new Array();
			}
			
			var i:int = 0, j:int = events.length, k:int, l:int;
			
			for each(var dispatcher:IEventDispatcher in dispatchers)
			{
				if (!data[dispatcher]) { continue; }
				
				k = 0; l = data[dispatcher].length;
				
				if (events.length == 0)
				{
					for (k = 0, l; k < l; k++)	{ dispatcher.removeEventListener(data[dispatcher][k].event, handler); }
					delete data[dispatcher];
					
					return;
				}
				
				if (method == null)
				{
					for (i; i < j; i++) 
					{
						for (k; k < l; k++)
						{
							if (data[dispatcher][k].event == events[i])
							{
								data[dispatcher].splice(i, 1);
								break;
							}
						}
					}
				}
				else
				{
					for (i; i < j; i++) 
					{
						for (k; k < l; k++)
						{
							if (data[dispatcher][k].event == events[i] && data[dispatcher][k].method == method)
							{
								data[dispatcher].splice(i, 1);
								break;
							}
						}
					}
				}
			}
		}
		
		static private function handler(e:* = null):void
		{
			var proxies:Array = new Array(), i:int = 0, j:int = data[e.target].length;
			for (i; i < j; i++) { if (data[e.target][i].event == e.type) { proxies.push(data[e.target][i]); } }
			
			for each(var proxy:Proxy in proxies)
			{
				if (proxy.parameters.length > 0)
				{
					try { proxy.method.apply(null, new Array(e).concat(proxy.parameters)); }
					catch (x:Error) { proxy.method.apply(null, proxy.parameters); }
				}
				else
				{
					try { proxy.method.call(null, e); }
					catch (x:Error) { proxy.method.call(); }
				}
				
				if (--proxy.times == 0) { evnt.cancel(e.target, e.type, proxy.method); }
			}
		}
	}
}

internal class Proxy
{
	public var event:String;
	public var method:Function;
	public var parameters:Array;
	public var times:int;
	
	public function Proxy() {}
}