<?php

/**
 * git-log を php で扱ってみるテスト
 *
 */

header("Content-type: text/html; charset=utf-8");

require("./lib/library.php");

$git = new GitReader($config["repository"]);

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


/* ログ出力 */
$result = $git->getLogs(array('limit' => $limit, 'page' => $page));
echo "<h1>command log</h1>";
pr($git->getLog());
echo "<h1>git-log</h1>";
pr($result);

/* ページング出力 */
/* テスト用だから、インライン要素にブロック要素いれるとか荒業やっちゃう */
$prevPage = $page - 1;
$nextPage = $page + 1;
echo <<< EOD
<a href="?page={$prevPage}">
<div style="position:fixed;top:0px;right:120px;width:120px;height:30px;background-color:#ccc;border:1px solid #aaa;opacity:0.8;text-align:center;line-height:30px;font-weight:bold;cursor:pointer;">Prev</div></a>
<a href="?page={$nextPage}"><div style="position:fixed;top:0px;right:0px;width:120px;height:30px;background-color:#ccc;border:1px solid #aaa;opacity:0.8;text-align:center;line-height:30px;font-weight:bold;cursor:pointer;">Next</div></a>
EOD;
