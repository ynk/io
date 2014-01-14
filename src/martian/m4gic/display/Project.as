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

package martian.m4gic.display
{

	import flash.display.*;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.Font;
	
	import martian.ev3nts.helpers.on;
	import martian.m4gic.log;
	import martian.m4gic.data.Ini;
	
	public class Project extends MovieClip
	{
		static public var URI:String = '.';
		static public var DEBUG:Boolean = false;
		static public var WIDTH:int = -1;
		static public var HEIGHT:int = -1;
		
		static private const QUALITY:Array = [StageQuality.LOW, StageQuality.MEDIUM, StageQuality.HIGH, StageQuality.BEST];
		static private const ALIGN:Array = [StageAlign.TOP_LEFT, StageAlign.TOP, StageAlign.TOP_RIGHT, StageAlign.LEFT, StageAlign.RIGHT, StageAlign.BOTTOM_LEFT, StageAlign.BOTTOM, StageAlign.BOTTOM_RIGHT];
		static private const SCALE:Array = [StageScaleMode.NO_SCALE, StageScaleMode.EXACT_FIT, StageScaleMode.NO_BORDER, StageScaleMode.SHOW_ALL];
		
		static public var STAGE:Stage;
		static public var INFOS:LoaderInfo;
		
		static public function get fonts():String
		{
			var fonts:Array = Font.enumerateFonts();
				for (var i:int = 0; i < fonts.length; i++) { fonts[i] = fonts[i].fontName; }
				
			return fonts.toString();
		}
		
		/**
		 * Just a very small shortcut to a project class
		 * call super() first, and then override the initialize function to get a well set stage
		 * it extends movieclip because it's meant to be used with the Frame metatag
		 */
		
		public function Project(config:Object = null)
		{
			if (Ini.extract(config, 'resizable', Boolean, true))
			{
				on(this, Event.ADDED_TO_STAGE, onadded);
				on(this, Event.REMOVED_FROM_STAGE, onremoved);
			}
			
			on(this, Event.ADDED_TO_STAGE, setup, config);
		}
		
		private function setup(config:Object):void
		{
			stop();
			STAGE = stage;
			INFOS = stage.loaderInfo;
			
			var ini:Ini = new Ini(config);
				stage.quality = QUALITY[ini.integer('quality', 2)];
				stage.align = ALIGN[ini.integer('align', 0)];
				stage.scaleMode = SCALE[ini.integer('scale', 0)];
				stage.frameRate = ini.integer('framerate', 60);
				
				DEBUG = ini.boolean('debug', (loaderInfo.url.indexOf('file://') != -1));
			
			WIDTH = ini.integer('width', stage.stageWidth);	
			HEIGHT = ini.integer('height', stage.stageHeight);	
			
			if (ini.boolean('frame')) { scrollRect = new Rectangle(0, 0, WIDTH, HEIGHT); }
			
			if (ini.star('log')) { log('*** startup log:', ini.star('log')); }
			
			if (DEBUG)
			{
				log('Project dimension:', WIDTH, 'x', HEIGHT);
				log('Project URI:', URI);
				log('Available fonts:', fonts);
			}
			
			ini.dispose();
			
			initialize();
		}
		
		protected function initialize():void { throw new Error('You need to overwrite initialize method'); }

		public function dispose():void {}
		public function resize():void {}
		
		private function onadded():void { stage.addEventListener(Event.RESIZE, onresize); }
		private function onremoved():void { stage.removeEventListener(Event.RESIZE, onresize); }
		private function onresize(e:Event):void { resize(); }
	}
}