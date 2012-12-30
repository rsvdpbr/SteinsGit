<?php

/**
 * git-branch 毎に git-log を 表示してみるテスト
 *
 */

require("./lib/library.php");

$git = new GitReader($config["repository"]);

/* クエリ取得 */
$table = array(
	'branch' => 'master',
	'limit' => 50,
	'page' => 0,
);
foreach($table as $key => $val){
	${$key} = $val;
	if(isset($_GET[$key]) && $_GET[$key]){
		${$key} = $_GET[$key];
	}
}

/* データ取得 */
$DataHash = array();

$DataHash['selectedBranch'] = $branch;
$DataHash['branches'] = $git->getBranches(array('remote'=>true));
$DataHash['logs'] = $git->getLogs(array('branch' => $branch, 'limit' => $limit, 'page' => $page));
foreach($DataHash['logs'] as $key => $val){
	$str = '['.date('Y/m/d H:i:s', strtotime($val[1])).']　'.$val[2];
	$str = '<a title="'.$val[0].'" href="git_diff_1.php?hash='.$val[0].'">' . $str . '</a>';
	$DataHash['logs'][$key] = $str;
}
$count = count($git->getLogs(array('branch' => $branch)));
$DataHash['page'] = array(
	'page' => $page,
	'limit' => $limit,
	'start' => $page * $limit + 1,
	'end' => $page * $limit + $limit,
	'maxCount' => $count,
	'maxPage' => ceil($count / $limit),
);
$DataHash['limits'] = array(10,20,30,40,50,60,70,80,90,100,200);
$DataHash['commands'] = $git->getCommandLog();

?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html lang="ja">
  <head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<style>
	  #log li {
	    border: 0 solid #fff;
	    border-width: 1px 0;
	    cursor: pointer;
	  }
	  #log li:hover {
	    color: #00b;
	    background-color: #fff0f0;
	    border-color: #500;
	  }
	  li a {
	    text-decoration: none;
	    color: #000;
	  }
	  li:hover a {
	    color: #00b;
	  }
	</style>
	<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
	<script type="text/javascript">
	  
	</script>
	<body>
	  <!-- フォーム部分 -->
	  <form name="config" method="GET">
		<div style="border:1px solid #888; background:#eef; padding:4px 8px; font-size:11px;">
		  <label style="margin:0 8px;">
			ブランチ：
			<select name="branch" onchange="document.forms['config'].submit()">
			  <?php foreach($DataHash['branches'] as $i){ ?>
			  <option value="<?php echo $i; ?>" <?php echo $i==$DataHash['selectedBranch'] ? 'selected' : ''; ?>><?php echo $i; ?>
				<?php } ?>
			</select>
			
		  </label>
		  <label style="margin:0 8px;">
			ページ：
			<select name="page" onchange="document.forms['config'].submit()">
			  <?php for($i=0; $i<$DataHash['page']['maxPage']; $i++){ ?>
					<option value="<?php echo $i; ?>" <?php echo $i==$DataHash['page']['page'] ? 'selected' : ''; ?>><?php echo $i+1; ?>
					  <?php } ?>
			</select>
		  </label>
		  <label style="margin:0 8px;">
			表示数：
			<select name="limit" onchange="document.forms['config'].submit()">
			  <?php foreach($DataHash['limits'] as $i){ ?>
			  <option value="<?php echo $i; ?>" <?php echo $i==$DataHash['page']['limit'] ? 'selected' : ''; ?>><?php echo $i; ?>
				<?php } ?>
			</select>
		  </label>
		</div>
	  </form>
	  <!-- 結果表示 -->
	  <h2>現在のブランチ：<?php echo $DataHash['selectedBranch']; ?></h2>
	  <h2>ログ（全<?php echo $DataHash['page']['maxCount']; ?>件中 <?php echo $DataHash['page']['start'].'〜'.min($DataHash['page']['end'], $DataHash['page']['maxCount']).''; ?>件目を表示 / <?php echo $DataHash['page']['page']+1; ?>ページ目）：</h2>
	  <ul id="log">
		<?php foreach($DataHash['logs'] as $i){ ?>
		<li><?php echo $i; ?></li>
		<?php } ?>
	  </ul>
	  <!-- コマンド出力 -->
	  <h2>実行コマンド</h2>
	  <ul>
		<?php foreach($DataHash['commands'] as $i){ ?>
		<li><?php echo $i; ?></li>
		<?php } ?>
	  </ul>
	  
	</body>
</html>
