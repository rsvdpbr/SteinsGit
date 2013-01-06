
dojo.provide 'app.layout.LayerAndNotice'

dojo.require 'dojo.date.locale'

dojo.declare(
	'app.layout.LayerAndNotice'
	null

	count: 0
	logs: []
	commonLogs: []
	components:
		layer: null
		loading: null
		notice: null

	constructor: ->
		@setLayer()
		@setNoticeArea()
		@setCommonNotice()
		@setString()
		@setSubscribe()

	setLayer: ->
		@components.layer = $('<div id="layer"></div>')
		$(@components.layer).css(
			'position': 'absolute'
			'zIndex': '1000'
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
			'zIndex': '1001'
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

	setCommonNotice: ->
		@components.commonNotice = $('<div id="commonNotice"></div>')
		$(@components.commonNotice).css(
			'zIndex': '1002'
			'position': 'absolute'
			'width': '40%'
			'height': '100px'
			'opacity' : '0.5'
			'bottom': '10px'
			'right': '20px'
			'font-weight': 'bold'
			'font-size': '13px'
			'padding': '4px 12px'
			'color': '#D2EAF5'
			'backgroundColor': '#555'
			'border': '1px solid #aaa'
			'display': 'none'
			'order-radius': '6px'
			'-webkit-border-radius': '6px'
			'-moz-border-radius': '6px'
				).appendTo('body')

	addCommonNotice: (notice, timeout)->
		noticeCount = $(@components.commonNotice).children().length
		timeout = timeout || (5000 + noticeCount * 300)
		@commonLogs.push notice
		if($(@components.commonNotice).css('display') == 'none')
			$(@components.commonNotice).fadeIn(200)
		node = $('<div style="opacity:1.0;">' + notice + '</div>').hide()
		$(@components.commonNotice).append(node)
		setTimeout(do=>
			that = node
			=>												# TODO: 関数オブジェクト作りすぎ。そのうち直す
				$(that).fadeOut 200, =>
					$(that).empty().show().css
						height: '20px'
					handler = setInterval(=>
						height = $(that).css('height').match(/^([0-9]+)px$/)[1] - 0
						$(that).css('height', (height - 1)+'px')
						if height < 1
							clearInterval(handler)
							$(that).remove()
							if $(@components.commonNotice).children().length == 0
								$(@components.commonNotice).fadeOut(150)
					25)
		, timeout)
		$(node).show(200)

	setSubscribe: ->
		dojo.subscribe 'layout/LAN/fadeIn', @, @fadeIn
		dojo.subscribe 'layout/LAN/fadeOut', @, @fadeOut
		dojo.subscribe 'layout/LAN/setString', @, @setString
		dojo.subscribe 'layout/LAN/setNotice', @, @setNotice
		dojo.subscribe 'layout/LAN/clearNotice', @, @clearNotice
		dojo.subscribe 'layout/LAN/addCommonNotice', @, @addCommonNotice

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