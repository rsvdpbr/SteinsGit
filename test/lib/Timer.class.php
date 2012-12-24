<?php

class Timer {

	private $log;
	private $sum;

	public function __construct(){
		$this->sum = $this->getNow();
		$this->log = array();
	}

	public function start($name){
		$now = $this->getNow();
		$this->log[$name] = array(
			"name" => $name,
			"start" => $now,
			"end" => 0,
			"time" => 0,
		);
		return $now;
	}

	public function end($name){
		$now = $this->getNow();
		$this->log[$name]["end"] = $now;
		$this->log[$name]["time"] = $now - $this->log[$name]["start"];
		return $this->log[$name]["time"];
	}

	public function getLog(){
		return array_merge(
			array("total" => $this->format($this->getNow() - $this->sum)),
			$this->formatAll($this->log)
		);
	}
	private function formatAll(){
		$data = $this->log;
		foreach($data as $key => $val){
			$data[$key]["time"] = $this->format($val["time"]);
		}
		return $data;
	}

	private function format($num){
		return number_format($num, 3, ".", "") . "ms";
	}

	public static function getNow(){
		return microtime(true) * 1000;
	}

}

