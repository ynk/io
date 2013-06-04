<?php
	require_once("config.php");
	
	$data = new SimpleXMLElement(file_get_contents("env/".ENV.".xml"));
	echo $data->application->asXML();
?>