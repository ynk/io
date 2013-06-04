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
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import martian.ev3nts.on;
	
	import martian.daem0n.core.Daemon;

	import martian.m4gic.tools.Domain;
	
	import martian.t1me.data.Load;
	import martian.t1me.interfaces.Stackable;
	import martian.t1me.trigger.Call;

	
	
	public class SFX extends Daemon
	{
		static public const CONFIG:String = 'sfxConfig';
		
		private var sounds:Dictionary;
		private var current:Sound;
		
		private var channel:SoundChannel;
		private var audio:SoundTransform;
			
		public function SFX() { name = "SFX"; }
		
		public function hook(stage:Stage):void 
		{
			if (!$hook(stage, false)) { return; }
			sounds = new Dictionary();
		}
		
		public function kill():void
		{
			if (!$kill()) { return; }
			sounds = null;	
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
		
		private function parse(xml:XML):void
		{
			var sound:Class, pkg:String = String(xml.@app);
			
			for each(var child:XML in xml.children())
			{
				try
				{
					sound = getDefinitionByName(pkg + '.' + String(child.valueOf())) as Class;
					register(String(child.name()), sound);
				}
				catch(e:Error) { throw new Error('Given Sound is not included : ' + pkg + '.' + String(child.valueOf())); return; }
			}
				
			tell(CONFIG);
		}
		
		public function register(name:String, sound:Class):void
		{
			if (!Domain.extending(sound, Sound)) { throw new Error('Bad sound argument. Must inherits from Sound class'); }	
				sounds[name] = sound;
		}
		
		public function release(arg:*):Boolean
		{
			if (arg is String) { delete sounds[arg]; return true; }
			else if (arg is Class) { for (var name:* in sounds) { if (sounds[name] == arg) { delete sounds[name]; return true; } } }
			
			return false;
		}
		
		public function loop(name:String, iterations:int = int.MAX_VALUE, transform:SoundTransform = null):void
		{
			if (sounds[name] == undefined) { return; }
			
			stop();
			
			current = new sounds[name]();
				channel = current.play(0, iterations, transform);
				
			audio = transform || new SoundTransform();
				channel.soundTransform = audio;
		}
		
		public function stop():void
		{
			if (current != null)
			{
				channel.stop();
				audio.volume = 0;
				
				audio = null;
				current = null;
			}
		}
		
		public function fire(name:String, iterations:int = 99, transform:SoundTransform = null):void
		{
			var oneshot:Sound = new sounds[name](),
				soundchannel:SoundChannel = oneshot.play(0, iterations, transform);
				soundchannel.stop();
				
			var soundtransform:SoundTransform = transform || new SoundTransform();
				soundchannel.soundTransform = soundtransform;
				
			oneshot.play();	
		}
	}
}