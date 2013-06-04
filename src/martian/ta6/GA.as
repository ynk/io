package martian.ta6 
{
	import flash.display.Stage;
	import flash.system.Capabilities;
	import martian.m4gic.data.Ini;
	
	public class GA extends Tag 
	{
		private var account:String;
					
		public function GA() 
		{
			super();
			name = 'Google Analytics';
		}
		
		override public function hook(stage:Stage, parameters:Object):void 
		{
			var ini:Ini = new Ini(parameters);
				this.account = ini.string('account', new Error('account parameter is required'));
				
			Tag.DEBUG = ini.boolean('debug', false);
			
			eval('var _gaq = _gaq || [];');
			call('_gaq.push(["_setAccount", "' + account + '"]);');
			
			//script(ini.string('url', 'http://www.google-analytics.com/ga.js'));
			
			super.hook(stage, { type:'js' });
		}
		
		override protected function prepare(type:String):String 
		{
			var string:String = 'function() { % }';
			
			switch(type)
			{
				case 'page':
					string = '_gaq.push(["_trackPageview", {code}]);';
					break;
					
				case 'event':
					string = '_gaq.push(["_trackEvent", {code}]);';
					break;
					
				case 'social':
					string = '_gaq.push(["_trackSocial", {code}]);';
					break;
			}
				
			return string;
		}
		
		public function page(code:String):void { track('"' + code + '"', 'page'); }
		
		public function event(category:String, action:String, label:String = '', value:int = 0):void { track('"' + [category, action, label, value].join('","') + '"', 'event'); }
		
		public function social(network:String, action:String):void { track('"' + [network, action].join('","') + '"', 'social'); }
	}

}