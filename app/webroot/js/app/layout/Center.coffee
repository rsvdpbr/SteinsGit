
dojo.provide 'app.layout.Center'

dojo.require 'dijit._Widget'
dojo.require 'dijit._Templated'

dojo.declare(
	'app.layout.Center'
	[dijit._Widget, dijit._Templated]

	widgetsInTemplate:true
	templateString: dojo.cache 'app.layout','templates/Center.html'
	style: 'width:100%; height:100%; padding:8px; border:1px solid #aaa; background-color:#fdfdff;'

)
