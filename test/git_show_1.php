<?php

/**
 *  git-show を実行してみるテスト
 *
 */

require("./lib/library.php");

$git = new GitReader($config["repository"]);

/* クエリ取得 */
$table = array(
	'branch' => 'master',
	'hash' => null,
);
foreach($table as $key => $val){
	${$key} = $val;
	if(isset($_GET[$key]) && $_GET[$key]){
		${$key} = $_GET[$key];
	}
}

/* データ取得 */
$DataHash = array();

$show = $git->getShow($hash);
/* 【荒業警報】 なんか@@のとこでうまくいかないから、強制的に改行文字いれちゃう */
$show = preg_replace("/^(@@.+@@)(\s)(.*)?/m", "\${1}\n\${3}", $show);
$show = htmlspecialchars($show);
$show = explode("\n", $show);
/* キー部分の正規表現に一致したものに、バリュー部分のスタイルを適用する */
$regexps = array(
	'/^\-/' => 'color: #f33;',
	'/^\+/' => 'color: #080;',
	'/^(commit|diff)/' => 'font-weight:bold; text-decoration: underline;',
	'/^(Author|Date|index|@@)/' => 'color: #00c;',
);
$sorcecodeRegion = false;
foreach($show as $key => $val){
	/* 正規表現でスタイル適用 */
	foreach($regexps as $regexp => $style){
		if(preg_match($regexp, $val)){
			$show[$key] = '<span style="' . $style . '">' . $show[$key] . '</span>';
			break;
		}
	}
	/* ソースコード部分をdivでくくる */
	if(!$sorcecodeRegion && preg_match("/^@@.+@@/", $val)){
		$show[$key+1] = '<div style="background:#fafafa; border:1px solid #888; margin:4px; padding: 4px;">' . $show[$key+1];
		$sorcecodeRegion = true;
	}else if($sorcecodeRegion && preg_match("/^diff/", $val)){
		$show[$key-1] = $show[$key-1] . '</div>';
		$sorcecodeRegion = false;
	}
}
if($sorcecodeRegion){
	$show[] = "</div>";
}
$show = implode("\n", $show);
$DataHash['show'] = $show;

$DataHash['selectedBranch'] = $branch;
$DataHash['commitHash'] = $hash;
$DataHash['commands'] = $git->getCommandLog();

?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html lang="ja">
  <head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<body>
	  <!-- 結果表示 -->
	  <h2>現在のブランチ：<?php echo $DataHash['selectedBranch']; ?></h2>
	  <h2>コミット（<?php echo $DataHash['commitHash']; ?>）：</h2>
<?php pr($DataHash['show']); ?>
	  <!-- コマンド出力 -->
	  <h2>実行コマンド</h2>
	  <ul>
		<?php foreach($DataHash['commands'] as $i){ ?>
		<li><?php echo $i; ?></li>
		<?php } ?>
	  </ul>
	  
	</body>
</html>
