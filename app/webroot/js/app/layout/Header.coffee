
dojo.provide 'app.layout.Header'


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
	configRemoteBranch: false

	postCreate: ->
		@setMessage()
		@setConfigMenu()
		# リポジトリ・ブランチメニューを初期化
		@domRepository.setDisabled true
		@domBranch.setDisabled true
		dojo.connect @domRepositoryMenu, 'onItemClick', @, @onRepositoryClick
		dojo.connect @domBranchMenu, 'onItemClick', @, @onBranchClick

	setConfigMenu: ->
		@domConfigMenu.addChild( new dijit.MenuItem(
			label: 'Remote Branch Show'
			onClick: do=>
				that = @
				->
					if that.configRemoteBranch
						@setLabel 'Remote Branch Show'
						that.configRemoteBranch = false
					else
						@setLabel 'Remote Branch Hide'
						that.configRemoteBranch = true
					that.nowRepository = ''
					that.resetBranch()
		))
		@domConfigMenu.addChild( new dijit.MenuItem(
			label: 'Clear cache'
			onClick: ->
				dojo.publish 'layout/LAN/fadeIn', ['ローカルキャッシュを削除']
				dojo.publish 'DataManager/clearCache'
				dojo.publish 'layout/LAN/fadeOut'
		))
		@domConfigMenu.addChild( new dijit.MenuItem(
			label: 'About SteingGit'
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
				# リポジトリメニューをセットする
				@domRepositoryMenu.destroyDescendants()
				for repo in data.repositories
					@domRepositoryMenu.addChild(
						new dijit.MenuItem(
							label: repo
						)
					)
				@domRepository.setDisabled false
		]

	onRepositoryClick: (item, event)->
		@nowRepository = item.label
		@nowBranch = ''
		@setMessage()
		@domBranch.setDisabled true
		dojo.publish 'DataManager/setDefaultPostData', ['repository', @nowRepository]
		dojo.publish 'DataManager/fetch', ['getBranches',
			{
				context: @
				postdata:
					remote: @configRemoteBranch
			}
			(data)->
				# ブランチメニューをセットする
				@domBranchMenu.destroyDescendants()
				for branch in data.branches
					@domBranchMenu.addChild(
						new dijit.MenuItem(
							label: branch
						)
					)
				@domBranch.setDisabled false
		]

	onBranchClick: (item, event)->
		@nowBranch = item.label
		@setMessage()

	resetBranch: ->
		@domBranchMenu.destroyDescendants()
		@domBranch.setDisabled true
		@nowBranch = ''
		@setMessage()

)