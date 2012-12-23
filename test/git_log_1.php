<?php

/**
 * git-log を php で扱ってみるテスト
 *
 */

header("Content-type: text/html; charset=utf-8");

require("./config.php");

require("./Timer.class.php");
$timer = new Timer(); /* 時間計測用。phpからコマンド叩いたことないから、どのくらいかかるのかと思って */

$timer->start("require git");
require("./Git.class.php");
$git = new Git($config["repository"]);
$timer->end("require git");

/* クエリ取得 */
$table = array(
	'page' => 0,
	'limit' => 20,
);
foreach($table as $key => $val){
	${$key} = $val;
	if(isset($_GET[$key]) && is_numeric($_GET[$key])){
		${$key} = $_GET[$key];
	}
}

/* ログ取得 */
$timer->start("execute git-log command");
$result = $git->execute( getGitLogCommand($limit, $page) );
$timer->end("execute git-log command");
$result = formatGitLogResult($result);

/* 結果出力 */
echo "<h1>command log</h1>";
pr($git->getLog());
echo "<h1>git-log</h1>";
pr($result);
echo "<h1>timer</h1>";
pr($timer->getLog());

/* ページング出力 */
/* テスト用だから、インライン要素にブロック要素いれるとか荒業やっちゃう */
$prevPage = $page - 1;
$nextPage = $page + 1;
echo <<< EOD
<a href="?page={$prevPage}">
<div style="position:fixed;top:0px;right:120px;width:120px;height:30px;background-color:#ccc;border:1px solid #aaa;opacity:0.8;text-align:center;line-height:30px;font-weight:bold;cursor:pointer;">Prev</div></a>
<a href="?page={$nextPage}"><div style="position:fixed;top:0px;right:0px;width:120px;height:30px;background-color:#ccc;border:1px solid #aaa;opacity:0.8;text-align:center;line-height:30px;font-weight:bold;cursor:pointer;">Next</div></a>
EOD;

/* ログ取得関数とその整形関数 */
function getGitLogCommand($limit = 20, $page = 0){
	$options = array();
	/* ページング */
	$start = $page * $limit;
	$options[] = "--skip={$start}";
	$options[] = "-n {$limit}";
	/* 日付フォーマット */
	$options[] = "--date=iso";
	/* ログフォーマット */
	$sep = "\t";
	$options[] = "--pretty=format:\"%h{$sep}%ad{$sep}%s\"";
	/* コマンド実行 */
	$command = "git log " . implode(' ',$options);
	return $command;
}

function formatGitLogResult($data){
	$data = unifyCrLf($data);
	$data = explode("\n", $data);
	foreach($data as $key => $val){
		$data[$key] = explode("\t", $val);
	}
	return $data;
}
/* 改行文字をLFに統一 */
function unifyCrLf($str){
	return str_replace(array("\r\n", "\r"), "\n", $str);
}
/* Cakeでお馴染みの */
function pr($str){
	echo '<pre>';
	print_r($str);
	echo '</pre>';
}

