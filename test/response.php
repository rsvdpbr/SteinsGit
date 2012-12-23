<?php
header("Content-type: text/html; charset=utf-8");

require("./config.php");
require("./Git.class.php");

$input = $_POST['command'];

$command = array("log", "status");

if(in_array($input, $command)){
    $git = new Git($config["repository"]);
    $result = $git->execute("git ".$input);
}else{
    $result = "failed";
}

pr($result);

function pr($str){
	echo '<pre>';
	print_r($str);
	echo '</pre>';
}
