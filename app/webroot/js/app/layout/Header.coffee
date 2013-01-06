
dojo.provide 'app.layout.Header'

dojo.require 'app.header.RepositoryDialog'

dojo.require 'dijit._Widget'
dojo.require 'dijit._Templated'
dojo.require 'dijit.Menu'
dojo.require 'dijit.MenuBar'
dojo.require 'dijit.PopupMenuBarItem'
dojo.require 'dijit.DropDownMenu'
dojo.require 'dijit.MenuItem'

dojo.declare(
	'app.layout.Header'
	[dijit._Widget, dijit._Templated]
	
	widgetsInTemplate:true
	templateString: dojo.cache 'app.layout','templates/Header.html'

	nowRepository: ''
	nowBranch: ''
	addRepositoryDlg: null
	configRemoteBranch: false

	postCreate: ->
		@setMessage()
		@setSubscribe()
		@setConfigMenu()
		# リポジトリ・ブランチメニューを初期化
		@domRepository.setDisabled true
		@domBranch.setDisabled true
		dojo.connect @domRepositoryMenu, 'onItemClick', @, @onRepositoryClick
		dojo.connect @domBranchMenu, 'onItemClick', @, @onBranchClick
		# ダイアログを作成
		@addRepositoryDlg = new app.header.RepositoryDialog

	setSubscribe: ->
		dojo.subscribe 'layout/Header/setRepositoryMenu', @, @setRepositoryMenu
		dojo.subscribe 'layout/Header/setRepository', @, @setRepository

	setConfigMenu: ->
		@domConfigMenu.addChild( new dijit.MenuItem(
			label: 'Remote Branch Show'
			onClick: do=>
				that = @
				->
					if that.configRemoteBranch
						@setLabel 'Remote Branch Show'
						that.configRemoteBranch = false
						dojo.publish 'layout/LAN/addCommonNotice', ['リモートブランチの表示をオフにしました']
					else
						@setLabel 'Remote Branch Hide'
						that.configRemoteBranch = true
						dojo.publish 'layout/LAN/addCommonNotice', ['リモートブランチの表示をオンにしました']
					that.nowRepository = ''
					that.resetBranch()
		))
		@domConfigMenu.addChild( new dijit.MenuItem(
			label: 'Clear cache'
			onClick: ->
				dojo.publish 'DataManager/clearCache'
				dojo.publish 'layout/LAN/addCommonNotice', ['ローカルキャッシュを削除しました']
		))
		@domConfigMenu.addChild( new dijit.MenuItem(
			label: 'About SteinsGit'
			onClick: ->
				dojo.publish 'layout/LAN/setString', ['SteinsGit']
				dojo.publish 'layout/LAN/fadeIn', ['version 0.1.0 (develop) - 2013/01/03']
				# 【荒業警報】LayerAndNoticeの内部実装に依存
				# こういうことするのここだけだろうし、わざわざこのためにLAN弄りたくないから荒業る
				# していることは、一時的にローディングレイヤーにクリックイベントつけて、クリックされたら、
				# レイヤーをフェードアウトしてクリックイベントを削除。セレクタ#layerがLANの実装に依存
				layerClickFunc = =>
					$('#layer').unbind 'click', layerClickFunc
					dojo.publish 'layout/LAN/fadeOut', [@, ->
						dojo.publish 'layout/LAN/setString'
					]
				$('#layer').bind 'click', layerClickFunc
		))

	# postCreate後にApp.coffeeから呼び出される、データ面での初期化処理
	initialize: ->
		@setRepositoryMenu()

	setMessage: ->
		prefix = 'SteinsGit &gt; '
		str = 'no repository selected'
		if @nowRepository != ''
			str = @nowRepository
			if @nowBranch != ''
				str += ' . ' + @nowBranch
		@domMessage.setLabel(prefix + str)

	setRepositoryMenu: ->
		dojo.publish 'DataManager/fetch', ['getRepositories',
			{context: @},
			(data)->
				dojo.publish 'layout/LAN/addCommonNotice', ['リポジトリ一覧を取得しました, 画面右上のRepositoryメニューから設定可能です']
				# リポジトリメニューをセットする
				@domRepositoryMenu.destroyDescendants()
				for repo in data.repositories
					@domRepositoryMenu.addChild(
						new dijit.MenuItem
							label: repo
							type: 'repository'
					)
				@domRepositoryMenu.addChild(
					new dijit.MenuItem
						label: '<span style="font-style:italic;color:#888;">Add new repository</span>'
						type: 'action'
						subtype: 'add'
				)
				@domRepository.setDisabled false
		]

	onRepositoryClick: (item, event)->
		if item.type == 'action'
			if item.subtype == 'add'
				@addNewRepository()
		else if item.type == 'repository'
			@setRepository(item.label)

	setRepository: (repoName)->
			@nowRepository = repoName
			@resetBranch()
			@setMessage()
			@domBranch.setDisabled true
			dojo.publish 'layout/LAN/addCommonNotice', ['カレントリポジトリを '+@nowRepository+' に設定しました']
			dojo.publish 'DataManager/setDefaultPostData', ['repository', @nowRepository]
			dojo.publish 'DataManager/fetch', ['getBranches',
				{
					context: @
					postdata:
						remote: @configRemoteBranch
				}
				(data)->
					dojo.publish 'layout/LAN/addCommonNotice', [@nowBranch+' ブランチ情報を取得しました, 画面右上のBranchメニューから設定可能です']
					# ブランチメニューをセットする
					@domBranchMenu.destroyDescendants()
					for branch in data.branches
						@domBranchMenu.addChild(
							new dijit.MenuItem(
								label: branch
							)
						)
					@domBranch.setDisabled false
					# Mediater call
					dojo.publish 'Mediater/call', ['layout/Header/selectRepository', [@nowRepository]]
			]

	addNewRepository: ->
		console.log 'new dialog show and input repository name and path or url'
		@addRepositoryDlg.show()

	onBranchClick: (item, event)->
		@nowBranch = item.label
		@setMessage()
		dojo.publish 'layout/LAN/addCommonNotice', [@nowBranch+' ブランチにチェックアウトしました']
		# Mediater call
		dojo.publish 'Mediater/call', ['layout/Header/selectBranch', [@nowBranch]]

	resetBranch: ->
		@domBranchMenu.destroyDescendants()
		@domBranch.setDisabled true
		@nowBranch = ''
		@setMessage()
		# Mediater call
		dojo.publish 'Mediater/call', ['layout/Header/clearBranch', []]

)