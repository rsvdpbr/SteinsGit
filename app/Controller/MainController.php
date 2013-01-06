<?php

class MainController extends AppController {

	public $uses = array('Git');

	public function beforeRender(){
		$this->Error = $this->Git->errors;
		parent::beforeRender();
	}

	public function index(){}

	/* POSTデータから特定のキーの存在を確認する */
	private function checkPostDataExistance($keys){
		foreach($keys as $key){
			if(!isset($this->request->data[$key])){
				$this->Git->errors[] = "{$key} is required";
				return false;
			}
		}
		return true;
	}
	/* 渡した連想配列で、POSTデータに存在するものはPOSTデータの値で上書きする */
	private function extendWithPostData($hash){
		foreach($hash as $key => $val){
			if(isset($this->request->data[$key])){
				$hash[$key] = $this->request->data[$key];
			}
		}
		return $hash;
	}

	/* リポジトリ一覧を取得する */
	public function getRepositories(){
		$this->DataHash['repositories'] = $this->Git->getRepositories();
		return $this->DataHash['repositories'];
	}

	public function addRepository(){
		$result = $this->Git->addRepository($this->request->data);
		$this->DataHash['repository'] = $result['name'];
	}

	/* ブランチリストを取得する */
	public function getBranches(){
		if(
			!$this->checkPostDataExistance(array('repository')) ||
			!$this->Git->setRepository($this->request->data['repository'])
		){ return false; }
		if(isset($this->request->data['remote']) && $this->request->data['remote'] == 'true'){
			$all = true;
		}else{
			$all = false;
		}
		$this->DataHash['branches'] = $this->Git->getBranches($all);
	}

	/* コミットログを取得する */
	public function getCommitList(){
		if(
			!$this->checkPostDataExistance(array('repository', 'branch')) ||
			!$this->Git->setRepository($this->request->data['repository']) ||
			!$this->Git->setBranch($this->request->data['branch'])
		){ return false; }
		$param = $this->extendWithPostData(array(
				'branch' => null,
				'limit' => 10,
				'page' => 0,
			));
		$this->DataHash['commits'] = $this->Git->getCommits($param);
	}

}
