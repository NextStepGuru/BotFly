component extends="coldbox.system.Coldbox" output="false"{
	setting enablecfoutputonly="yes";
	this.name = hash(getCurrentTemplatePath());
	this.sessionManagement = true;
	this.sessionTimeout = createTimeSpan(0,0,30,0);
	this.setClientCookies = true;

	COLDBOX_APP_ROOT_PATH = getDirectoryFromPath(getCurrentTemplatePath());
	COLDBOX_APP_MAPPING   = "";
	COLDBOX_CONFIG_FILE   = "";
	COLDBOX_APP_KEY       = "";

	this.ormEnabled = true;
	this.datasource = "logfly";
	this.ormSettings 	= {
		flushAtRequestEnd		= false,
		automanageSession		= false,
		autogenmap				= true,
		eventHandling			= true,
		logSQL					= true,
		secondaryCacheEnabled	= true,
		useDBForMapping			= false,
		savemapping				= false,
		skipCFCWithError		= true,
		cacheprovider			= "ehCache",
		dbcreate				= "none",
		eventHandler			= "flybox.model.EventHandler",
		cfclocation				= "model"
	};


	public boolean function onRequestStart(required string targetPage){

		if(findNoCase('index.cfm', listLast(arguments.targetPage, '/'))){
			reloadChecks();
			processColdBoxRequest();
		}

		return true;
	}

}