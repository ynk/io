package martian.ta6 
{
	import flash.display.Stage;
	import martian.m4gic.data.Ini;
	import martian.m4gic.log;
	public class Omniture extends Tag 
	{
		private var properties:Object = new Object();
		
		public function Omniture() 
		{
			super();
			name = 'Omniture';
		}
		
		override public function hook(stage:Stage, parameters:Object):void 
		{
			var ini:Ini = new Ini(parameters);
				
			var url:String = ini.string('script', new Error('script parameter is required'));
				
			//script(url);
				delete parameters.script;
			
			var fallback:String = ini.string('noscript');
				if (fallback.length != 0)
				{
					//noscript(fallback);
					delete parameters.noscript;
				}
				
			for (var property:* in parameters)
			{
				eval('s.' + property + ' = ' + parameters[property]);
				if ((property as String).indexOf('{code}') != -1) { properties[property] = parameters[property]; }
			}
				
			super.hook(stage, { type:'js' });
		}
		
		override protected function prepare(type:String):String 
		{
			var string:String = 's.pageName = "{code}";';
				for (var property:* in properties) { string += 's.' + property + ' = ' + properties[property] + ';' }
			
			string += 'var s_code = s.t();';
			string += 'if (s_code) { document.write(s_code); }';
			
			log(string);
			
			return string;
		}
		
		public function page(code:String):void 
		{
			track(code, 'page');
		}
	}
}