/*
Copyright (c) 2010 julien barbay <barbay.julien@gmail.com>

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
<<<<<<< HEAD
files (the 'Software'), to deal in the Software without
=======
files (the "Software"), to deal in the Software without
>>>>>>> 98835dae648483ec3ac8a32305e71d718b499d7b
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

package martian.t1me.data
{
	import flash.display.*;
	import flash.events.*;
	
	import flash.media.Sound;
	
	import flash.net.*;
	
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	
	import flash.utils.*;
	
	import martian.t1me.interfaces.Stackable;
	import martian.t1me.interfaces.Progressive;
	import martian.t1me.misc.Time;

	public class Load extends EventDispatcher implements Stackable, Progressive
	{
		static public var PROXY:String		= '';
		
		static public const IMAGE:String 		= 'image';
		static public const SWF:String 			= 'swf';
		static public const RSL:String			= 'rsl';
		static public const TEXT:String 		= URLLoaderDataFormat.TEXT;
		static public const ML:String 			= 'ml';
		static public const BINARY:String 		= URLLoaderDataFormat.BINARY;
		static public const VARIABLES:String 	= URLLoaderDataFormat.VARIABLES;
		static public const SOUND:String		= 'sound';		
		
		private var request:URLRequest;
		private var loader:*, target:*;
		private var type:String;

		private var loading:Number;
			public function get progress():Number { return loading; }
		
		protected var raw:* = null;
			public function get data():*
			{
				if (raw == null) { return null; }
				
				switch(type)
				{
					case IMAGE:		return Bitmap(raw);
					case SWF:		return DisplayObject(raw);
					case RSL:		return null;
					case TEXT:		return String(raw);
					case ML:		return new XML(raw);
					case BINARY:	return ByteArray(raw);
					case VARIABLES: return URLVariables(raw);
					case SOUND:		return Sound(raw);
				}
				
				return raw;
			}		
			
		public function Load(request:*, type:String, cache:Boolean = true)
		{
			if (request is String) { request = new URLRequest(request); }
			else if (!request is URLRequest) { throw new ArgumentError('request argument can be String or URLRequest'); }
			
			if (request.url.indexOf('proxy://') == 0) { request.url = PROXY + encodeURIComponent(request.url.replace('proxy://', 'http://')); }
			
			if (!cache)
			{
				request.url += request.url.lastIndexOf('?') == -1 ? '?' : '&';
				request.url += int(Math.random() * 0xFFFFFF).toString(16).toUpperCase();
			}
			
			this.request = request;
			this.type = type;
		}
		
		public function load():void { start(); }
		
		public function start():void
		{
			switch(type)
			{
				case IMAGE: case SWF: case RSL:
					loader = new Loader();
						loader.contentLoaderInfo.addEventListener(Event.COMPLETE, stop);
						loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onprogress);
						loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, stop);
						target = loader.contentLoaderInfo;
						break;
				
				case TEXT: case ML: case BINARY: case VARIABLES:
					loader = new URLLoader();
						loader.dataFormat = type != ML ? type : URLLoaderDataFormat.TEXT;
						loader.addEventListener(Event.COMPLETE, stop);
						loader.addEventListener(ProgressEvent.PROGRESS, onprogress);
						loader.addEventListener(IOErrorEvent.IO_ERROR, stop);
						target = loader;
						break;
				
				case SOUND:
					loader = new Sound();
						loader.addEventListener(Event.COMPLETE, stop);
						loader.addEventListener(ProgressEvent.PROGRESS, onprogress);
						loader.addEventListener(IOErrorEvent.IO_ERROR, stop);
						target = loader;
						break;
				
				default:
					throw new Error('unknown loader type:' + type);
					stop();
					return;
			}
			
			if (type == RSL) { loader.load(request, new LoaderContext(false, ApplicationDomain.currentDomain)); }
			else { loader.load(request); }
			
			dispatchEvent(new Event(Time.START));
		}
		
		private function onprogress(e:ProgressEvent):void
		{
			loading = e.bytesLoaded / e.bytesTotal;
			dispatchEvent(new Event(Time.STEP));
		}
		
		private function stop(e:* = null):void
		{
			if (e || target)
			{
				target.removeEventListener(Event.COMPLETE, stop);
				target.removeEventListener(ProgressEvent.PROGRESS, onprogress);
				target.removeEventListener(IOErrorEvent.IO_ERROR, stop);
			}
			
			if (e)
			{
				if (e.type == Event.COMPLETE)
				{
					switch(type)
					{
						case IMAGE: case SWF:
							raw = e.target.content;
							break;
						
						case TEXT: case ML: case BINARY: case VARIABLES:
							raw = e.target.data;
							break;
						
						case SOUND:
							raw = e.target;
							break;
					}
					
					dispatchEvent(new Event(Event.COMPLETE));
					
					if (loader is Loader) { loader.unloadAndStop(); }
						loader = null;
				}
				else { dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR)); }
			}
			
			dispatchEvent(new Event(Time.STOP));
		}
		
		public function dispose():void { raw = null; }
	}
}