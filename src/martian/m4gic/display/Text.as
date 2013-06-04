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
	import flash.text.AntiAliasType;
	import flash.display.Sprite;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import martian.m4gic.log;
	
	import flash.events.Event;
	
	import flash.text.StyleSheet;
	import flash.text.TextField;
	
	import martian.t1me.data.Load;
	
	public class Text extends Sprite 
	{
		static public var EMBED:Boolean = true;
		
		static private var css:StyleSheet;
		
		static private var loading:Boolean = false;
		static private var tmp:Array;
		
		static public function stylesheet(data:String):Load
		{
			css = new StyleSheet();
			
			var external:Boolean = data.indexOf('.css') != -1;
			
			if (!external)
			{
				css.parseCSS(data);
				trace(css.styleNames);
				return null;
			}
			
			loading = true;
			
			var load:Load = new Load(data, Load.TEXT);
				load.addEventListener(Event.COMPLETE, parse);
				
			return load;
		}
		
		static private function parse(e:Event):void
		{
			e.target.removeEventListener(Event.COMPLETE, parse);
			
			css.parseCSS(e.target.data);
			trace(css.styleNames);
			
			loading = false;
			
			if (!tmp) { return; }
				for each(var process:Object in tmp) { stylize(process.tf, process.classname, process.overwrite); }
				tmp = null;
		}
		
		static public function stylize(tf:TextField, classname:String = '', overwrite:Object = null):void
		{
			if (loading)
			{
				if (!tmp) { tmp = new Array(); }
				tmp.push( { tf:tf, classname:classname, overwrite:overwrite } );
				return;
			}
			
			if (overwrite)
			{
				var format:TextFormat = tf.getTextFormat();
				
				for (var key:* in overwrite)
				{					
					if (key in tf) { tf[key] = overwrite[key]; }
					if (format && key in format) { format[key] = overwrite[key]; }
				}
				
				if (format) { tf.setTextFormat(format); }
			}
			
			if (tf.type === TextFieldType.INPUT)
			{
				tf.parent.mouseChildren = true;
				
				tf.mouseEnabled = true;
				tf.tabEnabled = true;
				tf.selectable = true;
			}
			
			tf.styleSheet = css;
		}
		
		protected var tf:TextField = addChild(new TextField()) as TextField;
		private var style:String;
			
		public function Text(text:String, classname:String = '', overwrite:Object = null) 
		{
			mouseChildren = false;
			
			tf.x = -4;
			tf.y = -2;
			
			tf.wordWrap = false;
			tf.multiline = false;
			tf.autoSize = 'left';
			tf.selectable = false;
			tf.antiAliasType = AntiAliasType.ADVANCED;
			
			tf.name = 'tf';
			tf.embedFonts = EMBED;
			tf.tabEnabled = false;
			tf.mouseEnabled = false;
			tf.mouseWheelEnabled = false;
			tf.setTextFormat(new TextFormat());
			
			style = classname;
			if (style != '' || overwrite) { Text.stylize(tf, style, overwrite); }
			
			this.text = text;
		}
		
		public function get text():String { return tf.htmlText; }
		public function set text(value:String):void
		{
			if (style != '') { tf.htmlText = '<p class="' + style + '">' + value + '</p>'; }
			else { tf.htmlText = value; }
		}
		
		public function get classname():String { return style; }
		public function set classname(s:String):void
		{
			style = classname;
			if (style != '') { Text.stylize(tf, style); }
		}
		
		public function stylize(object:Object):void { Text.stylize(tf, '', object); }
		
		public function debug():void { tf.border = true; tf.borderColor = 0xFF0000; }
		
		override public function get width():Number { return int(tf.textWidth); }
		override public function set width(value:Number):void { tf.width = value; }
		
		override public function get height():Number { return int(tf.textHeight); }
		override public function set height(value:Number):void  { tf.height = value; }
	}
}