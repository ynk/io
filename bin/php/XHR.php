<?php

class XHR
{
	const INIT = "new";
	const OPEN = "opened";
	const KILL = "closed";
	
	var $boundary;
	var $path;
	var $files = array();

	var $state = XHR::INIT;
	var $max_mtime = 0;
	
	public function __construct($path = ".")
	{
		define("N", "\n");
		
		$this->boundary = uniqid(md5(microtime()));
		$this->path = $path;
	}
	
	public function add($file)
	{
		if ($this->state == XHR::KILL) { throw new Exception(-1); }
			$this->state = XHR::OPEN;
			
		$file = $this->path."/".$file;	
		$this->max_mtime = max($this->max_mtime, @filemtime($file));
		
		if (strpos($file, "proxy://") === false)
		{
			$data["headers"]["content-type"]["value"] = $this->get_mime_type($file);
			$data["headers"]["content-disposition"]["value"] = basename($file);
			$data["headers"]["content-length"]["value"] = filesize($file);
			$data["content"] = file_get_contents($file);
		}
		else
		{
			require_once(__DIR__."/Proxy.php");
				$file = substr($file, strrpos($file, "proxy://") + 8);
				$data = proxy("http://".$file);
		}
		
		
		array_push($this->files, array
								 (
									"id" 		=> count($this->files),
									"mimetype" 	=> $data["headers"]["content-type"]["value"],
									"name" 		=> $data["headers"]["content-disposition"]["value"],
									"length" 	=> $data["headers"]["content-length"]["value"],
									"content" 	=> $data["content"]
								 )
				   );
	}

	public function get()
	{
		if ($this->state == XHR::INIT) { throw new Exception(-2); }
		if ($this->state == XHR::KILL) { throw new Exception(-3); }
			$this->state = XHR::KILL;
		
		ob_start();	
			
		$headers = apache_request_headers();
		
		if (array_key_exists("If-Modified-Since", $headers))
		{
			$request_time = strtotime($headers["If-Modified-Since"]);
			
			if ($request_time == $this->max_mtime)
			{
				header("HTTP/1.1 304 Not Modified");
				exit;
			}
		}
		
		header('Last-Modified: '.date("r", $this->max_mtime));
		header('MIME-Version: 1.0');
		header('Content-Type: multipart/mixed; boundary="'.$this->boundary.'"');
		
		echo 'Content-Type: multipart/mixed; boundary="'.$this->boundary.'"'.N.N;
		
		foreach ($this->files as $file)
		{
			echo 'Content-Type: '.$file['mimetype'].N;
			echo 'Content-Disposition: attachment; filename="'.$file['name'].'"'.N;
			echo 'Content-Boundary: '.$file['id'].'_'.$this->boundary.N;
			echo 'Content-Length: '.$file['length'].N.N;
			echo $file['content'].N;
			echo '--'.$file['id'].'_'.$this->boundary.'--'.N.N;
		}
		
		echo "--".$this->boundary."--".N;
		
		return ob_get_clean();
	}
	
	//php.net "mime_content_type" first comment
	private function get_mime_type($filename, $path = '.')
	{
		if ($path == ".") { $path = __DIR__; }
	
		$fileext = substr(strrchr($filename, '.'), 1);
			if (empty($fileext)) { return -2; }

		if (!file_exists($path."/mime.types") || !is_readable($path."/mime.types")) { return -3; }
		
		$lines = file($path."/mime.types", FILE_IGNORE_NEW_LINES);
	   
		$matches = array();

		foreach($lines as $line)
		{
			if (strpos($line, "#") === 0) continue;
			if (!preg_match("#^(\S+)\s*\t.*".$fileext."#i", $line, $matches)) { continue; }
			
			return $matches[1];
		}
		
		return -1;
	}
}

?>
