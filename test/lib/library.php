<?php

$base = dirname(__FILE__);

$require = array(
	'config.php',				/* 設定ファイル */
	'util.php',					/* 便利関数定義ファイル */
	'Timer.class.php',			/* 時間計測クラス */
	'GitCore.class.php',		/* Gitを扱うための最小限の機能を持つクラス */
	'GitReader.class.php',		/* Gitから各種情報を読み取る機能を持つクラス */
);

foreach($require as $file){
	require_once($base . '/' . $file);
}

