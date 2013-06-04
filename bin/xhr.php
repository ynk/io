<?php

	require_once "php/XHR.php";

	$xhr = new XHR(__DIR__);

	if (isset($_POST['urls'])) { $files = explode(",", $_POST['urls']); }

	foreach($files as $file) { $xhr->add($file); }
		print $xhr->get();
?>
