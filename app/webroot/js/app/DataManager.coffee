
dojo.provide 'app.DataManager'

dojo.require 'dojox.encoding.digests.MD5'

dojo.declare(
	'app.DataManager'
	null

	cache: {}
	defaultPostData: {}

	constructor: ->
		@setSubscribe()
	setSubscribe: ->
		dojo.subscribe 'DataManager/clearCache', @, -> @cache = {}
		dojo.subscribe 'DataManager/setDefaultPostData', @, @setDefaultPostData
		dojo.subscribe 'DataManager/fetch', @, @fetch

	# keyとvalueを渡すことで、fetch時のPOSTのデフォルトデータを設定
	setDefaultPostData: (key, value)->
		@defaultPostData[key] = value

	# 使用APIとPOSTデータから、ハッシュ値を取得
	# ここでいうPOSTデータは、引数とデフォルト値がミックスインされた後のものを想定
	getHashKey: (dataname, postdata)->
		data = dojo.toJson([dataname, postdata])
		dojox.encoding.digests.MD5(data)

	# サーバーからデータを取得する
	# dataname=API名
	# param.postdata=POSTで渡すオプション
	# param.context=コールバック関数が呼び出されるコンテキスト
	# param.force=trueの場合はキャッシュ無視
	# func=コールバック関数
	fetch: (dataname, param, func)->
		dojo.publish 'layout/LAN/fadeIn', ['サーバーからデータを取得中']
		context = if param.context? then param.context else this
		# POSTデータとして、引数のオプションとデフォルトのデータをミックスイン
		if param.postdata?
			postdata = dojo.mixin(dojo.clone(@defaultPostData), postdata)
		else
			postdata = dojo.clone(@defaultPostData)
		# キャッシュチェック
		hashkey = @getHashKey(dataname, postdata)
		if @cache[hashkey]? or (param.force? and param.force == true)
			dojo.publish 'layout/LAN/setNotice', ['ローカルキャッシュからデータを取得完了']
			dojo.publish 'layout/LAN/fadeOut'
			return func.apply(context, [dojo.clone @cache[hashkey]])
		# 通信
		that = @
		dojo.xhrPost
			url: dataname + '.json'
			handleAs: 'json'
			content: postdata
			load: (data)->
				console.log 'LOAD COMPLETE', dataname , data
				# サーバー側で論理エラーが発生していたら、throwする
				if data.error.length > 0 then throw data.error[0]
				that.cache[hashkey] = data.result
				func.apply(context, [dojo.clone data.result])
				dojo.publish 'layout/LAN/setNotice', ['サーバーからデータの取得を完了']
				dojo.publish 'layout/LAN/fadeOut'
			error: (error)->
				console.log 'ERROR OCCURRED', dataname, error
				dojo.publish 'layout/LAN/setNotice', ['データ取得中にエラーが発生']
				dojo.publish 'layout/LAN/fadeOut'
		
	
)