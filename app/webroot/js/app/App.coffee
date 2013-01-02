
dojo.provide 'app.App'

dojo.require 'app.layout.LayerAndNotice'
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
		layer: null
		main: null
		header: null
		center: null
		side:
			left: null
			right: null

	constructor: ->
		@components.layer = new app.layout.LayerAndNotice
		dojo.publish 'layout/LAN/fadeIn'
		dojo.publish 'layout/LAN/setNotice', ['初期化処理を実行中']

	postCreate: ->
		@inherited arguments
		dojo.publish 'layout/LAN/setNotice', ['画面レイアウトを構築中']
		@setLayout()
		dojo.publish 'layout/LAN/setNotice', ['ロード完了']
		dojo.publish 'layout/LAN/fadeOut'

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