component output="false" hint="coldBox"{

	function configure(){

		coldbox = {

			appName 					= "coldBox",
			eventName 					= "event",
			debugMode					= false,
			debugPassword				= "",
			reinitPassword				= "",
			handlersIndexAutoReload 	= false,
			configAutoReload			= false,
			defaultEvent				= "general.index",
			requestStartHandler			= "flyboxDefault.onRequestStart",
			requestEndHandler			= "flyboxDefault.onRequestEnd",
			applicationStartHandler 	= "flyboxDefault.onAppInit",
			applicationEndHandler		= "flyboxDefault.onAppEnd",
			sessionStartHandler 		= "flyboxDefault.onSessionStart",
			sessionEndHandler			= "flyboxDefault.onSessionEnd",
			missingTemplateHandler		= "flyboxDefault.onMissingTemplate",
			UDFLibraryFile 				= "flybox/udf/udf.cfm",
			coldboxExtensionsLocation 	= "",
			modulesExternalLocation		= ["flybox/modules"],
			pluginsExternalLocation 	= "flybox/plugins",
			viewsExternalLocation		= "flybox/views",
			layoutsExternalLocation 	= "flybox/layouts",
			handlersExternalLocation  	= "flybox/handlers",
			requestContextDecorator 	= "flybox.model.RequestContextDecorator",
			exceptionHandler			= "flyboxDefault.onException",
			onInvalidEvent				= "flyboxDefault.onInvalidEvent",
			customErrorTemplate			= "",
			handlerCaching 				= true,
			eventCaching				= true,
			proxyReturnCollection 		= false,
			flashURLPersistScope		= "session"
		};

		// custom settings
		settings = {
			s3Access = "1TNVKRF63MSSVZY4HHG2",
			s3Secret = "vdpeY4LMJrgOnUYFjc77ZWYKRdefur07dBCpXX1x",
			jsmin_cacheLocation = '/assets/cache',
			jsmin_enable = true,
			minify_html = true,
			emailYak_api = 'qui7efnusdq120k',
			messagebox_style_override = true,
			framelessGrid_debug = true,
			site = {
				title = 'logFly | Offsite Logging',

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
						subject = "LogFly",
						from = "info@logfly.us",
						to = "jeremy.deyoung@lunarfly.com",
			            mailserver = "smtp.postmarkapp.com",
			            mailusername = "f84934ef-7f4f-4443-a488-f039215f2e0e",
			            mailpassword = "f84934ef-7f4f-4443-a488-f039215f2e0e",
			            mailport = 25
					},
					layout="flybox.model.email.emailLayouts"
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
			{class="flybox.interceptors.detectDevice",
			 properties={}
			},
			{class="flybox.interceptors.minify",
			 properties={}
			}
		];


		//Debugger Settings
		debugger = {
			enableDumpVar = false,
			persistentRequestProfilers = true,
			maxPersistentRequestProfilers = 10,
			maxRCPanelQueryRows = 50,
			//Panels
			showTracerPanel = true,
			expandedTracerPanel = false,
			showInfoPanel = true,
			expandedInfoPanel = false,
			showCachePanel = false,
			expandedCachePanel = false,
			showRCPanel = false,
			expandedRCPanel = false,
			showModulesPanel = false,
			expandedModulesPanel = false
		};

		//Mailsettings
		mailSettings = {
			protocol = {
				class = "coldbox.system.core.mail.protocols.PostmarkProtocol",
				properties = {
					apiKey = "f84934ef-7f4f-4443-a488-f039215f2e0e"
				}
			}
		};

		//Datasources
		datasources = {
			mpt_dsn = {name="qz", dbType="mysql", username="qz", password="noah$1jrd$1"}
		};
	}

    function development()
    {
    	// coldbox overrides
		coldbox.customErrorTemplate			= "";
		coldbox.handlerCaching 				= false;
		coldbox.eventCaching				= false;

        //Debugger overrides
		debugger.showTracerPanel = true;
		debugger.showInfoPanel = true;

		//LogBox DSL
		logBox = {
			// Define Appenders
			appenders = {
				coldboxTracer = { class="coldbox.system.logging.appenders.ColdboxTracerAppender" }
			},
			// Root Logger
			root = { levelMin="FATAL", levelMax="WARN", appenders="*" }
		};
   	}
}
