
dojo.provide 'app.App'

dojo.require 'app.layout.Header'
dojo.require 'app.layout.Center'
dojo.require 'app.layout.Side'

dojo.require 'dijit.layout._LayoutWidget'
dojo.require 'dijit._Templated'
dojo.require 'dijit.layout.BorderContainer'

dojo.declare(
	'app.App'
	[dijit.layout._LayoutWidget]

	components:
		main: null
		header: null
		center: null
		side:
			left: null
			right: null

	postCreate: ->
		@inherited arguments
		@setLayout()

	setLayout: ->
		$('body').append('<div id="container"></div>');
		@components.main = new dijit.layout.BorderContainer {
			style: 'width:100%; height:100%;'
			design: 'headline'
		}, 'container'
		@components.main.addChild(
			@components.header = new app.layout.Header {
				region: 'top'
				style: 'margin-bottom:0;'
			}
		)
		@components.main.addChild(
			@components.center = new app.layout.Center {
				region: 'center'
			}
		)
		@components.main.addChild(
			@components.side.left = new app.layout.Side {
				region: 'left'
				splitter: 'true'
			}
		)
		@components.main.startup()
		# AccordionContainerの表示がおかしいため、リサイズする
		@components.side.left.accordionContainer.resize()
		

)