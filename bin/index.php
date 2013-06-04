<!DOCTYPE html>
<html lang="fr" manifest="cfg/cache.php">
	
	<head>
		<title>demo</title>
		
		<meta charset="utf-8" />
		<meta name="description" content="" />
		
<!--		<script type="text/javascript" src="https://getfirebug.com/firebug-lite.js"></script>		-->
		<script src="js/swfobject.js" type="text/javascript"></script>
		<script src="js/swfrewrite.js" type="text/javascript"></script>
		
		<script type="text/javascript">
			rewrite.host("<?php echo $_SERVER['HTTP_HOST'].dirname($_SERVER['PHP_SELF']); ?>");
			
			var flashvars = {};
			
			var params =
			{
				menu: "false",
				scale: "noScale",
				allowFullscreen: "true",
				allowScriptAccess: "always",
				bgcolor: "#FFFFFF"
			};
			
			var attributes = { id:"wrapper" };
			
			swfobject.embedSWF("demo.swf", "wrapper", "100%", "100%", "10.0.0", "expressInstall.swf", flashvars, params, attributes);
		</script>
		
		<style type="text/css">
			html, body { width:100%; height:100%; overflow:hidden; }
			* { margin:0; padding:0; }
		</style>
	</head>
	
	<body>
		<div id="wrapper">
			<h1>demo</h1>
			<p><a href="http://www.adobe.com/go/getflashplayer"><img 
				src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" 
				alt="Get Adobe Flash player" /></a></p>
		</div>
		
		<script type="text/javascript">
			function fbl()
			{
				(function(F,i,r,e,b,u,g,L,I,T,E)
				{
					if(F.getElementById(b))	return;
						
					E = F[i+'NS'] && F.documentElement.namespaceURI;
					E = E ? F[i+'NS'](E,'script') : F[i]('script');
					E[r]('id',b);
					E[r]('src',I+g+T);
					E[r](b,u);
					(F[e]('head')[0] || F[e]('body')[0]).appendChild(E);
					E = new Image;
					E[r]('src',I+L);
					
				})(document,'createElement','setAttribute','getElementsByTagName','FirebugLite','4','firebug-lite.js','releases/lite/latest/skin/xp/sprite.png','https://getfirebug.com/','#startOpened');
			}
		</script>
	</body>
	
</html>