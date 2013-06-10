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

package martian.daem0n.todo
{
	/**
	 * Provides an easy way to use cursors as a singleton
	 */	
	public const Cursors:* = null;
}

/*

import flash.display.*;
import flash.events.*;
import flash.geom.Point;
import flash.ui.Mouse;

import martian.m4gic.services.Service;

internal class _Cursors extends Service
{
	private var current:*;
	private var offset:Point;	
	private var visible:Boolean = false;
		public function get hidden():Boolean { return !visible; }
	
	public function _Cursors() { NAME = "Cursors"; }
	
	override protected function _activate(args:Object = null):void { visible = false; }
	override protected function _desactivate(args:Object = null):void
	{
		if (visible)
		{	
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, follow);
			stage.removeChild(current);
			
			current = null;
			
			Mouse.show();
			visible = false;
		}
	}
	
	public function show(cursor:DisplayObject, offset:Point = null, only:Boolean = true):void
	{
		if (available && !visible)
		{
			this.offset = (offset != null) ? offset : new Point();
			
			current = cursor;
			current.mouseEnabled = current.mouseChildren = false;
			
			stage.addChild(current);
			
			follow(null);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, follow);

			if (only) { Mouse.hide(); }
			
			visible = true;
		}
	}
	
	public function hide():void
	{
		if (available && visible)
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, follow);
			
			stage.removeChild(current);
			current = null;
			Mouse.show();
			
			visible = false;
		}
	}
	
	private function follow(e:MouseEvent):void
	{
		stage.setChildIndex(current, stage.numChildren - 1);
		
		current.x = stage.mouseX + offset.x;
		current.y = stage.mouseY + offset.y;
	}
}
*/