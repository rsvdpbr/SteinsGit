<?php

/**
 * git-diff の結果を構造化する
 */

require('./lib/library.php');

$git = new GitReader($config['repository']);

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


$logs = $git->getLogs(array('limit' => 2, 'commit' => $hash));
$commit1 = $logs[1][0];
$commit2 = $logs[0][0];
$diff = $git->getDiffBetweenTwoCommits($commit1, $commit2);
$diff = preg_replace("/^(@@.+@@)(\s)(.*)?/m", "\${1}\n\${3}", $diff);
$diff = htmlspecialchars($diff);
$diff = explode("\n", $diff);
$diff_start = "/^diff --git a\/(.+) b\/(.+)/";
$result = array();
$preserve_keys = false;
/* ファイル単位で分割 */
unset($last);
foreach($diff as $num => $i){
	if(preg_match($diff_start, $i)){
		if(isset($last)){
			$result[] = array_slice($diff, $last, $num - $last, $preserve_keys);
		}
		$last = $num;
	}
}
if(isset($last)){
	$result[] = array_slice($diff, $last, count($diff), $preserve_keys);
}

/* 変更点単位で分割 */
$at_start = "/^@@ ([\+\-0-9]+),([0-9]+) ([\+\-0-9]+),([0-9]+) @@$/";
$at_start = "/^@@ \-([0-9]+),([0-9]+) \+([0-9]+),([0-9]+) @@$/";
foreach($result as $key => $diff){
	$resultUnit = array();
	$last = 0;
	foreach($diff as $num => $i){
		if(preg_match($at_start, $i)){
			$resultUnit[] = array_slice($diff, $last, $num - $last, $preserve_keys);
			$last = $num;
		}
	}
	$resultUnit[] = array_slice($diff, $last, count($diff), $preserve_keys);
	preg_match("/^diff --git a\/(.+) b\/(.+)$/", $resultUnit[0][0], $match);
	$resultUnit[0] = array(
		'before' => $match[1],
		'after' => $match[2],
	);
	$result[$key] = $resultUnit;
}

/* 変更行単位で分割 */
foreach($result as $file_key => $file){
	foreach($file as $block_key => $block){
		if($block_key > 0){
			/* 行情報を取得 */
			preg_match($at_start, $block[0], $match);
			$bef_count = $match[1];
			$aft_count = $match[3];
			for($i=1,$len=count($block); $i<$len; $i++){
				preg_match("/^([\+\-\s])?(.*)/", $block[$i], $match);
				if($match[1] == '+'){
					$line = array('before' => null, 'after' => $aft_count++);
				}else if($match[1] == '-'){
					$line = array('before' => $bef_count++, 'after' => null);
				}else{
					$line = array('before' => $bef_count++, 'after' => $aft_count++);
				}
				$result[$file_key][$block_key][$i] = array(
					'status' => $match[1],
					'code' => $match[2],
					'line' => $line,
				);
			}
		}
	}
}

$DataHash['diff'] = $result;
$DataHash['selectedBranch'] = $branch;
$DataHash['commitHash'] = $hash;
$DataHash['commands'] = $git->getCommandLog();

?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html lang="ja">
  <head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<style>
	  p {
	    margin:0;
	    padding:0;
	  }
	  table.code {
	    background:#fafafa;
	    border:1px solid #888;
	    border-collapse: collapse;
	    width:100%;
	    font-size: 13px;
	  }
	  table.code td {
	    border: 0 solid #aaa;
	    border-width: 0 1px;
	    padding: 0;
	  }
	  table.code td.status {
	    width: 18px;
	    text-align:center;
	  }
	  table.code td.line {
	    width: 46px;
	    text-align:center;
	  }
	  table.code td.code {
	  }
	  table.code tr.plus {
	    background:#dfd;
	  }
	  table.code tr.minus {
	    background:#fdd;
	  }
	  pre, code {
	    margin: 0;
	  }
	</style>
  </head>
	<body>
	  <!-- 結果表示 -->
	  <h2>現在のブランチ：<?php echo $DataHash['selectedBranch']; ?></h2>
	  <h2>コミット（<?php echo $DataHash['commitHash']; ?>）：</h2>
	  <div style="font-size:13px;">
	    <?php foreach($DataHash['diff'] as $file){ ?>
		<div style="margin:8px 8px 24px; padding: 8px; border:1px solid #aaa;">
	      <p style="font-size:16px;font-weight:bold;text-decoration:underline;">
	     	  <span style="color:#f33"><?php echo $file[0]['before']; ?></span> => <span style="color:#080;"><?php echo $file[0]['after']; ?></span>
     	  </p>
	      <?php for($i=1,$len=count($file); $i<$len; $i++){ ?>
	        <p style="color:#00c;margin-top:8px;"><?php echo $file[$i][0]; ?></p>
			<table class="code">
	          <?php for($j=1,$len2=count($file[$i]); $j<$len2; $j++){ ?>
			    <tr class="<?php echo ($file[$i][$j]['status'] == '+' ? 'plus' : ($file[$i][$j]['status'] == '-' ? 'minus' : '')); ?>">
				  <td class="status"><?php echo $file[$i][$j]['status']; ?></td>
				  <td class="line"><?php echo $file[$i][$j]['line']['before']; ?></td>
				  <td class="line"><?php echo $file[$i][$j]['line']['after']; ?></td>
				  <td class="code"><pre><code><?php echo $file[$i][$j]['code']; ?></code></pre></td>
			    </tr>
	     	  <?php } ?>
			</table>
	      <?php } ?>
		 </div>
	    <?php } ?>
	    <?php //pr($DataHash['diff']); ?>
	  </div>
	  <!-- コマンド出力 -->
	  <h2>実行コマンド</h2>
	  <ul>
		<?php foreach($DataHash['commands'] as $i){ ?>
		<li><?php echo $i; ?></li>
		<?php } ?>
	  </ul>
	  
	</body>
</html>
