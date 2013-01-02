<?php

class MainController extends AppController {

	public $uses = array('Git');

	public function beforeRender(){
		$this->Error = $this->Git->errors;
		parent::beforeRender();
	}

	public function index(){}

	/* リポジトリ一覧を取得する */
	public function getRepositories(){
		$this->DataHash['repositories'] = $this->Git->getRepositories();
	}

	/* ブランチリストを取得する */
	public function getBranches(){
		if(!$this->Git->setRepository($this->request->data['repository'])){
			return false;
		}
		if(isset($this->request->data['remote']) && $this->request->data['remote'] == 'true'){
			$all = true;
		}else{
			$all = false;
		}
		$this->DataHash['branches'] = $this->Git->getBranches($all);
	}

}
