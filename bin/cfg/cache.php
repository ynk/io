<?php
	require_once("config.php");
	require_once("../php/Explorer.php");
	header("Content-Type: text/cache-manifest");
	
	$data = new SimpleXMLElement(file_get_contents("env/".ENV.".xml"));
		$data = $data->cachemanifest;
		
	function solve($branch)
	{
		$output = "";
		if (!$branch) { return $output; }
		
		foreach ($branch->children() as $data)
		{
			$attributes = $data->attributes();
			
			if ($data == "*")
			{
				$extension = isset($attributes["ext"]) ? $attributes["ext"] : "*";
				
				if ($data == $extension) { $output .= "*"; }
				else
				{
					$data = explore("../", $extension, true);
					foreach($data as $file) { $output .= substr($file, 4)."\n"; }
				}
			}
			else if (substr($data, -1, 1) == "/")
			{
				$extension = isset($attributes["ext"]) ? $attributes["ext"] : "*";
				$recursive = isset($attributes["recursive"]) ? $attributes["recursive"] == "true" : true;
				
				$data = explore("../".substr($data, 0, -1), $extension, $recursive);
				foreach($data as $file) { $output .= substr($file, 3)."\n"; }
			}
			else { $output .= $data."\n"; }
		}
		
		return $output;
	}
?>

CACHE MANIFEST

CACHE:
<?php echo solve($data->cache); ?>

NETWORK:
<?php echo solve($data->network); ?>

FALLBACK:
<?php echo solve($data->fallback); ?>