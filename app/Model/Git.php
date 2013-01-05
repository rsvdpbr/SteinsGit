<?php

class Git extends AppModel {

	public $errors = array();
	private $repository = null;
	private $branch = null;

	/* シェルコマンドを実行 */
	private function execute($command){
		if(!$this->repository) return false;
		$command = escapeshellcmd($command);
		$command = "cd {$this->repository}; {$command};";
		return shell_exec($command);
	}
	/* 改行文字を統一 */
	private function unifyCrLf($str){
		return str_replace(array("\r\n", "\r"), "\n", $str);
	}

	/* リポジトリ一覧を返す */
	public function getRepositories(){
		$repos = $this->find('all', array('fields' => array('name')));
		$result = array();
		foreach($repos as $i){
			$result[] = $i['Git']['name'];
		}
		return $result;
		
	}

	/* リポジトリのアクセス権限を確認し、セット */
	public function setRepository($repoName){
		$repo = $this->find('first', array(
				'fields' => array('path'),
				'conditions' => array('name' => $repoName),
			));
		if($repo){
			$this->repository = $repo = $repo['Git']['path'];
			return true;
		}else{
			$this->errors[] = 'Repository Error';
			return false;
		}
	}

	/* ブランチの存在を確認し、セット */
	public function setBranch($branch){
		$branches = $this->getBranches(true);
		if(in_array($branch, $branches)){
			$this->branch = $branch;
			return true;
		}
		$this->errors[] = 'Branch Error';
		return false;
	}

	/* ブランチを配列にして返す（添字[0]は現在のブランチ） */
	public function getBranches($all = false){
		if(!$this->repository) return false;
		$options = array();
		if($all){ $options[] = "-a"; }
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
	public function getCommits($param = array()){
		/* git-log のオプションを設定 */
		$options = array();
		foreach($param as $name => $val){
			${$name} = $val;
		}
		if(isset($branch)){
			$options[] = $branch;
		}
		if(isset($limit)){
			if(!is_numeric($limit)){
				$this->errors[] = 'Invalid arguments';
				return false;
			}
			$options[] = "-n {$limit}";
		}
		if(isset($page) && isset($limit)){
			if(!is_numeric($page)){
				$this->errors[] = 'Invalid arguments';
				return false;
			}
			$start = $page * $limit;
			$options[] = "--skip={$start}";
		}
		$options[] = "--date=iso";
		$sep = "\t";
		$options[] = "--pretty=format:\"%h{$sep}%an{$sep}%ad{$sep}%s\"";
		/* コマンド実行 */
		$command = "git log " . implode(' ', $options);
		$result = $this->execute($command);
		/* 整形 */
		$result = $this->unifyCrLf($result);
		$result = explode("\n", $result);
		$ret = array();
		foreach($result as $key => $val){
			$unit = explode("\t", $val);
			if($unit[0]){
				$ret[$key] = array(
					'hash' => $unit[0],
					'author' => $unit[1],
					'datetime' => date('Y-m-d H:i:s', strtotime($unit[2])),
					'text' => $unit[3],
				);
			}
		}
		return $ret;
	}

}
