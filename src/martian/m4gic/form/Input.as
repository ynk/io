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

package martian.m4gic.form
{
	import flash.events.KeyboardEvent;
	import flash.events.FocusEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class Input extends EventDispatcher implements Field
	{
		static public const ALPHABETIC:Validator		= new Validator(new RegExp("[a-zA-Z\\s]+", "g"), "a-z A-Z"),
							NUMERIC:Validator			= new Validator(new RegExp("[0-9]+", "g"), "0-9"),
							ALPHANUMERIC:Validator		= new Validator(new RegExp("[a-zA-Z\\s0-9]+", "g"), "a-z A-Z 0-9"),
							FRENCH_ALPHA:Validator		= new Validator(new RegExp("[a-zA-Zàéèêëïôùç\\-',\\s]+", "g"), "a-z A-Z \\-', àéèêëïôùç"),
							FRENCH_ALPHANUM:Validator	= new Validator(new RegExp("[a-zA-Z0-9àéèêëïôùç\\-',\\s]+", "g"), "a-z A-Z 0-9 \\-', àéèêëïôùç"),
							EMAIL:Validator				= new Validator(new RegExp("^(([a-zA-Z0-9\\._\\-]+)@([a-zA-Z0-9-]+)\\.([a-zA-Z]{2,4}))$", "g"), "a-z0-9\\-_@."),
							LOGIN:Validator				= new Validator(new RegExp("^[a-z0-9\\-\\._]+$", "g"), "a-z0-9\\-._"),
							PASSWORD:Validator			= new Validator(new RegExp("^[a-zA-Z\\s0-9]+$", "g"), "a-z A-Z 0-9"),
							PHONE:Validator				= new Validator(new RegExp("^(0[0-9]{1})([0-9]{2}){4}$", "g"), "0-9"),
							MOBILE:Validator			= new Validator(new RegExp("^(0[67])([0-9]{2}){4}$", "g"), "0-9"),
							ZIPCODE:Validator			= new Validator(new RegExp("^[0-9]{5}$", "g"), "0-9");
		
		
		
		
		public function get asset():Object { return tf; }
		
		private var n:String;
			public function get name():String { return n; }
			public function set name(s:String):void { n = s; }
		
		public function get index():int { return tf.tabIndex; }
		public function set index(i:int):void
		{
			tf.tabIndex = i;
			tell(Event.TAB_INDEX_CHANGE);
		}
		
		public function get next():int { return tf.tabIndex + 1; }
		
		public function get value():Object { return tf.text; }
		public function set value(o:Object):void
		{
			tf.text = o;
			tell(Event.CHANGE);
		}
		
		public var	tf:Object,
					default_value:String,
					validator:Validator,
					mandatory:Boolean = true;
		
		public function Input(tf:Object, validator:Validator, mandatory:* = null, min:Number = NaN, max:Number = NaN)
		{
			this.tf = tf;
			this.validator = validator;
			
			this.index = -1;

			if (mandatory === true || mandatory === false) { this.mandatory = mandatory; }
			if (!isNaN(min)) { this.validator.min = int(min); }
			if (!isNaN(max)) { this.validator.max = int(max); }
			
			this.n = tf.name;
			
			init();
		}

		private function init():void
		{
			default_value = tf.text;
			tf.type = 'input';
			tf.tabIndex = 0;
			
			tf.restrict = validator.restrict;
			tf.displayAsPassword = (validator == PASSWORD);
			if (validator.max >= validator.min) { tf.maxChars = validator.max; }
			
			tf.addEventListener(Event.CHANGE, onchange, false, 0, true);
			tf.addEventListener(FocusEvent.FOCUS_IN, onfocusin, false, 0, true);
			tf.addEventListener(FocusEvent.FOCUS_OUT, onfocusout, false, 0, true);
			tf.addEventListener(KeyboardEvent.KEY_DOWN, onkeydown, true, 0, true);
			
			tell(Event.CHANGE);
		}

		public function validate():Boolean
		{
			if (tf.text === default_value) { tf.text = ''; }
			var test:Boolean = (validator.test != null) ? validator.test.call(null, tf.text) : true;
			
			return test && !((tf.text != "" || mandatory) && (tf.text.search(validator.regex) == -1 || tf.text.length < validator.min));
		}

		private function onchange(e:Event):void { tell(Event.CHANGE); }
		
		private function onfocusin(e:FocusEvent):void
		{
			if (tf.text === default_value) { tf.text = ''; }
			
			tf.setSelection(0, tf.length);
			tell(Event.CHANGE);
		}
		
		private function onfocusout(e:FocusEvent):void
		{
			if (tf.text.length == 0) { tf.text = default_value; }
			else { tf.text = trim(tf.text); }
			
			tell(Event.CHANGE);
		}
		
		private function onkeydown(e:KeyboardEvent):void { tell(Event.CHANGE); }
		
		private function trim(str:String):String
		{
			var rst:String = str;
				rst = rst.replace(new RegExp('^\\s+'), '');
				rst = rst.replace(new RegExp('\\s+$'), '');
				rst = rst.replace(new RegExp('\\s+'), ' ');
			
			return rst;				
		}
		
		private function tell(type:String):void { dispatchEvent(new Event(type)); }
	}
}