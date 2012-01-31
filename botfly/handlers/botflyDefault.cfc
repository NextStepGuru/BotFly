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

		// defines the start time for processing this request
		prc.startTime = getTickCount();

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

			addAsset(asset='/botfly/css/botfly/global.css',sendToHeader=true,assetType='css',filter='any');

			if(structKeyExists(site,'library')){
				// loads Libraries from Coldbox Config
				for(var i=1;i<=arrayLen(site['library']);i++){
					addAssetLibrary(library=site['library'][i]);
				}
			}

			if(structKeyExists(site,'asset')){
				// loads Assets from Coldbox Config
				for(var i=1;i<=arrayLen(site['asset']);i++){
					var header = false;
					var type = 'js';
					var filter = 'any';
					if(structKeyExists(site['asset'][i],'header')){
						header = site['asset'][i]['header'];
					}
					if(structKeyExists(site['asset'][i],'type')){
						type = site['asset'][i]['type'];
					}
					if(structKeyExists(site['asset'][i],'filter')){
						filter = site['asset'][i]['filter'];
					}
					addAsset(asset=site['asset'][i]['asset'],sendToHeader=header,assetType=type,filter=filter);
				}
			}
		}

		if(structKeyExists(site,'loginSecurity') && site['loginSecurity'] && structKeyExists(site,'loginModel'))
			if(!sessionStorage.exists('account')){
				getModel(site['loginModel']).checkSecurity();
			}
	}

	void function onRequestEnd(required any event,required any rc,required any prc){
		logWithPusher(statusCode=200,statusText="Success",prc=arguments.prc);
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

		logWithPusher(statusCode=500,statusText="Internet Server Error",prc=arguments.prc);
	}

	void function onMissingTemplate(required any event,required any rc,required any prc){
		if(getSetting('environment') eq "production"){
			logger.logErrorWithBean(event.getValue("ExceptionBean"));
		}
		header statusCode="404" statusText="File not Found";

		logWithPusher(statusCode=404,statusText="File Not Found",prc=arguments.prc);
	}

	void function onInvalidEvent(required any event,required any rc,required any prc){
		if(getSetting('environment') eq "production"){
			logger.logErrorWithBean(event.getValue("ExceptionBean"));
		}
		header statusCode="500" statusText="Unhandled Exception";

		logWithPusher(statusCode=400,statusText="Bad Request",prc=arguments.prc);
	}

	void function logWithPusher(required numeric statusCode=200, required string statusMessage="Success", required string requestData="", required string responseData="", required any prc){

		var myThread = "t#reReplace(createUUID(),'\W','','all')#";
		if(!listFindNoCase('yottaamonitor',cgi.HTTP_USER_AGENT)){
			thread name=myThread useragent=cgi.HTTP_USER_AGENT remoteIP=cgi.REMOTE_ADDR remoteUser='' channel=reReplace(getSetting('appName'),'\W','','all') apiMethod=GetHttpRequestData()['method'] apiServer=cgi.http_host responseTime=(getTickCount()-prc.startTime) appID=getSetting('pusher_appID') appKey=getSetting('pusher_key') appSecret=getSetting('pusher_secret') apiCall=cgi.path_info statusCode=arguments.statusCode statusMessage=arguments.statusMessage  requestData=arguments.requestData responseData=arguments.responseData {

				var data = structNew();
					data.request = requestData;
					data.response = responseData;
					data.api = structNew();
					data.api.call = apiCall;
					data.api.code = statusCode;
					data.api.message = statusMessage;
					data.api.response = responseTime;
					data.api.remoteIP = remoteIP;
					data.api.remoteUser = remoteUser;
					data.api.server = apiServer;
					data.api.useragent = useragent;
					data.api.method = apiMethod;
					data.api.ts = dateFormat(now(),'yyyy-mm-dd') & "T" & timeFormat(now(),'hh:mm:ss') & "Z";

				var pusher = createObject('component','botfly.plugins.pusher').init();
					pusher.setAppID(appID);
					pusher.setAppKey(appKey);
					pusher.setAppSecret(appSecret);
					pusher.TriggerPush(channel=channel,event='log',jsonData=serializeJSON(data));
			}
		}
	}
}
