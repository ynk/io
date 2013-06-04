package martian.t1me.data 
{
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import martian.t1me.interfaces.Progressive;
	import martian.t1me.interfaces.Stackable;
	import martian.t1me.misc.Time;
	
	public class Preload extends EventDispatcher implements Stackable, Progressive 
	{
		private var loaderinfo:LoaderInfo;
			public function get progress():Number { return loaderinfo ? (loaderinfo.bytesLoaded / loaderinfo.bytesTotal) : 0; }
		
		public function Preload(loaderinfo:LoaderInfo) 
		{
			if (!loaderinfo) { throw new Error('loaderinfo cannot be null'); }
			
			this.loaderinfo = loaderinfo;
		}
		
		public function start():void 
		{
			loaderinfo.addEventListener(ProgressEvent.PROGRESS, step);
			dispatchEvent(new Event(Time.START));
		}
		
		private function step(e:ProgressEvent):void 
		{
			if (progress >= 1)
			{
				loaderinfo.removeEventListener(ProgressEvent.PROGRESS, step);
				dispatchEvent(new Event(Time.STOP));
			}
			else { dispatchEvent(new Event(Time.STEP)); }
		}
		
		public function dispose():void { loaderinfo = null; }
	}
}