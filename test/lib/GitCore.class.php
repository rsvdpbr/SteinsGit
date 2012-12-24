<?php

class GitCore {

	private $repo;
	private $exec_log;

	public function __construct($path){
		$this->repo = $this->getRepository($path);
		$this->exec_log = array();
	}

	private function getRepository($path){
		if(substr($path, -1) !== "/"){
			$path = $path . "/";
		}
		if(!file_exists($path)){
			throw new RuntimeException("there is no git repository at " . $path);
		}
		return $path;
	}

	public function execute($command){
		$this->exec_log[] = $command;
		$command = "cd {$this->repo}; {$command}";
		return shell_exec($command);
	}

	public function getCommandLog(){
		return $this->exec_log;
	}

}

