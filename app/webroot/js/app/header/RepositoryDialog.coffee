
dojo.provide 'app.header.RepositoryDialog'

dojo.require 'dijit._Templated'
dojo.require 'dijit.Dialog'
dojo.require 'dijit.form.Form'
dojo.require 'dijit.form.TextBox'
dojo.require 'dijit.form.Button'

dojo.declare(
	'app.header.RepositoryDialog'
	[dijit.Dialog, dijit._Templated]

	templateString: dojo.cache 'app.header', 'templates/RepositoryDialog.html'
	widgetsInTemplate: true
	title: 'Add New Repository'
	style: 'width:500px'

	constructor: ->
		@inherited arguments

	postCreate: ->
		@inherited arguments
		dojo.connect @domRegister, 'onClick', @, @register
		dojo.connect @domCancel, 'onClick', @, @onCancel
		dojo.connect @domFormName, 'onKeyUp', @, @updateRegisterButton
		dojo.connect @domFormPath, 'onKeyUp', @, @updateRegisterButton

	updateRegisterButton: ->
		if @domFormName.getValue() == '' or @domFormPath.getValue() == ''
			@domRegister.setDisabled true
		else
			@domRegister.setDisabled false

	show: ->
		@inherited arguments
		@domFormName.setValue('')
		@domFormPath.setValue('')
		@domRegister.setDisabled true

	register: ->
		data = @domForm.getValues()
		dojo.publish 'DataManager/fetch', ['addRepository',
			{
				context: @
				postdata:
					newRepoName: data.name
					newRepoPath: data.path
			}
			(data)->
				repo = data.repository
				dojo.publish 'layout/LAN/addCommonNotice', [data.repository+' リポジトリを追加しました']
				dojo.publish 'layout/Header/setRepositoryMenu'
				dojo.publish 'layout/Header/setRepository', [repo]
				@hide()
		]
		console.log @domForm, data

)
