
dojo.provide 'app.layout.Header'


dojo.require 'dijit._Widget'
dojo.require 'dijit._Templated'
dojo.require 'dijit.Menu'
dojo.require 'dijit.MenuSeparator'
dojo.require 'dijit.MenuBar'
dojo.require 'dijit.PopupMenuBarItem'
dojo.require 'dijit.DropDownMenu'
dojo.require 'dijit.MenuItem'

dojo.declare(
	'app.layout.Header'
	[dijit._Widget, dijit._Templated]
	
	widgetsInTemplate:true
	templateString: dojo.cache 'app.layout','templates/Header.html'
	
	constructor: ->
		@inherited arguments
		console.log('layout/Header.coffee : constructor')

	postCreate: ->
		@inherited arguments

)