<?php
header("Content-type: text/html; charset=utf-8");

require("./lib/library.php");

$input = $_POST['command'];

$command = array("log", "status");

if(in_array($input, $command)){
    $git = new GitCore($config["repository"]);
    $result = $git->execute("git ".$input);
}else{
    $result = "failed";
}

pr($result);

