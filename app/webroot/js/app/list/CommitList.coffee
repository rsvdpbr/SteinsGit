
dojo.provide 'app.list.CommitList'

dojo.require 'app.list.CommitListUnit'
dojo.require 'dijit.layout._LayoutWidget'

dojo.declare(
	'app.list.CommitList'
    [dijit.layout._LayoutWidget,dijit._Templated],

	widgetsInTemplate: true
	templateString: dojo.cache 'app.list','templates/CommitList.html'
	style: 'width:100%; height:100%; padding:0; margin:0;'
	title: 'Commit List'
	limit: 100
	page: 0
	commits: []

	constructor: ->
		@inherited arguments
		# Mediater register
		dojo.publish 'Mediater/register', ['layout/Header/selectBranch', @, @onSelectBranch]
		dojo.publish 'Mediater/register', ['layout/Header/clearBranch', @, @onClearBranch]

	postCreate: ->
		@inherited arguments
		@onClearBranch()

	onClearBranch: ->
		@domContents.destroyDescendants()
		string = '<div style="padding:8px;text-align:center;">no branch selected</span>'
		@domContents.setContent(string)

	onSelectBranch: (branch)->
		@page = 0
		@branch = branch
		@fetchCommitList()

	fetchCommitList: ->
		@domContents.destroyDescendants()
		@commits = []
		dojo.publish 'DataManager/fetch', ['getCommitList',
			{
				context: @
				postdata:
					branch: @branch
					limit: @limit
					page: @page
			},
			(data)->
				console.log('Commits', data, @)
				@getPrevHtml()
				for commit in data.commits
					clu = new app.list.CommitListUnit(commit)
					clu.placeAt(@domContents)
					@commits.push clu
				@getNextHtml()
		]

	# 汚いやり方だけど、とりあえず暫定的に
	getPrevHtml: ->
		if @page > 0
			@domPrev = $('<div>前のページに戻る</div>').css
				'width': '100%', 'height': '32px', 'padding': '0', 'margin': '0'
				'borderBottom': '1px solid #aaa', 'cursor': 'pointer'
				'textAlign': 'center', 'color': '#33a', 'line-height': '32px'
			$(@domPrev).hover(
				=> $(@domPrev).css('backgroundColor', '#ffe')
				=> $(@domPrev).css('backgroundColor', '#fff')
			)
			$(@domPrev).bind 'click', =>
				@page--
				@fetchCommitList()
			$(@domContents.domNode).append(@domPrev)
	getNextHtml: ->
		if @limit == @commits.length
			@domNext = $('<div>次のページに進む</div>').css
				'width': '100%', 'height': '32px', 'padding': '0', 'margin': '0'
				'cursor': 'pointer', 'textAlign': 'center', 'color': '#33a'
				'line-height': '32px'
			$(@domNext).hover(
				=> $(@domNext).css('backgroundColor', '#ffe')
				=> $(@domNext).css('backgroundColor', '#fff')
			)
			$(@domNext).bind 'click', =>
				@page++
				@fetchCommitList()
			$(@domContents.domNode).append(@domNext)

)
