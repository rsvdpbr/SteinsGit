<?php

class Git extends AppModel {

	public $useTable = false;

	public $errors = array();
	private $repository = null;
	private $repos = array(
		'Groupware' => '/Users/ryo/Sites/work/groupware',
		'SteinsGit' => '/Users/ryo/Sites/stegit',
	);

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
		return array_keys($this->repos);
		
	}

	/* リポジトリのアクセス権限を確認し、セット */
	public function setRepository($repo){
		if(isset($repo)){
			if(array_key_exists($repo, $this->repos)){
				$this->repository = $this->repos[$repo];
				return true;
			}
		}
		$this->errors[] = 'Repository Error';
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

}
