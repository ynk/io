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

package martian.daem0n
{
	import flash.display.*;

	import flash.events.*;

	import flash.utils.Dictionary;

	import martian.daem0n.core.Daemon;

	public class Keyboard extends Daemon
	{
		public var DEBUG:Boolean = false;

		private var table:Dictionary;
		private var UID:uint = 0;
		private var binds:Dictionary;

		public function Keyboard() { name = "Keyboard"; }

		public function hook(stage:Stage, active:Boolean = true):void
		{
			if (!$hook(stage)) { return; }
			if (!table) { table = Keys.get(); }

			binds = new Dictionary();

			if (active) { activate(); }
		}

		public function kill():void
		{
			if (!$kill()) { return; }

			binds = null;
		}

		public function activate():void
		{
			if (!$activate()) { return; }

			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
		}

		public function deactivate():void
		{
			if (!$deactivate()) { return; }

			stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			stage.removeEventListener(KeyboardEvent.KEY_UP, keyUp);
		}

		private function keyDown(e:KeyboardEvent):void
		{
			if (table[e.keyCode] == undefined) { trace(e.keyCode); return; }

			if (!table[e.keyCode].pressed)
			{
				table[e.keyCode].pressed = true;
				for each(var bind:Bind in binds) { bind.push(table[e.keyCode].label); }
			}
		}

		private function keyUp(e:KeyboardEvent):void
		{
			if (table[e.keyCode] == undefined) { trace(e.keyCode); return; }

			if (table[e.keyCode].pressed)
			{
				table[e.keyCode].pressed = false;
				for each(var bind:Bind in binds) { bind.splice(table[e.keyCode].label); }
			}
		}

		public function press(key:String):Boolean
		{
			for each(var object:Object in table) { if (object.label == key) { return object.pressed; } }
			return undefined;
		}

		public function bind(...combo):Function
		{
			return function(callback:Function, time:int = 0):uint
			{
				binds[UID] = new Bind(Bind.GROUP, combo, callback, time);
				return UID++;
			}
		}



		public function sequence(...combo):Function
		{
			return function(callback:Function, time:int = 0):uint
			{
				binds[UID] = new Bind(Bind.SEQUENCE, combo, callback, time);
				return UID++;
			}
		}

		public function konami():Function
		{
			return function(callback:Function, time:int = 0):uint
			{
				binds[UID] = new Bind(Bind.SEQUENCE, ["up", "up", "down", "down", "left", "right", "b", "a", "enter"], callback, time);
				return UID++;
			}
		}

		public function unlink(callback:Function, id:uint = -1):void
		{
			if (id < 0)
			{
				for (var uid:* in binds)
				{ if (binds[uid].callback == callback) { binds[uid]; } }

				return;
			}

			delete binds[id];
		}
	}
}

// INTERNAL STUFF

import flash.system.Capabilities;
import flash.utils.clearTimeout;
import flash.utils.Dictionary;
import flash.utils.setTimeout;

internal class Bind
{
	static public const GROUP:int = 0;
	static public const SEQUENCE:int = 1;

	public var	type:int = -1,
				combo:Array,
				callback:Function,
				time:int;

	private var live:Array,
				index:int,
				timer:uint;

	public function Bind(type:int, combo:Array, callback:Function, time:int)
	{
		this.type = type;
		this.combo = combo;
		this.callback = callback;
		this.time = time;

		live = new Array(combo.length);
		index = 0;

		if (type == GROUP) { combo = combo.sort(); }
	}

	public function push(key:String):void
	{
		if (type == GROUP)
		{
			live[index++] = key;
			live = live.sort();

			validate();
		}
	}

	public function splice(key:String):void
	{
		if (type == GROUP)
		{
			for (var j:int = 0; j < live.length; j++)
			{
				if (key == live[j])
				{
					live.splice(j, 1);
					break;
				}
			}
		}

		if (type == SEQUENCE)
		{
			live[index++] = key;
			validate();
		}
	}

	private function validate():void
	{
		var validation:Boolean = true;

		for (var j:int = 0; j < combo.length; j++)
		{ if (combo[j] != live[j]) { validation = false; } }

		if (validation)
		{
			callback.call();
			reset();
		}
		else if (time > 0)
		{
			clearTimeout(timer);
			timer = setTimeout(reset, time, true);
		}
		else if (index == combo.length)
		{
			if (type == GROUP) { reset(); }
			if (type == SEQUENCE)
			{
				live.shift();
				index--;
			}
		}
	}

	private function reset(triggered:Boolean = false):void
	{
		if (triggered) { trace("too long !"); }

		clearTimeout(timer);
		live = new Array(combo.length);
		index = 0;
	}
}


internal class Keys
{
	static private var 	azerty:Dictionary,
						qwerty:Dictionary,
						qwtoaz:Dictionary,
						ready:Boolean = false;

	static public function get():Dictionary
	{
		if (!ready) { initialize(); }

		if (Capabilities.language == "fr") { return azerty; }
		else { return qwerty; }
	}

	static private function initialize():void
	{
		var j:int = 0,
			numbers:Array,
			lowercase:Array,
			pad:Array;

		azerty = new Dictionary();
		qwerty = new Dictionary();
		qwtoaz = new Dictionary();

		azerty[8]	= qwerty[8]		= qwtoaz[8]		=	{ label:"backspace", 	pressed:false };
		azerty[9]	= qwerty[9]		= qwtoaz[8]		=	{ label:"tab", 			pressed:false };
		azerty[13]	= qwerty[13]	= qwtoaz[13]	=	{ label:"enter", 		pressed:false };
		azerty[16]	= qwerty[16]	= qwtoaz[16]	=	{ label:"shift", 		pressed:false };
		azerty[17]	= qwerty[17]	= qwtoaz[17]	=	{ label:"ctrl", 		pressed:false };
		azerty[18]	= qwerty[18]	= qwtoaz[18]	=	{ label:"alt", 			pressed:false };
		azerty[19]	= qwerty[19]	= qwtoaz[19]	=	{ label:"pause", 		pressed:false };
		azerty[20]	= qwerty[20]	= qwtoaz[20]	=	{ label:"caps", 		pressed:false };
		azerty[27]	= qwerty[27]	= qwtoaz[27]	=	{ label:"esc", 			pressed:false };
		azerty[32]	= qwerty[32]	= qwtoaz[32]	=	{ label:"space", 		pressed:false };
		azerty[33]	= qwerty[33]	= qwtoaz[33]	=	{ label:"pageup", 		pressed:false };
		azerty[34]	= qwerty[34]	= qwtoaz[34]	=	{ label:"pagedown", 	pressed:false };
		azerty[35]	= qwerty[35]	= qwtoaz[35]	=	{ label:"end",			pressed:false };
		azerty[36]	= qwerty[36]	= qwtoaz[36]	=	{ label:"home",			pressed:false };
		azerty[37]	= qwerty[37]	= qwtoaz[37]	=	{ label:"left", 		pressed:false };
		azerty[38]	= qwerty[38]	= qwtoaz[38]	=	{ label:"up", 			pressed:false };
		azerty[39]	= qwerty[39]	= qwtoaz[39]	=	{ label:"right", 		pressed:false };
		azerty[40]	= qwerty[40]	= qwtoaz[40]	=	{ label:"down", 		pressed:false };
		azerty[45]	= qwerty[45]	= qwtoaz[45]	=	{ label:"ins", 			pressed:false };
		azerty[46]	= qwerty[46]	= qwtoaz[46]	=	{ label:"del", 			pressed:false };

		numbers  = String("0123456789").split("");
		for (j = 0; j < numbers.length; j++) { azerty[48 + j] = qwerty[48 + j] = qwtoaz[48 + j] = { label:numbers[j], pressed:false }; }

		lowercase = String("abcdefghijklmnopqrstuvwxyz").split("");
		for (j = 0; j < lowercase.length; j++) { azerty[65 + j] = qwerty[65 + j] = { label:lowercase[j], pressed:false }; }

		lowercase = String("qbcdefghijkl,noparstuvzxyw").split("");
		for (j = 0; j < lowercase.length; j++) { qwtoaz[65 + j] = { label:lowercase[j], pressed:false }; }

		azerty[91]	= qwerty[91]	= qwtoaz[91]	= { label:"winleft",	pressed:false }; //PC ONLY
		azerty[92]	= qwerty[92]	= qwtoaz[92]	= { label:"winright",	pressed:false }; //PC ONLY
		azerty[93]	= qwerty[93]	= qwtoaz[93]	= { label:"context",	pressed:false }; //PC ONLY

		pad = String("0123456789*+ -,/").split("");
		for (j = 0; j < pad.length; j++) { if (pad[j] != " ") { qwtoaz[96 + j] = { label:pad[j], pressed:false }; } }

		for (j = 0; j < 15; j++) { azerty[112 + j] = qwerty[112 + j] = qwtoaz[112 + j] = { label:"f" + (j + 1), pressed:false }; }

		azerty[144]	= qwerty[144] 	= qwerty[144] 	=	{ label:"num", 		pressed:false };
		azerty[145]	= qwerty[145] 	= qwerty[144] 	=	{ label:"scroll", 	pressed:false };

		azerty[186]	= { label:"$",			pressed:false };
		azerty[187]	= { label:"+",			pressed:false };
		azerty[188]	= { label:",",			pressed:false };
		azerty[189]	= { label:"-", 			pressed:false };
		azerty[190]	= { label:";",			pressed:false };
		azerty[191]	= { label:":", 			pressed:false };
		azerty[192]	= { label:"ù", 			pressed:false };
		azerty[219]	= { label:"°",			pressed:false };
		azerty[220]	= { label:"*",			pressed:false };
		azerty[221]	= { label:"^",			pressed:false };
		azerty[222]	= { label:"²",			pressed:false };
		azerty[223]	= { label:"!",			pressed:false };
		azerty[226]	= { label:"<",			pressed:false };

		qwerty[186]	= { label:"$",			pressed:false };
		qwerty[187]	= { label:"+",			pressed:false };
		qwerty[188]	= { label:",",			pressed:false };
		qwerty[189]	= { label:"-", 			pressed:false };
		qwerty[190]	= { label:";",			pressed:false };
		qwerty[191]	= { label:":", 			pressed:false };
		qwerty[192]	= { label:"ù", 			pressed:false };
		qwerty[219]	= { label:"[",			pressed:false };
		qwerty[220]	= { label:"*",			pressed:false };
		qwerty[221]	= { label:"^",			pressed:false };
		qwerty[222]	= { label:"²",			pressed:false };
		qwerty[223]	= { label:"!",			pressed:false };
		qwerty[226]	= { label:"<",			pressed:false };

		qwtoaz[186]	= { label:"m",			pressed:false };
		qwtoaz[187]	= { label:"-",			pressed:false };
		qwtoaz[188]	= { label:";",			pressed:false };
		qwtoaz[189]	= { label:"°", 			pressed:false };
		qwtoaz[190]	= { label:":",			pressed:false };
		qwtoaz[191]	= { label:"=", 			pressed:false };
		qwtoaz[192]	= { label:"<", 			pressed:false };
		qwtoaz[219]	= { label:"^",			pressed:false };
		qwtoaz[220]	= { label:"`",			pressed:false };
		qwtoaz[221]	= { label:"$",			pressed:false };
		qwtoaz[222]	= { label:"ù",			pressed:false };
		qwtoaz[223]	= { label:"!",			pressed:false };

		ready = true;
	}
}