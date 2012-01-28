component extends="coldbox.system.Interceptor" output="false"{
	property name="log" 				type="logbox:log:{this}";
	property name="siteService"			inject="model:site.siteService";

	public void function configure(){

	}

	public void function afterConfigurationLoad(){
		siteService.siteConfiguration();
	}

	public void function preEvent(){
		var rc = arguments.event.getCollection();
		var site = siteService.siteConfiguration();
		rc.site = structNew();
		rc.site['id'] 					= site.getID();
		rc.site['title'] 				= site.getName();
		rc.site['logo']					= site.getLogo();
		rc.site['url'] 					= site.getShortURL();
		rc.site['email'] 				= site.getEmail();
		rc.site['menusLocation1'] 		= site.getMenusLocation1();
		rc.site['menusLocation2'] 		= site.getMenusLocation2();
		rc.site['menusLocation3'] 		= site.getMenusLocation3();
		rc.site['defaultAffiliateID']	= site.getDefaultAffiliateID();
		rc.site['pages']				= site.getPages();
	}

}

