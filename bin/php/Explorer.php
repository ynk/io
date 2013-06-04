<?php
	function explore($path = ".", $filter = "*", $recursive = true)
	{
		$files = array();
		
		$dir = opendir($path);
		$extensions = explode(",", $filter);
		
		while(false !== ($file = readdir($dir)))
		{
			if (substr($file, 0, 1) != ".")
			{
				if (is_dir($path.'/'.$file) && $recursive)
				{
					$subdir = explore($path."/".$file, $filter, true);
					if (count($subdir) > 0) { $files = array_merge((array)$files, (array)$subdir); }
				}
				else if (is_dir($path.'/'.$file)) {}
				else if ($filter == "*") { array_push($files, $path.'/'.$file); }
				else
				{
					foreach($extensions as $extension)
					{
						$length = strlen($extension);
						if (substr($file, -$length, $length) == $extension) { array_push($files, $path.'/'.$file); }
					}
				}
			}
		}
		
		closedir($dir);
		
		return $files;
	}
?>