
dojo.provide 'app.layout.Left'

dojo.require 'dijit.layout.AccordionContainer'
dojo.require 'dijit.layout.AccordionPane'
dojo.require 'dijit._Widget'
dojo.require 'dijit._Templated'

dojo.declare(
	'app.layout.Left'
	[dijit._Widget, dijit._Templated]

	widgetsInTemplate:true
	templateString: dojo.cache 'app.layout','templates/Left.html'

	constructor: ->
		@inherited arguments
		console.log('layout/Left.coffee : constructor')
		

	postCreate: ->
		@inherited arguments

)