
dojo.provide 'app.list.CommitListUnit'

dojo.require 'dijit._WidgetBase'
dojo.require 'dijit._Templated'

dojo.declare(
	'app.list.CommitListUnit'
	[dijit._Widget, dijit._Templated]

	widgetsInTemplate: true
	templateString: dojo.cache 'app.list','templates/CommitListUnit.html'
	style: 'width:100%;'

	data: null
	selected: false

	constructor: (data)->
		@inherited arguments
		@data = data
		dojo.publish 'Mediater/register', ['list/CommitListUnit/selectCommit', @, @onSelectCommit]
		
	postCreate: ->
		dojo.connect @domInner, 'onmouseenter', @, ->
			if !@selected then $(@domInner).css('backgroundColor', '#eee')
		dojo.connect @domInner, 'onmouseleave', @, ->
			if !@selected then $(@domInner).css('backgroundColor', '#fff')
		dojo.connect @domInner, 'click',  @, ->
			# Mediater/call
			dojo.publish 'Mediater/call', ['list/CommitListUnit/selectCommit', [@data]]

	onSelectCommit: (commit)->
		console.log 'onSelectCommit', commit[0]
		if @data == commit[0]
			@selected = true
			$(@domInner).css('backgroundColor', '#dfd')
		else
			@selected = false
			$(@domInner).css('backgroundColor', '#fff')

)
