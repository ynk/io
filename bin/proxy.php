<?php
	require_once(__DIR__."/php/Proxy.php");
	
	if(!isset($_GET["url"])) { die("-1"); }
	
	$data = proxy($_GET["url"], $_SERVER['HTTP_USER_AGENT']);
	
	header($data["headers"]["content-type"]["display"]);
	header($data["headers"]["content-disposition"]["display"]);
	header($data["headers"]["content-length"]["display"]);
	
	echo $data["content"];
?>
