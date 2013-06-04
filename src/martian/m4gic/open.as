package martian.m4gic 
{
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.net.sendToURL;
	
	public function open(request:*, window:String = '_blank'):void
	{
		if (request is String) { request = new URLRequest(request); }
		else if (!request is URLRequest) { throw new ArgumentError('request argument can be String or URLRequest'); }
		
		(window != '') ? navigateToURL(request, window) : sendToURL(request);
	}
}