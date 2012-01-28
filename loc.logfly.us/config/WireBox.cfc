component output="false" hint="The default WireBox Injector configuration object" extends="coldbox.system.ioc.config.Binder"{

	function configure(){

		wireBox = {
			scopeRegistration = {
				enabled = true,
				scope   = "application", // server, cluster, session, application
				key		= "wireBox"
			},

			customDSL = {
			},

			customScopes = {
			},

			scanLocations = [],
			stopRecursions = [],
			parentInjector = "",
			listeners = [
				 { class="coldbox.system.aop.Mixer", properties={} }
			]
		};

	}

}