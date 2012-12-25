<?php

class GitReader extends GitCore {

	/* 改行文字をLFに統一 */
	private function unifyCrLf($str){
		return str_replace(array("\r\n", "\r"), "\n", $str);
	}

	/* ブランチを配列にして返す（添字[0]は現在のブランチ） */
	public function getBranches($param = array()){
		/* git-branch の結果を取得 */
		$options = array();
		if(isset($param['remote']) && $param['remote']){
			$options[] = "-a";
		}
		$command = "git branch " . implode(" ", $options);
		$branches = $this->execute($command);
		/* 整形 */
		$result = array('HEAD');
		foreach(explode("\n", $this->unifyCrLf($branches)) as $i){
			if($i == '* (no branch)'){
				$result[0] = 'no branch';
			}else if(preg_match("/(\*)? ([0-9a-zA-Z\/_\-\.]+)/", $i, $match)){
				if($match[1] === '*'){
					$result[0] = $match[2];
				}else{
					$result[] = $match[2];
				}
			}
		}
		return $result;
	}

	/* ログを配列にして返す */
	public function getLogs($param = array()){
		/* git-log のオプションを設定 */
		$options = array();
		foreach($param as $name => $val){
			${$name} = $val;
		}
		if(isset($branch)){
			$options[] = $branch;
		}
		if(isset($page) && isset($limit)){
			$start = $page * $limit;
			$options[] = "--skip={$start}";
		}
		if(isset($limit)){
			$options[] = "-n {$limit}";
		}
		$options[] = "--date=iso";
		$sep = "\t";
		$options[] = "--pretty=format:\"%h{$sep}%ad{$sep}%s\"";
		/* コマンド実行 */
		$command = "git log " . implode(' ', $options);
		$result = $this->execute($command);
		/* 整形 */
		$result = $this->unifyCrLf($result);
		$result = explode("\n", $result);
		foreach($result as $key => $val){
			$result[$key] = explode("\t", $val);
		}
		return $result;
	}

	/*  */
	public function getShow($hash, $param = array()){
		/* git-show 実行 */
		$options = array();
		$command = "git show " . $hash . " " . implode(' ', $options);
		$result = $this->execute($command);
		/* 整形 */
		$result = $this->unifyCrLf($result);
		return $result;
	}
}

