
dojo.provide 'app.App'

dojo.require 'app.layout.Header'
dojo.require 'app.layout.Center'
dojo.require 'app.layout.Left'

dojo.require 'dijit.layout._LayoutWidget'
dojo.require 'dijit._Templated'
dojo.require 'dijit.layout.ContentPane'
dojo.require 'dijit.layout.BorderContainer'
dojo.require 'dijit.layout.AccordionContainer'
dojo.require 'dijit.layout.AccordionPane'
dojo.require 'dijit.layout.TabContainer'

dojo.declare(
	'app.App'
	[]

	components:
		header: null
		left: 
			top: null
			center: null
		center: null

	constructor: ->
		@inherited arguments
		console.log('App.coffee : constructor')
		@setLayout()

	setLayout: ->
		$('body').append('<div id="container"></div>');
		# 要素の作成
		bc = new dijit.layout.BorderContainer {
			style: 'width:100%; height:100%;'
			design: 'headline'
		}, 'container'
		@components.header = new app.layout.Header
			region: 'top'
			style: 'margin-bottom:0;'
		lefts = new dijit.layout.BorderContainer
			region: 'left'
			style: 'width:360px; style="height:100%;" border:0;'
			splitter: 'true'
		@components.left.top = new app.layout.Left
			region: 'top'
			style: 'height:30%; border:0;'
			splitter: 'true'
		@components.left.center = new app.layout.Left
			region: 'center'
			style: 'border:0;'
			splitter: 'true'
		@components.center = new app.layout.Center
			region: 'center'
			splitter: 'true'
		# 親子関係の定義
		bc.addChild(@components.header)
		bc.addChild(lefts)
		lefts.addChild(@components.left.top)
		lefts.addChild(@components.left.center)
		bc.addChild(@components.center)
		bc.startup()
		
)