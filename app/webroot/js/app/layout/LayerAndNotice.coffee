
dojo.provide 'app.layout.LayerAndNotice'

dojo.require 'dojo.date.locale'

dojo.declare(
	'app.layout.LayerAndNotice'
	null

	count: 0
	logs: []
	components:
		layer: null
		loading: null
		notice: null

	constructor: ->
		@setLayer()
		@setNoticeArea()
		@setString()
		@setSubscribe()

	setLayer: ->
		@components.layer = $('<div id="layer"></div>')
		$(@components.layer).css(
			'position': 'absolute'
			'zIndex': '5'
			'width': '100%'
			'height': '100%'
			'backgroundColor': '#555'
			'opacity': '0.5'
			'backgroundImage': 'url(img/loading.gif)'
			'backgroundRepeat': 'no-repeat'
			'backgroundPosition': 'center center'
			'display': 'none'
		).appendTo('body')

	setNoticeArea: ->
		@components.loading = $('<div id="notice"></div>')
		$(@components.loading).css(
			'zIndex': '6'
			'position': 'absolute'
			'width': '100%'
			'textAlign': 'center'
			'top': '50%'
			'margin-top': '-9px'
			'font-weight': 'bold'
			'font-size': '18px'
			'color': '#D2EAF5'
		).appendTo(@components.layer)
		@components.string = $('<div id="noticeString"></div>')
		$(@components.string).appendTo(@components.loading)
		@components.notice = $('<div id="noticeArea"></div>')
		$(@components.notice).css(
			'margin-top': '80px'
			'font-size': '15px'
		).appendTo(@components.loading)

	setSubscribe: ->
		dojo.subscribe 'layout/LAN/fadeIn', @, @fadeIn
		dojo.subscribe 'layout/LAN/fadeOut', @, @fadeOut
		dojo.subscribe 'layout/LAN/setString', @, @setString
		dojo.subscribe 'layout/LAN/setNotice', @, @setNotice
		dojo.subscribe 'layout/LAN/clearNotice', @, @clearNotice

	fadeIn: (string)->
		if string? then @setNotice(string)
		@count++;
		console.log 'layer> now count is ' + @count
		$(@components.layer).fadeIn(50)
	fadeOut: (context, func)->
		@count--;
		console.log 'layer> now count is ' + @count
		if @count == 0
			console.log 'layer> count is zero, fade-out'
			$(@components.layer).fadeOut(300, =>
				@clearNotice()
				if func?
					context = if context? then context else this
					func.apply(context)
			)

	setString: (string)->
		if !string? then string = "Loading"
		$(@components.string).text(string)
	setNotice: (string)->
		@logs.push
			'time': dojo.date.locale.format(new Date(), "yyyy/MM/dd HH:mm");
			'string': string
		$(@components.notice).text(string)
	clearNotice: ->
		$(@components.notice).text('')
		
)