component output="false" hint="coldBox"{

	function configure(){

		coldbox = {

			appName 					= "{botfly}",
			eventName 					= "event",
			debugMode					= false,
			debugPassword				= "",
			reinitPassword				= "",
			handlersIndexAutoReload 	= false,
			configAutoReload			= false,
			defaultEvent				= "general.index",
			requestStartHandler			= "botflyDefault.onRequestStart",
			requestEndHandler			= "botflyDefault.onRequestEnd",
			applicationStartHandler 	= "botflyDefault.onAppInit",
			applicationEndHandler		= "botflyDefault.onAppEnd",
			sessionStartHandler 		= "botflyDefault.onSessionStart",
			sessionEndHandler			= "botflyDefault.onSessionEnd",
			missingTemplateHandler		= "botflyDefault.onMissingTemplate",
			UDFLibraryFile 				= "botfly/udf/udf.cfm",
			coldboxExtensionsLocation 	= "",
			modulesExternalLocation		= ["botfly/modules"],
			pluginsExternalLocation 	= "botfly/plugins",
			viewsExternalLocation		= "botfly/views",
			layoutsExternalLocation 	= "botfly/layouts",
			handlersExternalLocation  	= "botfly/handlers",
			requestContextDecorator 	= "botfly.model.RequestContextDecorator",
			exceptionHandler			= "botflyDefault.onException",
			onInvalidEvent				= "botflyDefault.onInvalidEvent",
			customErrorTemplate			= "",
			handlerCaching 				= true,
			eventCaching				= true,
			proxyReturnCollection 		= false,
			flashURLPersistScope		= "session"
		};

		// custom settings
		settings = {
			s3Access 					= "{S3Access}",
			s3Secret 					= "{S3Secret}",
			jsmin_cacheLocation 		= '/assets/cache',
			jsmin_enable 				= true,
			minify_html 				= true,
			emailYak_api 				= '{EmailYak}',
			messagebox_style_override 	= true,
			pusher_logger				= true,
			pusher_key 					= '{PusherKey}',
			pusher_secret 				= '{PusherSecret}',
			pusher_appID 				= '{PusherAppID}',
			framelessGrid_debug 		= true,
			site = {
				title = '{Title}',

				// loads site specific js/css files
				asset = [
							{asset='/assets/css/main.css',header=true,type='css'},
							{asset='/assets/js/main.js',header=true,type='js'}
						],

				// loads site specific libraries
				library = ['normalizeCSS','jQuery','framelessGrid','formalize']
			}
		};

		environments = {
			development = "^loc."
		};

		modules = {
			autoReload = false,
			include = [],
			exclude = []
		};

		orm = {
			injection = {
				// enable entity injection
				enabled = true,
				// a list of entity names to include in the injections
				include = "",
				// a list of entity names to exclude from injection
				exclude = ""
			}
		}

		//LogBox DSL
		logBox = {
			// Define Appenders
			appenders = {
				coldboxTracer = { class="coldbox.system.logging.appenders.ColdboxTracerAppender" },
				EmailAppender = {
					class="coldbox.system.logging.appenders.EmailAppender",
					properties={
						subject = "{Subject}",
						from = "{FromEmail}",
						to = "{ToEmail}",
			            mailserver = "smtp.postmarkapp.com",
			            mailusername = "{PostmarkAPI}",
			            mailpassword = "{PostmarkAPI}",
			            mailport = 25
					},
					layout="botfly.model.email.emailLayouts"
				}
			},
			// Root Logger
			root = { levelMin="FATAL", levelMax="WARN", appenders="*" }
		};

		//Layout Settings
		layoutSettings = {
			defaultLayout = "Layout.Default.cfm",
			defaultView   = ""
		};

		//WireBox Integration
		wireBox = {
			enabled = true,
			binder="config.WireBox",
			singletonReload=false
		};

		//Interceptor Settings
		interceptorSettings = {
			throwOnInvalidStates = false,
			customInterceptionPoints = ""
		};

		//Register interceptors as an array, we need order
		interceptors = [
			// security
			{class="coldbox.system.interceptors.security",
			 properties={
				rulesSource="xml",
				rulesFile="config/securityRules.xml.cfm",
				debugMode=true,
				preEventSecurity=true
			 }
			},
			//SES
			{class="coldbox.system.interceptors.SES",
			 properties={}
			},
			//Detect Device
			{class="botfly.interceptors.detectDevice",
			 properties={}
			},
			{class="botfly.interceptors.minify",
			 properties={}
			}
		];


		//Debugger Settings
		debugger = {
			enableDumpVar 					= false,
			persistentRequestProfilers 		= true,
			maxPersistentRequestProfilers 	= 10,
			maxRCPanelQueryRows 			= 50,
			//Panels
			showTracerPanel 				= true,
			expandedTracerPanel 			= false,
			showInfoPanel 					= true,
			expandedInfoPanel 				= false,
			showCachePanel 					= false,
			expandedCachePanel 				= false,
			showRCPanel 					= false,
			expandedRCPanel 				= false,
			showModulesPanel 				= false,
			expandedModulesPanel 			= false
		};

		//Mailsettings
		mailSettings = {
			protocol = {
				class = "coldbox.system.core.mail.protocols.PostmarkProtocol",
				properties = {
					apiKey = "{PostmarkAPI}"
				}
			}
		};

		//Datasources
		datasources = {
			dsn = {name="{botfly}", dbType="mysql", username="{botfly}", password="{botfly}"}
		};
	}

    function development()
    {
    	// coldbox overrides
		coldbox.customErrorTemplate		= "";
		coldbox.handlerCaching 			= false;
		coldbox.eventCaching			= false;

        //Debugger overrides
		debugger.showTracerPanel 		= true;
		debugger.showInfoPanel 			= true;

		//LogBox DSL
		logBox = {
			// Define Appenders
			appenders = {
				coldboxTracer 			= { class="coldbox.system.logging.appenders.ColdboxTracerAppender" }
			},
			// Root Logger
			root 						= { levelMin="FATAL", levelMax="WARN", appenders="*" }
		};
   	}
}
