
dojo.provide 'app.Mediater'

dojo.declare(
	'app.Mediater'
	null

	data: {}

	constructor: ->
		dojo.subscribe 'Mediater/register', @, @register
		dojo.subscribe 'Mediater/call', @, @call

	register: (name, context, process)->
		console.log 'Mediater> register ' + name, context, typeof process
		if !@data[name]? then @data[name] = []
		@data[name].push {
			'context': context
			'process': process
		}
		# context.destroy()が呼ばれた際に、自動でMediaterの呼び出しリストからも削除する
		dojo.connect context, 'destroy', @, ->
			console.log 'DESTROY', @
			@unregister name, context, process

	unregister: (name, context, process)->
		console.log 'Mediater> unregister ' + name, context, typeof process
		if @data[name]?
			for val,index in @data[name]
				if val? and val.context == context and val.process == process
					delete @data[name][index]
					@data[name].splice(index, 1)

	call: (name, args)->
		console.log 'Mediater> ' + name + ' called with ', args
		if !@data[name]? then return console.log 'Mediater> there is no process about ' + name
		for i in @data[name]
			if typeof i.process == 'function'
				i.process.call(i.context, args)
			else if typeof i.process == 'string'
				dojo.publish(i.process, args)

)