
dojo.provide 'app.layout.Side'

dojo.require 'app.list.CommitList'

dojo.require 'dijit.layout.AccordionContainer'
dojo.require 'dijit.layout.ContentPane'
dojo.require 'dijit._Widget'
dojo.require 'dijit._Templated'

dojo.declare(
	'app.layout.Side'
	# [dijit._Widget, dijit._Templated]
	[dijit.layout._LayoutWidget, dijit._Templated]

	widgetsInTemplate: true
	templateString: dojo.cache 'app.layout','templates/Side.html'
	style: 'width:400px; height:100%; border:0; padding:0;'

	resize: ->
		@inherited arguments
		@accordionContainer.resize()

)
