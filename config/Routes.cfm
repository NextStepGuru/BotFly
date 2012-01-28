<cfscript>

	setUniqueURLS(false);
	setAutoReload(false);
	setExtensionDetection(true);
	setValidExtensions('xml,json,jsont,jsonp');
	setThrowOnInvalidExtension(false);

	setBaseURL("/");

	//addModuleRoutes(pattern="/forgebox",module="forgebox");

	addRoute(pattern=":handler/:action?/:id?");

	function PathInfoProvider(Event){

		return CGI.PATH_INFO;
	}
</cfscript>