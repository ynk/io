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

package martian.t1me.data
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import martian.ev3nts.on;

	import martian.t1me.misc.Time;
	
	import flash.net.URLRequest;
	import flash.net.URLStream;
	
	import flash.utils.ByteArray;
	
	import martian.t1me.interfaces.Stackable;
	
	public class XHR extends EventDispatcher implements Stackable 
	{
		static private const INIT:String 				= "init";
		static private const KILL:String 				= "dispose";
		
		static private const OPENING_BOUNDARY:String 	= "opening_boundary";
		static private const READING_HEADER:String 		= "reading_header";
		static private const READING_CONTENT:String 	= "reading_content";
		static private const WAITING_LOADING:String		= "waiting_loading";
		static private const WAITING_BOUNDARY:String	= "waiting_boundary";
		static private const CLOSING_BOUNDARY:String 	= "closing_boundary";
				
		static public var service:String = "xhr.php";
		
		
		
		private var policy:Boolean,
					files:Array;
		
		private var stream:URLStream,
					cache:ByteArray,
					line:ByteArray,
					
					boundary:String,
					index:int = 0,
					placeholder:Data,
		
					headers:Array,
					state:String,
					
					delimiter:String,
					search:uint;
					
		public var i:int = 0;
		
		public function XHR(strictly:Boolean = true, ...urls)
		{
			policy = strictly;
			
			files = new Array();
				for (var i:int = 0; i < urls.length; i++) { add(urls[i]); }
				
			stream = new URLStream();
				stream.addEventListener(Event.OPEN, parse);
				stream.addEventListener(ProgressEvent.PROGRESS, parse);
				
			cache = new ByteArray();
			headers = new Array();
		}
		
		public function add(url:String):void { files.push(new Data(files.length, url)); }
		public function remove(arg:*):void { }
		
		public function start():void  { load(); }
		public function load():void
		{
			var urls:String = "";
				for each(var data:Data in files) { urls += "," + data.url; }
				urls = urls.substr(1);
				
			var vars:URLVariables = new URLVariables();
				vars.urls = urls;
				
			var request:URLRequest = new URLRequest(service);
				request.method = URLRequestMethod.POST;
				request.data = vars;
				
			stream.load(request);
		}
		
		public function parse(e:Event = null):void
		{
			if (e)
			{
				if (e.type == Event.OPEN) { state = OPENING_BOUNDARY; }
				else if (e.type == Event.COMPLETE && !policy) { dispatchEvent(new Event(Time.STOP)); }
			}
			
			if (state == CLOSING_BOUNDARY) { dispatchEvent(new Event(Time.STOP)); }
			if (state == INIT || state == CLOSING_BOUNDARY || state == WAITING_LOADING || state == KILL) { return; }
			
			if (stream.bytesAvailable)
			{
				var dump:uint = cache.position;
					stream.readBytes(cache, cache.length, 0);
					cache.position = dump;
			}
			
			if (this[state]) { this[state].call(); }
		}
		
		private function opening_boundary():void
		{
			do
			{
				line = until(cache, "\n");
				var str:String = new String(line);
				
				if (str.indexOf("--") == 0)
				{
					if (boundary) { if (str.indexOf("--" + boundary) != 0) { continue; } }
					else { boundary = str.match(new RegExp("^(\\S+)\\s*$"))[1]; }
					
					state = READING_HEADER;
					break;
				}
				else if (str.indexOf(":") != -1)
				{
					var header:Array = str.split(":", 2);
					if (header[0].toLowerCase() == "content-type")
					{
						headers.push(str);
						var result:Array = header[1].match(new RegExp("^\\s*multipart\\/mixed;\\s*boundary=\"?([0-9abcdef]+?)\"?\\s*$", null));
						
						if (result)
						{
							boundary = result[1];
							state = READING_HEADER;
							break;
						}
					}
				}
			}
			while (line != null);
			
			until(cache, "\n");
			if (state != OPENING_BOUNDARY) { parse(); }
		}
		
		private function reading_header():void
		{
			if (!placeholder) { placeholder = identify(index++); }
			
			do
			{
				line = until(cache, "\n");
				var str:String = new String(line);
				
				if (str == "") { state = READING_CONTENT; break; }
				else if (str.indexOf(":") != -1)
				{
					var header:Array = str.split(":", 2);
						placeholder.headers.push(str);
						
					switch (header[0].toLowerCase())
					{
						case "content-type":
							var type:Array = header[1].match(/^\s*(\S+)\s*$/);
							if (type != null) { placeholder.mimetype = type[1]; }
							break;
							
						case "content-disposition":
							var name:Array = header[1].match(new RegExp("^\\s*attachment;\\s*filename=\"?(.+?)\"?\\s*$", null));
							if (name != null) { placeholder.name = name[1]; }
							break;
							
						case "content-boundary":	
							placeholder.boundary = header[1].substr(1);
							break;
						
						case "content-length":
							placeholder.length = parseInt(header[1], 10);
							break;
					}
				}
			}
			while (line != null);
			
			if (state != READING_HEADER) { parse(); }
		}
		
		private function reading_content():void
		{
			var chunk:ByteArray = new ByteArray();
					
			if (placeholder.length > 0)
			{
				if (cache.bytesAvailable < placeholder.length) { return; }
				
				delimiter = null;
				search = 0;
				
				cache.readBytes(chunk, 0, placeholder.length);
			}
			else
			{
				chunk = until(cache, "\n\n--" + placeholder.boundary);
					if (!chunk) { return; }
					
				cache.position -= String("\n\n--" + placeholder.boundary).length;
			}
			
			on(placeholder, Event.COMPLETE, onload);
				placeholder.load(chunk);
				
			state = WAITING_LOADING;
			parse();
		}
		
		private function onload():void
		{
			dispatchEvent(new Event(Time.STEP));
			
			until(cache, "\n");
			
			state = WAITING_BOUNDARY;
			parse();
		}
		
		private function waiting_boundary():void
		{
			line = until(cache, "\n");
			var str:String = new String(line);
			
			if (str.substr(0, 2) == "--")
			{
				if (str.indexOf(boundary) == 2) { state = CLOSING_BOUNDARY; }
				else if (str.indexOf(placeholder.boundary) == 2)
				{
					placeholder = null;
					state = WAITING_BOUNDARY;
					until(cache, "\n");
				}
			}
			else
			{
				state = READING_HEADER;
				cache.position -= str.length + 1;
			}
			
			parse();
		}
		
		public function until(source:ByteArray, delimiter:String):ByteArray
		{
			var dump:ByteArray = new ByteArray();
			var char:uint;
			
			var length:uint = delimiter.length,
				check:String = "",
				found:Boolean = false;
			
			var position:uint = source.position;
			
			if (this.delimiter == delimiter && search > 0) { source.position = this.search; }
			else
			{
				this.delimiter = null;
				this.search = 0;
			}
			
			while (source.bytesAvailable > 0)
			{
				char = source.readByte();
				dump.writeByte(char);
				
				check = (check + String.fromCharCode(char)).substr(-length);
				
				if (check == delimiter)
				{
					found = true;
					break;
				}
			}
			
			if (!found)
			{
				this.delimiter = delimiter;
				this.search = source.position - length + 1;
				
				source.position = position;
				
				return null;
			}
			
			this.delimiter = null;
			this.search = 0;
			
			var result:ByteArray = new ByteArray();
			
			if (dump.length > length)
			{
				dump.position = 0;
				dump.readBytes(result, 0, dump.length - length);
			}
			
			return result;
		}
		
		private function identify(arg:*):Data
		{
			var file:Data;
			
			if (arg is String) {  for each (file in files) { if (file.url == arg) { return file; } } }
			else if (arg is int) { for each (file in files) { if (file.id == arg) { return file; } } }
			
			return null;
		}
		
		public function get(arg:* = null):*
		{
			return arg != null ? identify(arg).get() || null : placeholder.get();
		}
		
		public function dispose():void 
		{
			files = null;
			placeholder = null;
			stream.close();
		}
	}
}



import flash.display.Bitmap;
import flash.display.Loader;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.ByteArray;

import martian.ev3nts.on;

internal class Data extends EventDispatcher
{
	public var id:uint;
	public var url:String;
	public var name:String = "";
	public var boundary:String = "";
	
	public var headers:Array = new Array();
	public var mimetype:String = "unknown";
	
	public var length:uint = 0;
	
	private var raw:*;
		public function get():* { return raw; }
	
	public function Data(id:uint, url:String)
	{
		this.id = id;
		this.url = url;
	}
	
	public function load(chunk:ByteArray):void
	{
		var loader:Loader;
		
		switch(true)
		{
			case mimetype.indexOf("jpeg") != -1:
			case mimetype.indexOf("png") != -1:
				loader = new Loader();
					on(loader.contentLoaderInfo, Event.COMPLETE, onload);
					loader.loadBytes(chunk);
					
				break;
			
			case mimetype.indexOf("xml") != -1:
				raw = new XML(new String(chunk));
					oncomplete();
					
				break;
				
			case mimetype.indexOf("text") != -1:
				raw = new String(chunk);
					oncomplete();
					
				break;
				
			default:
				oncomplete();
				break;
		}
	}
	
	private function onload(e:Event):void
	{
		raw = Bitmap(e.target.content);
			oncomplete();
	}
	
	private function oncomplete():void { dispatchEvent(new Event(Event.COMPLETE)); }
	
	override public function toString():String { return '[Data id="' + id + '" url="' + url + '", mimetype="' + mimetype + '"]'; }
}