rewrite = new function()
{
	var host;
	
	this.host = function()
	{
		if (arguments.length == 0) { return gethost(); }
		else { sethost(arguments[0]); }
	};
	
	var gethost = function() { return host; };
	var sethost = function(s)
	{
		var init = (host == undefined);
			host = window.location.protocol + "//" + s + "/";
		
		if (init)
		{
			if (!rewrite.html5)
			{
				if (window.location.hash == "")
				{
					var uri = window.location.toString(),
						pms = uri.split(host).join("");
						
					window.location.replace(host + (pms.charAt(0) == "/" ? "#" : "#/") + pms.replace(/#/g, ""));
				}
			}
		}
	};	
	
	this.hook = null;
	
	this.cron = function()
	{
		if (!rewrite.html5)
		{
			if (window.location.hash == "") { window.location.hash = "/"; }
			
			if (value != window.location.hash.substr(1))
			{
				value = window.location.hash.substr(1);
				if (rewrite.debug) { console.log("external change"); }
				rewrite.hook.gateway("tell", "external");
			}
		}
		else
		{
			if (value != window.location.href.replace(rewrite.host(), ""))
			{
				value = window.location.href.replace(rewrite.host(), "");
				if (rewrite.debug) { console.log("external change"); }
				rewrite.hook.gateway("tell", "external");
			}
		}
	}

	var value = !this.html5 ? window.location.hash.substr(1) : window.location.href.replace(this.host, "");

	this.value = function()
	{
		if (arguments.length == 0) { return getvalue(); }
		else { setvalue(arguments[0]); }
	}
	
	var getvalue = function() { return !this.html5 ? value.substr(1) : value; };
	var setvalue = function(s)
	{
		if (!rewrite.html5)
		{
			value = "/" + s;
				window.location.hash = value;
		}
		else
		{
			value = s;
			window.history.pushState({}, "", value);
		}
    };

	this.path = function()
	{
		var path = value.replace(rewrite.host(), "").substr(!this.html5 ? 1 : 0).split("/"), i = 0;
			while(i < path.length)
			{
				 if (path[i].indexOf("?") > -1) { path[i] = path[i].split("?")[0]; }
				 else if (path[i] == "" || path[i].charAt(0) == "?") { path.splice(i, 1); }
				 else { i++; }
			}
			
        return path;
    };
    
	this.parameters = function()
	{
		var url = value.split("?");
			url.shift();
		
		if (url.length == 0) { return null; }
			
		var pms = url[0].split("&"),
			pm, obj = {};
			
		for (var i = 0; i < pms.length; i++)
		{
			pm = pms[i].split("=");
			obj[pm[0]] = pm[1];
		}	
			
        return obj;
    };
	
	this.overwrite = function()
	{
		if (typeof swfobject != undefined)
		{
			var object = this;
			var method = swfobject.embedSWF;
				swfobject.embedSWF = function()
				{
					var args = new Array();
					for (var i = 0; i < 10; i++) { args.push(arguments[i]); }
						if (args[8] == undefined) { args[8] = {}; }
						if (typeof args[8].id == undefined) { args[8] = args[1]; }
						
					var capsule = function(e) { object.deeplink(args[1]); };	
					if (args[9] == undefined) { args[9]= capsule; }
					
					method.apply(this, args);
				}
		}
	};
	
	this.deeplink = function(id)
	{
		this.callback = function() { this.hook = document[id]; }
		if (this.ready) { this.callback.call(this); }
	};

	var active = false;
	
	this.launch = function()
	{
		if (active === true) { return; }
			active = true;
			
		value = !this.html5 ? window.location.hash.substr(1) : window.location.href.replace(this.host, "");
		
		var object = this;
		
		setTimeout(function()
		{
			object.hook.gateway("tell", "ready");
			object.timer = setInterval(object.cron, 50);
		}, 50);
	}
	
	this.callback = null;
	this.ready = false;
	this.timer = null;	
	
	this.wait = function()
	{
		var ie = (window.attachEvent && !window.opera),
			webkit = navigator.userAgent.indexOf("AppleWebKit/") > -1;

		if (document.readyState && webkit)
		{
			this.timer = setInterval(function()
			{
				var state = document.readyState;
				if (state == "loaded" || state == "complete") { rewrite.domready(); }
			}, 50);
		}
		else if (document.readyState && ie)
		{
			var src = (window.location.protocol == "https:") ? "://0" : "javascript:void(0)";
			document.write('<script type="text/javascript" defer="defer" src="' + src + '" onreadystatechange="if (this.readyState == \'complete\') rewrite.domready();"><\/script>');
		}
		else
		{
			var object = this;
			
			if (window.addEventListener)
			{
				document.addEventListener("DOMContentLoaded", function() { object.domready(); }, false);
				window.addEventListener("load", function() { object.domready(); }, false);
			}
			else if (window.attachEvent) { window.attachEvent("onload", object.domready); }
			else
			{
				var fn = window.onload;
				window.onload = function()
				{
					rewrite.domready();
					if (fn) { fn(); }
				}
			}
		}
	};
	
	this.domready = function()
	{
		if (this.ready) { return; }
			this.ready = true;
		
		if (this.timer) { clearInterval(this.timer); this.timer = null; }
		if (this.callback) { this.callback(); }
	};
	
	this.html5 = window.history.pushState != undefined;
	
	this.debug = (window.console != undefined);
	
	//constructor
	this.overwrite();
	this.wait();
}