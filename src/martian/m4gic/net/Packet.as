package martian.m4gic.net 
{
	import flash.utils.ByteArray;
	
	public class Packet
	{
		static public const BUFFER_MAX_SIZE:int = 32;
		static public var MAGIC:int = 0x57;
		
		static public const INVALID:int = 0;
		static public const POLICY:int = 1;
		static public const HANDSHAKE:int = 2;
		static public const FRIEND_COME:int = 3;
		static public const FRIEND_QUIT:int = 4;
		static public const BROADCAST:int = 5;
		static public const RAW:int = 6;
		static public const NOTIFICATION:int = 7;
		static public const CLOSE:int = 8;
		
		static public function policyfile(port:int):ByteArray
		{
			var data:ByteArray = new ByteArray();
				data.writeUTFBytes('<?xml version="1.0"?><cross-domain-policy><allow-access-from domain="*" to-ports="' + port.toString() + '"/></cross-domain-policy>');
				data.writeByte(0);
			
			return data;
		}
		
		static public function dump(src:ByteArray, debug:Boolean = false):Packet
		{
			var packet:Packet = new Packet(),
				data:ByteArray = new ByteArray();
				
			src.position = 0;
			src.readBytes(data);
			
			if (data.toString().indexOf("<policy-file-request/>") != -1)
			{
				packet.type = POLICY;
				packet.parent = POLICY;
				packet.sender = 0;
				packet.target = 0;
				packet.data = null;
				
				return packet;
			}
			
			if (data.readByte() != MAGIC) { trace("this raw data is not a valid packet"); return null; }
			
			packet.type = data.readShort();
				if (debug) { trace("packet type:", packet.type); }
				
			if (packet.type == Packet.INVALID) { return null; }
				
			packet.parent = data.readShort();
				if (debug) { trace("packet parent:", packet.parent); }
				
			packet.sender = data.readInt();
				if (debug) { trace("packet sender:", packet.sender); }
			
			packet.target = data.readInt();
				if (debug) { trace("packet target:", packet.target); }
			
			if (debug) { trace("packet bytes available for data:", data.bytesAvailable); }
			
			if (data.bytesAvailable)
			{
				packet.data = new ByteArray();
					data.readBytes(packet.data as ByteArray);
					
				if (debug) { trace("packet data:", packet.data); }
				if (packet.type < 10
					|| packet.parent == BROADCAST
					|| packet.parent == NOTIFICATION
					|| packet.parent == RAW) { packet.data = Qark.decode(packet.data as ByteArray); }
			}
			
			return packet;
		}
		
		public var	type:int = INVALID,
					parent:int = INVALID,
					sender:int = 0,
					target:int = 0,
					data:Object = null;
					
		public function get bytearray():ByteArray
		{
			var bytearray:ByteArray = new ByteArray();
				bytearray.writeByte(MAGIC);
				bytearray.writeShort(type);
				bytearray.writeShort(parent);
				bytearray.writeInt(sender);
				bytearray.writeInt(target);
				if (data) {	bytearray.writeBytes(data is ByteArray ? data as ByteArray : Qark.encode(data)); }
				
			bytearray.position = 0;
			return bytearray;
		}
		
		public function Packet() {}
		
		public function reverse():Packet
		{
			var tmp:int = sender;
				sender = target;
				target = tmp;
				
			return this;
		}
	}
}
























































import flash.display.BitmapData;
import flash.utils.ByteArray;
import flash.utils.describeType;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

//aerys.in
internal class Qark
{
	static private const MAGIC:uint	= 0x3121322b;
	static private const FLAG_NONE:uint = 0;
	static private const FLAG_GZIP:uint = 1;
	static private const FLAG_DEFLATE:uint = 2;
	static private const TYPE_CUSTOM:uint = 0;
	static private const TYPE_OBJECT:uint = 1;
	static private const TYPE_ARRAY:uint = 2;
	static private const TYPE_INT:uint = 3;
	static private const TYPE_UINT:uint = 4;
	static private const TYPE_FLOAT:uint = 5;
	static private const TYPE_STRING:uint = 6;
	static private const TYPE_BYTES:uint = 7;
	static private const TYPE_BOOLEAN:uint = 8;
	static private const TYPE_BITMAP_DATA:uint = 9;
	static private const ENCODERS:Array = [encodeCustomObject, encodeObject, encodeArray, encodeInteger, encodeUnsignedInteger, encodeFloat, encodeString, encodeBytes, encodeBoolean, encodeBitmapData];
	static private const DECODERS:Array = [decodeCustomObject, decodeObject, decodeArray, decodeInteger, decodeUnsignedInteger, decodeFloat, decodeString, decodeBytes, decodeBoolean, decodeBitmapData];

	static private function getType(source:*):int
	{
		if (source is int)								{ return TYPE_INT; }
		if (source is uint)								{ return TYPE_UINT; }
		if (source is Number)							{ return TYPE_FLOAT; }
		if (source is String)							{ return TYPE_STRING; }
		if (source is Array)							{ return TYPE_ARRAY; }
		if (source is ByteArray)						{ return TYPE_BYTES; }
		if (source is Boolean)							{ return TYPE_BOOLEAN; }
		if (source is BitmapData) 						{ return TYPE_BITMAP_DATA; }
		if (getQualifiedClassName(source) == "Object")	{ return TYPE_OBJECT; }
			
		return TYPE_CUSTOM;
	}

	static public function encode(source:*, compress:Boolean = true):ByteArray
	{
		var result:ByteArray = new ByteArray(),
			data:ByteArray = new ByteArray();
			
		result.writeInt(MAGIC);
		
		encodeRecursive(source, data);
		data.position = 0;
		
		if (!compress)
		{
			result.writeByte(FLAG_NONE);
			result.writeBytes(data);
			result.position = 0;
			
			return result;
		}
		
		var size:int = data.length,
			compressedSize:int = 0,
			deflatedSize:int = 0;
			
		data.deflate();
		deflatedSize = data.length;
		data.inflate();
		
		data.compress();
		compressedSize = data.length;
		
		if (compressedSize < size) { result.writeByte(FLAG_GZIP); }
		else
		{
			data.uncompress();
			result.writeByte(FLAG_NONE);
		}
		
		
		if (compressedSize < size && compressedSize < deflatedSize) { result.writeByte(FLAG_GZIP); }
		else if (deflatedSize < size && deflatedSize < compressedSize)
		{
			data.uncompress();
			data.deflate();
			result.writeByte(FLAG_DEFLATE);
		}
		else
		{
			data.uncompress();
			result.writeByte(FLAG_NONE);
		}

		result.writeBytes(data);
		result.position = 0;

		return result;
	}

	static public function decode(source:ByteArray):*
	{
		var magic:uint = source.readInt();
		
		if (magic != MAGIC) { return null; }
		
		var flags:uint = source.readByte(),
			data:ByteArray = new ByteArray();
			
		source.readBytes(data);
		
		if (flags & FLAG_DEFLATE) { data.inflate(); }
		else if (flags & FLAG_GZIP) { data.uncompress(); }
		
		return decodeRecursive(data);
	}

	static private function encodeRecursive(source:*, target:ByteArray):void
	{
		var flag : int = getType(source);
			target.writeByte(flag);
			
		ENCODERS[flag].call(null, source, target);
	}

	static private function decodeRecursive(source : ByteArray) : *
	{
		var flag:uint = source.readByte();
			return DECODERS[flag].call(null, source);
	}

	static private function encodeObject(source:Object, target:ByteArray):void
	{
		var start:int = target.position,
			length:int = 0,
			propertyName:String;
			
		target.position += 2;
			
		for (propertyName in source)
		{
			encodeString(propertyName, target);
			encodeRecursive(source[propertyName], target);
				
			++length;
		}

		var stop:int = target.position;

		target.position = start;
		target.writeShort(length);
		target.position = stop;
	}

	static private function decodeObject(source:ByteArray, target:Object = null) : Object
	{
		var length:int = source.readShort();
			target ||= new Object();
			
		for (; length > 0; --length) target[decodeString(source)] = decodeRecursive(source);
		
		return target;
	}

	static private function encodeArray(source:Array, target:ByteArray):void
	{
		var length:int = source.length;
			target.writeShort(length);

		for (var i:int = 0; i < length; ++i) { encodeRecursive(source[i], target); }
	}

	static private function decodeArray(source : ByteArray) : Array
	{
		var  array:Array = new Array();
		
		for (var length:int = source.readShort(); length > 0; --length)
			array.push(decodeRecursive(source));

		return array;
	}

	static private function encodeString(source:String, target:ByteArray):void { target.writeUTF(source); }
	static private function decodeString(source:ByteArray):String { return source.readUTF(); }

	static private function encodeInteger(source:int, target:ByteArray):void { target.writeInt(source); }
	static private function decodeInteger(source : ByteArray):int { return source.readInt(); }

	static private function encodeUnsignedInteger(source:uint, target:ByteArray):void { target.writeUnsignedInt(source); }
	static private function decodeUnsignedInteger(source:ByteArray) : uint { return source.readUnsignedInt(); }

	static private function encodeFloat(source:Number, target:ByteArray) : void { target.writeFloat(source); }
	static private function decodeFloat(source:ByteArray):Number { return source.readFloat(); }

	static private function encodeBytes(source:ByteArray, target:ByteArray):void
	{
		target.writeInt(source.length);
		target.writeBytes(source);
	}

	static private function decodeBytes(source:ByteArray):ByteArray
	{
		var ba:ByteArray = new ByteArray();
		
		source.readInt();
		source.readBytes(ba);
		ba.position = 0;
		
		return ba;
	}

	static private function encodeBoolean(source:Boolean, target:ByteArray):void { target.writeByte(source ? 1 : 0); }
	static private function decodeBoolean(source:ByteArray):Boolean { return source.readByte() == 1; }

	static private function encodeCustomObject(source:Object, target:ByteArray):void
	{
		var variables:XMLList = describeType(source).variable,
			object:Object = new Object(),
			propertyName:String;

		for each (var variable:XML in variables)
		{
			propertyName = variable.@name;
			object[propertyName] = source[propertyName];
		}

		encodeObject(object, target);
	}

	static private function decodeCustomObject(source:ByteArray):Object { return decodeObject(source); }

	static private function encodeBitmapData(source:BitmapData, target:ByteArray):void
	{
		var ba:ByteArray = source.getPixels(source.rect);
		
		target.writeShort(source.width);
		target.writeShort(source.height);
		target.writeBoolean(source.transparent);
		
		var S:Object = getDefinitionByName('martian.m4gic.net.Server');
		if (S) { S.log(ba.length, ba.endian, ba.objectEncoding); }
		
		encodeBytes(ba, target);
	}

	static private function decodeBitmapData(source : ByteArray):BitmapData
	{
		var w:int = source.readShort(),
			h:int = source.readShort(),
			t:Boolean = source.readBoolean(),
			b:ByteArray = decodeBytes(source);
		
		var bmp:BitmapData = new BitmapData(w, h, t, 0);
			bmp.setPixels(bmp.rect, b);

		return bmp;
	}
}