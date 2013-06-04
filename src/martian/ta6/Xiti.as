package martian.ta6 
{
	import flash.display.Stage;
	import flash.system.Capabilities;
	import martian.m4gic.data.Ini;
	
	public class Xiti extends Tag
	{
		private var subdomain:String,
					siteid:String,
					subsiteid:String = '',
					resolution:String = '';
		
		public function Xiti() 
		{
			super();
			name = 'Xiti';
		}
		
		override public function hook(stage:Stage, parameters:Object):void 
		{
			var ini:Ini = new Ini(parameters);
				this.subdomain = ini.string('subdomain', new Error('subdomain parameter is required'));
				this.siteid = ini.star('siteid', new Error('siteid parameter is required'));
				this.subsiteid = ini.star('subsiteid', new Error('subsiteid parameter is required'));
				
			Tag.DEBUG = ini.boolean('debug', false);
				
			this.resolution = Capabilities.screenResolutionX + 'x' + Capabilities.screenResolutionY + 'x' + eval('screen.pixelDepth') + 'x' + eval('screen.colorDepth');
			
			super.hook(stage, { type:'request' });
		}
		
		override protected function prepare(type:String):String
		{
			var now:Date = new Date();
			
			var string:String = subdomain + '.xiti.com/hit.xiti';
				string += '?s=' + siteid;
					if (subsiteid != '') { string += '&s2=' + subsiteid; }
				
				string += '&r=' + resolution;
				string += '&hl=' + now.getHours() + 'x' + now.getMinutes() + 'x' + now.getSeconds();
				
			switch(true)
			{
				case type.indexOf('click') != -1:
					string += 'clic=' + type.charAt(type.length - 1);
					
				case type == 'page':
					string += '&p={code}';
					break;
			}
			
			return string;
		}
		
		public function page(code:String):void { track(code, 'page'); }
		
		public function click_action(code:String):void { track(code, 'clickA'); }
		public function click_navigation(code:String):void { track(code, 'clickN'); }
		public function click_exit(code:String):void { track(code, 'clickS'); }
		public function click_download(code:String):void { track(code, 'clickT'); }
	}
}