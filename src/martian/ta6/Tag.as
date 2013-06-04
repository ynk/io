package martian.ta6 
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import martian.ev3nts.helpers.on;
	import martian.m4gic.log;
	import martian.m4gic.open;
	import martian.t1me.data.Load;
	import martian.t1me.interfaces.Stackable;
	import martian.t1me.trigger.Call;
	
	import martian.daem0n.core.Daemon;
	
	public class Tag extends Daemon 
	{
		static public const READY:String = "trackReady";
		static public const CONFIG:String = "trackConfig";
		
		
		static public var DEBUG:Boolean = true;
		static private var callback:Boolean = false;
		
		static public var ID:String = "";
		static private function SOLVE(stage:Stage):void
		{
			if (!ExternalInterface.available)
			{
				if (DEBUG) { return; }
				log("Tags: no javascript in there");
				return;
			}
			
			var script:String = "";
				script += "var objects = document.getElementsByTagName('object');";
				script += "for (var i = 0; i < objects.length; i++) { if (objects[i].data == '" + stage.loaderInfo.url + "') { return objects[i].id || 'flash'; } }";
				script += "var embeds = document.getElementsByTagName('embed');";
				script += "for (var j = 0; j < embeds.length; j++) { if (embeds[j].src == '" + stage.loaderInfo.url + "') { return embeds[j].id || 'flash'; } }";
				script += "return 'flash';";
				
			ID = ExternalInterface.call("function() { " + script + " }");
		}
		
		
		private var tags:Dictionary,
					type:String;
		
		public function Tag()
		{
			name = "Tag";
			
			if (DEBUG && !callback)
			{
				callback = true;
				
				if (ExternalInterface.available)
				{
					ExternalInterface.addCallback('_call', call);
					ExternalInterface.addCallback('_eval', eval);
				}
			}
		}
		
		public function hook(stage:Stage, parameters:Object):void
		{
			if (!$hook(stage)) { return; }
			
			if (parameters.debug === true) { DEBUG = true; }
			
			if (parameters.type != undefined)
			{
				switch(parameters.type)
				{
					case "request":
						type = "request";
						break;
						
					case "js":
						type = "js";
						if (ID == "") { SOLVE(stage); }
						break;
					
					default:
						log("unsupported tracker type :", parameters.type);
						$kill();
						break;
				}
			}
		}
		
		public function dictionary(arg:*):Stackable
		{
			if (arg is String || arg is URLRequest)
			{
				var load:Load = new Load(arg, Load.TEXT);
					on(load, Event.COMPLETE, parse);
					
				return load;
			}
			
			if (arg is XML)
			{
				parse(arg);
				return new Call(null);
			}
			
			return null;
		}
		
		private function onconfig(e:Event):void { parse(new XML(e.target.data)); }
		
		private function parse(xml:XML):void
		{
			tags = new Dictionary();
			for each(var child:XML in xml.children()) { tags[String(child.name())] = String(child.valueOf()); }
				
			tell(CONFIG);
		}
		
		//doesnt work :(
		final protected function script(url:String):void
		{
			if (ExternalInterface.available)
			{
				var scriptname:String = "script_" + int(Math.random() * 0xfff).toString(16);
				
				ExternalInterface.addCallback(scriptname + "_onload", onload);
				
				var code:String = "/* ! */ var bodytag = document.getElementsByTagName('body')[0];";
					code += "var " + scriptname + " = document.createElement('script');";
					code += scriptname + ".type = 'text/javascript';";
					//code += scriptname + ".onload = document['" + ID + "']." + scriptname + "_onload;";
					code += scriptname + ".src = '" + url + "';";
					code += "bodytag.appendChild(" + scriptname + ");";
					
				call(code);
			}
		}
		
		//doesnt work :(
		final protected function noscript(url:String):void
		{
			if (ExternalInterface.available)
			{
				var scriptname:String = "script_" + int(Math.random() * 0xfff).toString(16);
				
				ExternalInterface.addCallback(scriptname + "_onload", onload);
				
				var code:String = "var bodytag = document.getElementsByTagName('body')[0];";
					code += "var " + scriptname + " = document.createElement('image');";
					code += scriptname + ".width = 1;";
					code += scriptname + ".height = 1;";
					code += scriptname + ".alt = '';";
					//code += scriptname + ".onload = document['" + ID + "']." + scriptname + "_onload;";
					code += scriptname + ".src = '" + url + "';";
					code += "bodytag.appendChild(" + scriptname + ");";
					
				call(code);
			}
		}
		
		protected function onload():void { tell(READY); }
		
		protected function prepare(type:String):String	{ throw new Error("you must override the prepare method with the track string, and put {code} marker in it"); }
		
		public function track(code:String, type:String):void
		{
			if (tags != null && tags[code] != undefined) { code = tags[code]; }
			
			var query:String = prepare(type);
				if (query.indexOf("{code}") == -1) { throw new Error("invalid prepare() string, use the {code} marker to properly insert your tag"); }
				query = query.replace("{code}", code);
				
			if (DEBUG) { log("xiti:", query); }	
				
			switch(this.type)
			{
				case "request":
					open(query, "");
					break;
					
				case "js":
					call(query);
					break;
			}
		}
		
		protected function call(code:String):*
		{
			//ExternalInterface.call('function() {}'); fucks up in js
			return eval(code); //hotfix
			
			code = code.split('"').join("'");
			log("JS call", code);
			
			if (ExternalInterface.available) { return ExternalInterface.call("eval", "(function() { " + code + " })();"); }
			return null;
		}
		
		protected function eval(code:String):*
		{
			code = code.split('"').join("'");
			
			log("JS eval", code);
			if (ExternalInterface.available) { return ExternalInterface.call("eval",  code); }
			return null;
		}
		
		protected function quote(str:String):String { return '"' + str + '"'; }
	}
}