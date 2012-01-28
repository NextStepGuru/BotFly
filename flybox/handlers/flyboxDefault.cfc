component output="false" cache="true"{

	property name="log"			 		inject="logbox:logger:{this}";
	property name="logger"           	inject="coldbox:plugin:logger";
	property name="sessionStorage"		inject="coldbox:plugin:sessionStorage";

	void function onAppInit(required any event,required any rc,required any prc){

	}

	void function onAppEnd(required any event,required any rc,required any prc){

	}

	public void function onRequestStart(required any event,required any rc,required any prc){
		// create defaults for assets
		prc.assets = buildAssetsData();

		// creates defaults for meta
		prc.meta = buildMetaData();

		// sets default for title
		prc.meta.title = getSetting('appName');

		// site specific settings
		if(settingExists('site')){

			// loads Site Structure from ColdBox Config
			var site = getSetting('site');

			// sets default for title if it exists
			if(structKeyExists(site,'title')){
				prc.meta.title = site['title'];
			}

			if(structKeyExists(site,'asset')){
				// loads Assets from Coldbox Config
				for(var i=1;i<=arrayLen(site['asset']);i++){
					addAsset(asset=site['asset'][i]['asset'],sendToHeader=site['asset'][i]['header'],assetType=site['asset'][i]['type']);
				}
			}

			if(structKeyExists(site,'library')){
				// loads Libraries from Coldbox Config
				for(var i=1;i<=arrayLen(site['library']);i++){
					addAssetLibrary(library=site['library'][i]);
				}
			}
		}
	}

	void function onRequestEnd(required any event,required any rc,required any prc){

	}

	void function onSessionStart(required any event,required any rc,required any prc){

	}

	void function onSessionEnd(required any event,required any rc,required any prc){
		var sessionScope = event.getValue("sessionReference");
		var applicationScope = event.getValue("applicationReference");
	}

	void function onException(required any event,required any rc,required any prc){
		if(getSetting('environment') eq "production"){
			logger.logErrorWithBean(event.getValue("ExceptionBean"));
		}
		header statusCode="500" statusText="Unhandled Exception";
	}

	void function onMissingTemplate(required any event,required any rc,required any prc){
		if(getSetting('environment') eq "production"){
			logger.logErrorWithBean(event.getValue("ExceptionBean"));
		}
		header statusCode="404" statusText="File not Found";
	}

	void function onInvalidEvent(required any event,required any rc,required any prc){
		if(getSetting('environment') eq "production"){
			logger.logErrorWithBean(event.getValue("ExceptionBean"));
		}
		header statusCode="500" statusText="Unhandled Exception";
	}
}
