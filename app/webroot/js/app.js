dojo.require("dojo.parser");
dojo.registerModulePath("app", "../app");
dojo.require("app.App");
var APP;
$(document).ready(function(){
	APP = new app.App();
});
